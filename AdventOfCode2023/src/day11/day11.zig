const std = @import("std");
const print = std.debug.print;

const GALAXY = 1;
const SPACE = 0;

fn min(num1: usize, num2: usize) usize {
    if (num1 > num2) {
        return (num2);
    }
    return (num1);
}

fn max(num1: usize, num2: usize) usize {
    if (num1 <= num2) {
        return (num2);
    }
    return (num1);
}

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;

    var emptyRows = std.AutoHashMap(usize, usize).init(allocator);
    var emptyCols = std.AutoHashMap(usize, usize).init(allocator);

    for (input, 0..) |line, i| {
        var emptyRow = true;
        for (line) |c| {
            if (c == '#') {
                emptyRow = false;
                break;
            }
        }
        if (emptyRow) {
            try emptyRows.put(i, 1);
        }
    }

    for (0..input[0].len) |i| {
        var emptyCol = true;
        for (0..input.len) |j| {
            if (input[j][i] == '#') {
                emptyCol = false;
            }
        }
        if (emptyCol) {
            try emptyCols.put(i, 1);
        }
    }

    var pairs: usize = 0;
    var part1: usize = 0;

    var MULTIPLIER: usize = 1_000_000;

    for (0..input.len) |i| {
        for (0..input[0].len) |j| {
            if (input[i][j] != '#') {
                continue;
            }

            // found one.
            for (i..input.len) |a| {
                for (0..input[0].len) |b| {
                    if (i == a and j == b) {
                        continue;
                    }
                    if (i == a and b < j) {
                        continue;
                    }
                    if (input[a][b] != '#') {
                        continue;
                    }

                    // print("Galaxy 1 | {} {}\n", .{ j, i });
                    // print("Galaxy 2 | {} {}\n", .{ b, a });

                    var dist: usize = (a - i) + (max(j, b) - min(j, b));

                    for (i..a) |k| {
                        if (emptyRows.get(k)) |_| {
                            dist += MULTIPLIER - 1;
                        }
                    }

                    for (min(j, b)..max(j, b)) |k| {
                        if (emptyCols.get(k)) |_| {
                            dist += MULTIPLIER - 1;
                        }
                    }

                    // print("Distance: {}\n", .{dist});
                    // print("----\n", .{});
                    pairs += 1;
                    part1 += dist;
                }
            }
        }
    }

    print("Pairs: {}\n", .{pairs});
    print("Part 1: {}\n", .{part1});
}
