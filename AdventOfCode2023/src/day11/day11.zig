const std = @import("std");
const print = std.debug.print;

const GALAXY = 1;
const SPACE = 0;

fn min(num1: u256, num2: u256) usize {
    if (num1 > num2) {
        return @truncate(num2);
    }
    return @truncate(num1);
}

fn max(num1: u256, num2: u256) usize {
    if (num1 <= num2) {
        return @truncate(num2);
    }
    return @truncate(num1);
}

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;

    var grid = try allocator.alloc(u256, input.len);
    var index: usize = 0;

    for (input) |line| {
        var line1: u256 = 0;
        for (line) |_c| {
            var c: u8 = 0;
            if (_c == '.') {
                c = SPACE;
            } else {
                c = GALAXY;
            }

            line1 = (line1 << 1) | @as(u256, c);
        }

        grid[index] = line1;
        index += 1;
    }

    var rows: u256 = 0;
    var cols: u256 = 0;

    for (grid) |row| {
        if (row == 0) {
            rows = (rows << 1) | @as(u256, 1);
            continue;
        }
        rows = rows << 1;
    }

    for (0..input[0].len) |i| {
        var empty = true;
        for (grid) |row| {
            var truncated: u8 = @truncate(input[0].len - i - 1);
            if (row & @as(u256, @as(u256, 1) << truncated) != 0) {
                empty = false;
                break;
            }
        }

        if (empty) {
            cols = (cols << 1) | @as(u256, 1);
            continue;
        }
        cols = cols << 1;
    }

    var pair: usize = 0;
    var part1: usize = 0;

    for (grid, 0..) |row, i| {
        var galaxy: u265 = 1;
        for (1..256) |k1| {
            var comp1 = galaxy & row;
            if (comp1 > 0) {

                //
                // We found galaxy!
                //

                for (i..grid.len) |j| {
                    var rowAgain = grid[j];
                    var galaxy2: u265 = 1;

                    for (1..256) |k2| {
                        var comp2 = galaxy2 & rowAgain;
                        if (comp2 > 0) {
                            var found = i != j or k2 > k1;

                            if (found) {
                                pair += 1;
                                var distY: u256 = 0;
                                if (k1 > k2) {
                                    distY = k1 - k2;
                                } else {
                                    distY = k2 - k1;
                                }

                                // print("Galaxy 1 | {},{}\n", .{ k1, i });
                                // print("Galaxy 2 | {},{}\n", .{ k2, j });

                                var emptyRows: u256 = 0;
                                var emptyCols: u256 = 0;

                                if (i != j) {
                                    for (i + 1..j) |_shift| {
                                        var shift: u8 = @truncate(_shift);
                                        var u8Length: u8 = @truncate(input.len);
                                        var r = @as(u256, 1) << (u8Length - shift - 1);

                                        if (r & rows > 0) {
                                            emptyRows += 1;
                                        }
                                    }
                                }

                                if (k1 != k2) {
                                    for (min(k1, k2) + 1..max(k1, k2)) |_shift| {
                                        var shift: u8 = @truncate(_shift);
                                        var u8Length: u8 = @truncate(input[0].len);
                                        var r = @as(u256, 1) << (u8Length - shift - 1);

                                        if (r & cols > 0) {
                                            emptyCols += 1;
                                        }
                                    }
                                }

                                var dist = distY + (j - i) + emptyRows + emptyCols;

                                print("Distance: {}\n", .{dist});
                                print("---\n", .{});
                                part1 += @truncate(dist);
                            }
                        }
                        galaxy2 = galaxy2 << 1;
                    }
                }
            }
            galaxy = galaxy << 1;
        }
    }

    print("Pairs: {}\n", .{pair});
    print("Part 1: {}\n", .{part1});
}
