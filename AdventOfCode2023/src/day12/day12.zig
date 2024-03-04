const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

var MEMOIZED: std.StringHashMap(usize) = undefined;

fn rec_solve(allocator: std.mem.Allocator, input: []const u8, config: []u8) !usize {
    var inputConfigArr = [2][]const u8{ input, config };
    var inputConfig = try std.mem.concat(allocator, u8, &inputConfigArr);
    // defer allocator.free(inputConfig);

    if (MEMOIZED.get(inputConfig)) |num| {
        return num;
    }

    if (input.len == 0) {
        if (config.len == 0) {
            return 1;
        }

        return 0;
    }

    if (config.len == 0) {
        var hash = [_]u8{'#'};
        if (std.mem.containsAtLeast(u8, input, 1, &hash)) {
            return 0;
        }

        return 1;
    }

    if (input[0] == '.') {
        var res = try rec_solve(allocator, input[1..], config[0..]);

        try MEMOIZED.put(inputConfig, res);

        return res;
    }

    // If unknown, try both.
    if (input[0] == '?') {
        var dotInput = try allocator.alloc(u8, input.len);
        var hashInput = try allocator.alloc(u8, input.len);

        std.mem.copy(u8, dotInput, input);
        std.mem.copy(u8, hashInput, input);

        dotInput[0] = '.';
        hashInput[0] = '#';

        defer allocator.free(dotInput);
        defer allocator.free(hashInput);

        var res = try rec_solve(allocator, dotInput[0..], config[0..]) + try rec_solve(allocator, hashInput[0..], config[0..]);

        try MEMOIZED.put(inputConfig, res);

        return res;
    }

    // #? -> {1, 1}
    // ### -> {3}

    if (input[0] == '#') {
        var current = config[0];

        // ### -> {3}
        // Not long enough to match
        if (input.len < current) {
            return 0;
        }

        var containsDots = false;
        for (0..current) |i| {
            if (input[i] == '.') {
                containsDots = true;
                break;
            }
        }

        // Doesnt match the current one
        // #.# -> {3}
        if (containsDots) {
            return 0;
        }

        // ### -> {3}
        // ##?. -> {3}
        // [] -> {}

        if (input.len == current) {
            var res = try rec_solve(allocator, "", config[1..]);

            try MEMOIZED.put(inputConfig, res);

            return res;
        }

        if (input[current] == '#') {
            return 0;
        }

        var res = try rec_solve(allocator, input[current + 1 ..], config[1..]);

        try MEMOIZED.put(inputConfig, res);
        return res;
    }

    return 0;
}

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;

    var part1: usize = 0;
    var part2: usize = 0;

    MEMOIZED = std.StringHashMap(usize).init(allocator);

    for (input) |line| {
        var splitIter = std.mem.splitSequence(u8, line, " ");

        var pattern = splitIter.next().?;
        var config = splitIter.next().?;

        var used: usize = 0;
        var numberConfig = try allocator.alloc(u8, 20);

        var commaIter = std.mem.splitSequence(u8, config, ",");
        while (commaIter.next()) |num| {
            numberConfig[used] = try std.fmt.parseInt(u8, num, 10);

            used += 1;
        }

        var fivePattern = std.ArrayList(u8).init(allocator);

        try fivePattern.appendSlice(pattern);
        try fivePattern.append('?');
        try fivePattern.appendSlice(pattern);
        try fivePattern.append('?');
        try fivePattern.appendSlice(pattern);
        try fivePattern.append('?');
        try fivePattern.appendSlice(pattern);
        try fivePattern.append('?');
        try fivePattern.appendSlice(pattern);

        var fiveConfig = std.ArrayList(u8).init(allocator);

        try fiveConfig.appendSlice(numberConfig[0..used]);
        try fiveConfig.appendSlice(numberConfig[0..used]);
        try fiveConfig.appendSlice(numberConfig[0..used]);
        try fiveConfig.appendSlice(numberConfig[0..used]);
        try fiveConfig.appendSlice(numberConfig[0..used]);

        var fivePatternSlice = try fivePattern.toOwnedSlice();
        var fiveConfigSlice = try fiveConfig.toOwnedSlice();

        part1 += try rec_solve(allocator, pattern, numberConfig[0..used]);
        part2 += try rec_solve(allocator, fivePatternSlice, fiveConfigSlice);
    }

    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}

test "Basic easy example" {
    var example1 = "#.#.###";
    var example1Config = [_]u16{ 1, 1, 3 };
    var allocator = std.heap.page_allocator;

    try expect(try rec_solve(allocator, example1, &example1Config) == 1);
}

test "More complicated example" {
    var example1 = "???.###";
    var example1Config = [_]u16{ 1, 1, 3 };
    var allocator = std.heap.page_allocator;

    var res = try rec_solve(allocator, example1, &example1Config);

    print("Result: {}\n", .{res});

    try std.testing.expectEqual(res, 1);
}

test "Even more complex" {
    var example1 = "?###????????";
    var example1Config = [_]u16{ 3, 2, 1 };
    var allocator = std.heap.page_allocator;

    var res = try rec_solve(allocator, example1, &example1Config);

    print("Result: {}\n", .{res});

    try std.testing.expectEqual(res, 10);
}
