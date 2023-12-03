const std = @import("std");

pub fn solve(input: [][]const u8) !void {
    const a = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(a);
    var allocator = arena.allocator();
    defer arena.deinit();

    // Grid of usize
    var grid = try allocator.alloc([]i32, input.len);

    for (0..grid.len) |index| {
        grid[index] = try allocator.alloc(i32, input[0].len);
    }

    var currentNumber: u32 = 0;
    for (0..grid.len) |i| {
        if (currentNumber != 0) {
            var digitCount = std.math.log10(currentNumber) + 1;

            for (0..digitCount) |k| {
                var typedCurrentNum: i32 = @intCast(currentNumber);
                grid[i - 1][grid[0].len - 1 - k] = typedCurrentNum;
            }
            currentNumber = 0;
        }

        for (0..grid[0].len) |j| {
            var char = input[i][j];
            if (char >= '0' and char <= '9') {
                currentNumber *= 10;
                currentNumber += char - '0';
            } else if (j > 0 and currentNumber > 0) {
                // How many digits did you span
                var digitCount = std.math.log10(currentNumber) + 1;

                for (0..digitCount) |k| {
                    var typedCurrentNum: i32 = @intCast(currentNumber);
                    grid[i][j - 1 - k] = typedCurrentNum;
                }
                currentNumber = 0;

                if (input[i][j] == '.') {
                    grid[i][j] = 0;
                } else if (input[i][j] == '*') {
                    grid[i][j] = -2; // gear
                } else {
                    grid[i][j] = -1; // any symbol
                }
            } else {
                if (input[i][j] == '.') {
                    grid[i][j] = 0;
                } else if (input[i][j] == '*') {
                    grid[i][j] = -2; // gear
                } else {
                    grid[i][j] = -1; // any symbol
                }
            }
        }
    }

    if (currentNumber != 0) {
        var digitCount = std.math.log10(currentNumber) + 1;
        for (0..digitCount) |k| {
            var typedCurrentNum: i32 = @intCast(currentNumber);
            grid[grid.len - 1][grid[0].len - k - 1] = typedCurrentNum;
        }
        currentNumber = 0;
    }

    // for (0..grid.len) |i| {
    //     for (0..grid[0].len) |j| {
    //         std.debug.print("{}, ", .{grid[i][j]});
    //     }
    //     std.debug.print("\n", .{});
    // }

    var part1: i32 = 0;
    var lastAddedNumber: i32 = 0;

    for (0..grid.len) |i| {
        for (0..grid[0].len) |j| {
            if (grid[i][j] > 0) {
                // std.debug.print("Num: {}\n", .{grid[i][j]});
                for (0..3) |aroundI| {
                    if (aroundI == 0 and i == 0) {
                        continue;
                    }

                    if (aroundI == 2 and i == grid.len - 1) {
                        continue;
                    }

                    // std.debug.print("Checking aroudnI: {}\n", .{aroundI});
                    for (0..3) |aroundJ| {
                        if (aroundI == 1 and aroundJ == 1) {
                            continue;
                        }
                        if (aroundJ == 0 and j == 0) {
                            continue;
                        }
                        if (aroundJ == 2 and j == grid[0].len - 1) {
                            continue;
                        }

                        // std.debug.print("checking {},{}\n", .{ aroundI, aroundJ });
                        if (grid[i + aroundI - 1][j + aroundJ - 1] <= -1) {
                            if (lastAddedNumber != grid[i][j]) {
                                lastAddedNumber = grid[i][j];
                                part1 += lastAddedNumber;
                            }
                        }
                    }
                }
            } else {
                lastAddedNumber = 0;
            }
        }
    }

    var part2: i32 = 0;

    for (0..grid.len) |i| {
        for (0..grid[0].len) |j| {
            if (grid[i][j] == -2) {
                var product: i32 = 1;
                var numOfnums: usize = 0;
                // std.debug.print("Num: {}\n", .{grid[i][j]});
                for (0..3) |aroundI| {
                    var prevGear: i32 = 0;
                    if (aroundI == 0 and i == 0) {
                        continue;
                    }

                    if (aroundI == 2 and i == grid.len - 1) {
                        continue;
                    }

                    // std.debug.print("Checking aroudnI: {}\n", .{aroundI});
                    for (0..3) |aroundJ| {
                        if (aroundI == 1 and aroundJ == 1) {
                            continue;
                        }
                        if (aroundJ == 0 and j == 0) {
                            continue;
                        }
                        if (aroundJ == 2 and j == grid[0].len - 1) {
                            continue;
                        }

                        // std.debug.print("checking {},{}\n", .{ aroundI, aroundJ });
                        if (grid[i + aroundI - 1][j + aroundJ - 1] > 0) {
                            if (prevGear == grid[i + aroundI - 1][j + aroundJ - 1]) {
                                continue;
                            }
                            prevGear = grid[i + aroundI - 1][j + aroundJ - 1];
                            // Found number
                            product *= grid[i + aroundI - 1][j + aroundJ - 1];
                            numOfnums += 1;
                        } else {
                            prevGear = 0;
                        }
                    }
                }
                if (numOfnums == 2) {
                    part2 += product;
                }
            }
        }
    }

    std.debug.print("Part1: {}\n", .{part1});
    std.debug.print("Part2: {}\n", .{part2});
}
