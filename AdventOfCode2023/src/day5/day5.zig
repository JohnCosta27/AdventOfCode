const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const expect = std.testing.expect;

const Range = struct {
    sourceStart: usize,
    destinationStart: usize,
    rangeLength: usize,

    pub fn fits(self: Range, input: usize) bool {
        return input >= self.sourceStart and input < self.sourceStart + self.rangeLength;
    }

    pub fn compute(self: Range, input: usize) usize {
        if (self.fits(input)) {
            var distanceFromStart = input - self.sourceStart;
            return self.destinationStart + distanceFromStart;
        }
        return input;
    }

    pub fn prettyPrint(self: Range) void {
        print("Start: {} | Destination Start: {} | Length: {}\n", .{ self.sourceStart, self.destinationStart, self.rangeLength });
    }
};

test "Test range" {
    var range = Range{ .sourceStart = 50, .destinationStart = 98, .rangeLength = 2 };
    try expect(range.compute(49) == 49);
    try expect(range.compute(50) == 98);
    try expect(range.compute(51) == 99);
    try expect(range.compute(52) == 52);

    try expect(range.fits(51));

    var otherRange = Range{ .sourceStart = 18, .destinationStart = 25, .rangeLength = 70 };
    try expect(otherRange.fits(40));
}

fn getSeeds(input: [][]const u8) ![]usize {
    var allocator = std.heap.page_allocator;

    var seedsLine = input[0][7..];
    var seedNumbers = std.mem.tokenizeSequence(u8, seedsLine, " ");
    var seedsList = ArrayList(usize).init(allocator);
    defer seedsList.deinit();

    while (seedNumbers.next()) |num| {
        try seedsList.append(try std.fmt.parseInt(usize, num, 10));
    }

    var seeds = try seedsList.toOwnedSlice();
    return seeds;
}

fn parseRange(line: []const u8, reverse: bool) !Range {
    var seedNumbers = std.mem.tokenizeSequence(u8, line, " ");
    var destinationStart = try std.fmt.parseInt(usize, seedNumbers.next().?, 10);
    var sourceStart = try std.fmt.parseInt(usize, seedNumbers.next().?, 10);
    var rangeLength = try std.fmt.parseInt(usize, seedNumbers.next().?, 10);
    if (reverse) {
        return Range{ .sourceStart = destinationStart, .destinationStart = sourceStart, .rangeLength = rangeLength };
    }
    return Range{ .sourceStart = sourceStart, .destinationStart = destinationStart, .rangeLength = rangeLength };
}

fn traverseMaps(maps: [7]*ArrayList(Range), input: usize) usize {
    var mappedValue = input;
    for (maps) |map| {
        // print("Mapped value: {}\n", .{mappedValue});
        for (map.*.items) |range| {
            if (range.fits(mappedValue)) {
                mappedValue = range.compute(mappedValue);
                break;
            }
        }
    }
    return mappedValue;
}

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;

    var seeds = try getSeeds(input);

    var seedToSoil = ArrayList(Range).init(allocator);
    var soilToFert = ArrayList(Range).init(allocator);
    var fertToWater = ArrayList(Range).init(allocator);
    var waterToLight = ArrayList(Range).init(allocator);
    var lightToTemp = ArrayList(Range).init(allocator);
    var tempToHumid = ArrayList(Range).init(allocator);
    var humidToLocation = ArrayList(Range).init(allocator);

    var locationToHumid = ArrayList(Range).init(allocator);
    var humidToTemp = ArrayList(Range).init(allocator);
    var tempToLight = ArrayList(Range).init(allocator);
    var lightToWater = ArrayList(Range).init(allocator);
    var waterToFert = ArrayList(Range).init(allocator);
    var fertToSoil = ArrayList(Range).init(allocator);
    var soilToSeed = ArrayList(Range).init(allocator);

    var maps = [7]*ArrayList(Range){ &seedToSoil, &soilToFert, &fertToWater, &waterToLight, &lightToTemp, &tempToHumid, &humidToLocation };

    var reverseMaps = [7]*ArrayList(Range){ &locationToHumid, &humidToTemp, &tempToLight, &lightToWater, &waterToFert, &fertToSoil, &soilToSeed };

    defer seedToSoil.deinit();
    defer soilToFert.deinit();
    defer fertToWater.deinit();
    defer waterToLight.deinit();
    defer lightToTemp.deinit();
    defer tempToHumid.deinit();
    defer humidToLocation.deinit();

    defer locationToHumid.deinit();
    defer humidToTemp.deinit();
    defer tempToLight.deinit();
    defer lightToWater.deinit();
    defer waterToFert.deinit();
    defer fertToSoil.deinit();
    defer soilToSeed.deinit();

    var index: usize = 2;
    var stages: usize = 0;

    while (index < input.len) {
        var line = input[index];

        if (line[0] < '0' or line[0] > '9') {
            stages += 1;
            index += 1;
            continue;
        }

        var range = try parseRange(line, false);
        var reverseRange = try parseRange(line, true);

        if (stages == 0) {
            try seedToSoil.append(range);
            try soilToSeed.append(reverseRange);
        } else if (stages == 1) {
            try soilToFert.append(range);
            try fertToSoil.append(reverseRange);
        } else if (stages == 2) {
            try fertToWater.append(range);
            try waterToFert.append(reverseRange);
        } else if (stages == 3) {
            try waterToLight.append(range);
            try lightToWater.append(reverseRange);
        } else if (stages == 4) {
            try lightToTemp.append(range);
            try tempToLight.append(reverseRange);
        } else if (stages == 5) {
            try tempToHumid.append(range);
            try humidToTemp.append(reverseRange);
        } else if (stages == 6) {
            try humidToLocation.append(range);
            try locationToHumid.append(reverseRange);
        }

        index += 1;
    }

    var lowest: usize = 999999999999;
    var lowestSeed: usize = 0;

    for (seeds) |seed| {
        var location = traverseMaps(maps, seed);
        if (location < lowest) {
            lowest = location;
            lowestSeed = seed;
        }
    }

    print("Part 1: {} | Seed: {}\n", .{ lowest, lowestSeed });

    var part2: usize = 1;
    outerLoop: while (true) {
        var seed = traverseMaps(reverseMaps, part2);
        var i: usize = 0;
        while (i <= seeds.len / 2) {
            if (seeds[i] <= seed and seeds[i] + seeds[i + 1] > seed) {
                break :outerLoop;
            }
            i += 2;
        }

        if (part2 % 10_000_000 == 0) {
            print("Counting: {}\n", .{part2});
        }

        part2 += 1;
    }
    print("Part 2: {}\n", .{part2});
}
