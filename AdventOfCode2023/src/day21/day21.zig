const std = @import("std");
const print = std.debug.print;

const ROCK = '#';
const START = 'S';
const GARDEN = '.';
const STEPS = 1;
const PART2_STEPS = 50;

fn printGrid(grid: [][]u8) void {
    for (grid) |row| {
        for (row) |c| {
            print("{c}", .{c});
        }
        print("\n", .{});
    }
}

fn coord(x1: usize, y1: usize) u128 {
    return @as(u128, x1) << 64 | @as(u128, y1);
}

fn x(c: u128) usize {
    return @truncate(c >> 64);
}

fn y(c: u128) usize {
    return @truncate(c);
}

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;
    var grid = try allocator.alloc([]u8, input.len + 2);

    for (0..grid.len) |i| {
        grid[i] = try allocator.alloc(u8, input[0].len + 2);
    }

    // Horizontal
    for (0..grid[0].len) |i| {
        grid[0][i] = ROCK;
        grid[grid.len - 1][i] = ROCK;
    }

    // Vertical
    for (0..grid.len) |i| {
        grid[i][0] = ROCK;
        grid[i][grid[0].len - 1] = ROCK;
    }

    for (1..grid.len - 1) |i| {
        for (1..grid[0].len - 1) |j| {
            grid[i][j] = input[i - 1][j - 1];
        }
    }

    var myX: usize = 0;
    var myY: usize = 0;
    outerLoop: for (grid, 0..) |row, i| {
        for (row, 0..) |c, j| {
            if (c == START) {
                myX = j;
                myY = i;
                break :outerLoop;
            }
        }
    }

    var part1: u32 = 0;

    var visited = std.AutoHashMap(u128, bool).init(allocator);
    try visited.put(coord(myX, myY), true);

    var currentSteps = std.ArrayList(u128).init(allocator);
    try currentSteps.append(coord(myX, myY));

    for (0..STEPS) |_| {
        var newCurrentSteps = std.AutoHashMap(u128, bool).init(allocator);
        for (currentSteps.items) |c| {
            var north: u128 = c - 1;
            var northCoordX = x(north);
            var northCoordY = y(north);

            var south: u128 = c + 1;
            var southCoordX = x(south);
            var southCoordY = y(south);

            var west: u128 = c - (@as(u128, 1) << 64);
            var westCoordX = x(west);
            var westCoordY = y(west);

            var east: u128 = c + (@as(u128, 1) << 64);
            var eastCoordX = x(east);
            var eastCoordY = y(east);

            if (grid[northCoordY][northCoordX] != ROCK) {
                try newCurrentSteps.put(north, true);
            }
            if (grid[southCoordY][southCoordX] != ROCK) {
                try newCurrentSteps.put(south, true);
            }
            if (grid[westCoordY][westCoordX] != ROCK) {
                try newCurrentSteps.put(west, true);
            }
            if (grid[eastCoordY][eastCoordX] != ROCK) {
                try newCurrentSteps.put(east, true);
            }
        }

        currentSteps.deinit();
        currentSteps = std.ArrayList(u128).init(allocator);

        var keyIter = newCurrentSteps.keyIterator();
        while (keyIter.next()) |value| {
            try currentSteps.append(value.*);
            try visited.put(value.*, true);
        }

        part1 = newCurrentSteps.count();
        newCurrentSteps.deinit();
    }

    myX = myX + input[0].len * 10_000_000_000;
    myY = myY + input.len * 10_000_000_000;

    var part2: u32 = 0;

    var visitedPart2 = std.AutoHashMap(u128, bool).init(allocator);
    try visitedPart2.put(coord(myX, myY), true);

    var currentStepsPart2 = std.ArrayList(u128).init(allocator);
    try currentStepsPart2.append(coord(myX, myY));

    for (0..PART2_STEPS) |n| {
        if (n % 100000 == 0) {
            print("{}\n", .{n});
        }
        var newCurrentSteps = std.AutoHashMap(u128, bool).init(allocator);
        for (currentStepsPart2.items) |c| {
            var north: u128 = c - 1;
            var northCoordX = x(north) % input[0].len;
            var northCoordY = y(north) % input.len;

            var south: u128 = c + 1;
            var southCoordX = x(south) % input[0].len;
            var southCoordY = y(south) % input.len;

            var west: u128 = c - (@as(u128, 1) << 64);
            var westCoordX = x(west) % input[0].len;
            var westCoordY = y(west) % input.len;

            var east: u128 = c + (@as(u128, 1) << 64);
            var eastCoordX = x(east) % input[0].len;
            var eastCoordY = y(east) % input.len;

            if (grid[northCoordY][northCoordX] != ROCK) {
                print("{} - {},{}\n", .{ north, northCoordX, northCoordY });
                try newCurrentSteps.put(north, true);
            }
            if (grid[southCoordY][southCoordX] != ROCK) {
                try newCurrentSteps.put(south, true);
            }
            if (grid[westCoordY][westCoordX] != ROCK) {
                try newCurrentSteps.put(west, true);
            }
            if (grid[eastCoordY][eastCoordX] != ROCK) {
                try newCurrentSteps.put(east, true);
            }
        }

        currentStepsPart2.deinit();
        currentStepsPart2 = std.ArrayList(u128).init(allocator);

        var keyIter = newCurrentSteps.keyIterator();
        while (keyIter.next()) |value| {
            try currentStepsPart2.append(value.*);
            try visitedPart2.put(value.*, true);
        }

        part2 = newCurrentSteps.count();
        newCurrentSteps.deinit();
    }

    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}
