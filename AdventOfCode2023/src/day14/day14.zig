const std = @import("std");
const print = std.debug.print;

const ROCK = 'O';
const OBSTACLE = '#';
const EMPTY = '.';

const Direction = enum { north, west, south, east };

fn get_direction_offsets(direction: Direction) struct { i32, i32 } {
    const offsets: struct { i32, i32 } = switch (direction) {
        Direction.north => .{ -1, 0 },
        Direction.west => .{ 0, -1 },
        Direction.south => .{ 1, 0 },
        Direction.east => .{ 0, 1 },
    };

    return offsets;
}

fn print_grid(grid: [][]const u8) void {
    for (0..grid.len) |i| {
        for (0..grid[0].len) |j| {
            print("{c}", .{grid[i][j]});
        }
        print("\n", .{});
    }
}

fn get_load(grid: [][]const u8) usize {
    var load: usize = 0;

    for (0..grid.len) |i| {
        for (0..grid[0].len) |j| {
            if (grid[i][j] != ROCK) {
                continue;
            }

            load += grid.len - i;
        }
    }

    return load;
}

fn stringify_grid(allocator: std.mem.Allocator, grid: [][]const u8) ![]u8 {
    var length: usize = 0;
    const row_length = grid[0].len;

    for (0..grid.len) |i| {
        length += grid[i].len;
    }

    var stringified = try allocator.alloc(u8, length);
    for (0..grid.len) |i| {
        for (0..grid[0].len) |j| {
            stringified[i * row_length + j] = grid[i][j];
        }
    }

    return stringified;
}

fn rotate_grid(grid_pointer: *[][]u8, direction: Direction) void {
    const grid = grid_pointer.*;
    const direction_offset = get_direction_offsets(direction);

    const forI: i32 = direction_offset[0];
    const forJ: i32 = direction_offset[1];

    while (true) {
        var has_changed = false;

        for (0..grid.len) |i| {
            if (direction == Direction.north and i == 0) {
                continue;
            }

            if (direction == Direction.south and i == grid.len - 1) {
                continue;
            }

            for (0..grid[0].len) |j| {
                if (direction == Direction.west and j == 0) {
                    continue;
                }

                if (direction == Direction.east and j == grid[0].len - 1) {
                    continue;
                }

                const current_block = grid[i][j];
                if (current_block != ROCK) {
                    continue;
                }

                const signedI: i32 = @intCast(i);
                const signedJ: i32 = @intCast(j);

                const offsetI: usize = @intCast(signedI + forI);
                const offsetJ: usize = @intCast(signedJ + forJ);

                const next_block = grid[offsetI][offsetJ];
                if (next_block != EMPTY) {
                    continue;
                }

                has_changed = true;
                grid[offsetI][offsetJ] = ROCK;
                grid[i][j] = EMPTY;
            }
        }

        if (!has_changed) {
            break;
        }
    }
}

const SPINS = 1000000000 * 4;

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;

    var copied_input = try allocator.alloc([]u8, input.len);
    defer allocator.free(copied_input);

    for (0..copied_input.len) |i| {
        copied_input[i] = try allocator.alloc(u8, input[0].len);
        std.mem.copyForwards(u8, copied_input[i], input[i]);
    }

    var string_set = std.StringHashMap(usize).init(allocator);

    var current_spin: usize = 0;

    while (current_spin < SPINS) {
        const direction = switch (current_spin % 4) {
            0 => Direction.north,
            1 => Direction.west,
            2 => Direction.south,
            3 => Direction.east,
            else => unreachable,
        };

        rotate_grid(&copied_input, direction);
        if (direction != Direction.north) {
            current_spin += 1;
            continue;
        }

        const mask = try stringify_grid(allocator, copied_input);

        if (string_set.get(mask)) |last_found| {
            const cycle = current_spin - last_found;
            const cycles_to_add = (SPINS - current_spin) / cycle;
            const fast_forward = cycle * cycles_to_add;

            current_spin += fast_forward;

            if (current_spin > SPINS) {
                unreachable;
            }
        } else {
            try string_set.put(mask, current_spin);
        }

        current_spin += 1;
    }

    print("Part 2: {}\n", .{get_load(copied_input)});
}
