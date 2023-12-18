const std = @import("std");
const print = std.debug.print;

const GRID_SIZE = 10000;

fn countInside(grid: *[][]u32, x: usize, y: usize) void {
    if (grid.*[y][x] == 1) {
        return;
    }

    if (grid.*[y][x] > 2) {
        return;
    }

    grid.*[y][x] = 1;

    countInside(grid, x - 1, y);
    countInside(grid, x + 1, y);
    countInside(grid, x, y - 1);
    countInside(grid, x, y + 1);

    countInside(grid, x - 1, y - 1);
    countInside(grid, x + 1, y - 1);
    countInside(grid, x + 1, y + 1);
    countInside(grid, x - 1, y + 1);
}

pub fn solve(input: [][]const u8) !void {
    const allocator = std.heap.page_allocator;

    var grid = try allocator.alloc([]u32, GRID_SIZE);
    for (0..grid.len) |i| {
        grid[i] = try allocator.alloc(u32, GRID_SIZE);
        @memset(grid[i], 2);
    }

    var coords = std.ArrayList(u128).init(allocator);

    var x: usize = GRID_SIZE / 2;
    var y: usize = GRID_SIZE / 2;

    var part2x: usize = 20_000_000_000;
    var part2y: usize = 20_000_000_000;
    var part2edges: usize = 0;

    for (input) |line| {
        var tokenizer = std.mem.tokenizeSequence(u8, line, " ");

        var stringDirection = tokenizer.next().?;
        var times = try std.fmt.parseInt(u32, tokenizer.next().?, 10);

        var stringColour = tokenizer.next().?;
        var colour = try std.fmt.parseInt(u32, stringColour[2 .. stringColour.len - 2], 16);

        for (0..times) |_| {
            switch (stringDirection[0]) {
                'U' => {
                    y -= 1;
                },
                'D' => {
                    y += 1;
                },
                'R' => {
                    x += 1;
                },
                'L' => {
                    x -= 1;
                },
                else => unreachable,
            }
            grid[y][x] = colour;
        }

        var part2Direction = stringColour[stringColour.len - 2 .. stringColour.len - 1][0] - '0';

        part2edges += colour;

        if (part2Direction == 0) {
            // Right
            var c2 = @as(u128, part2x + colour) << 64 | @as(u128, part2y);

            part2x = part2x + colour;

            // try coords.put(c1, true);
            try coords.append(c2);
        } else if (part2Direction == 1) {
            // Down
            var c2 = @as(u128, part2x) << 64 | @as(u128, part2y + colour);

            part2y = part2y + colour;

            // try coords.put(c1, true);
            try coords.append(c2);
        } else if (part2Direction == 2) {
            // Left
            var c2 = @as(u128, part2x - colour) << 64 | @as(u128, part2y);

            part2x = part2x - colour;

            // try coords.put(c1, true);
            try coords.append(c2);
        } else if (part2Direction == 3) {
            // Up
            var c2 = @as(u128, part2x) << 64 | @as(u128, part2y - colour);

            part2y = part2y - colour;

            // try coords.put(c1, true);
            try coords.append(c2);
        }
    }

    countInside(&grid, GRID_SIZE / 2 + 1, GRID_SIZE / 2 + 1);

    var part1: usize = 0;
    var part2: i256 = 0;

    for (4800..5300) |i| {
        for (4800..5300) |j| {
            if (grid[i][j] == 2) {
                // print(".", .{});
            } else {
                // print("#", .{});
                part1 += 1;
            }
        }
        // print("\n", .{});
    }

    var first = coords.items[0];
    var prev = first;

    var items = try coords.toOwnedSlice();

    for (items) |key| {
        var x2 = @as(i256, key >> 64);
        var y2 = @as(i256, key & 0xFFFFFFFFFFFFFFFF);

        var x1 = @as(i256, prev >> 64);
        var y1 = @as(i256, prev & 0xFFFFFFFFFFFFFFFF);

        prev = key;

        part2 += x1 * y2 - x2 * y1;
    }

    var x2 = @as(i256, first >> 64);
    var y2 = @as(i256, first & 0xFFFFFFFFFFFFFFFF);

    var x1 = @as(i256, prev >> 64);
    var y1 = @as(i256, prev & 0xFFFFFFFFFFFFFFFF);

    part2 += x1 * y2 - x2 * y1;
    part2 = @divTrunc(part2, 2);
    part2 += part2edges / 2 + 1;

    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}
