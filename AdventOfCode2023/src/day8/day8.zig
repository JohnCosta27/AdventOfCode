const std = @import("std");
const print = std.debug.print;

fn gcd(a: usize, b: usize) usize {
    if (b == 0) {
        return a;
    }
    return gcd(b, a % b);
}

fn lcm(a: usize, b: usize) usize {
    return (a / gcd(a, b)) * b;
}

const TreeishNode = struct {
    label: []const u8,
    left: ?(*TreeishNode),
    right: ?(*TreeishNode),
};

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;

    var instructions = input[0];

    var map = input[1..];

    var nodeMap = std.StringHashMap(*TreeishNode).init(allocator);
    defer nodeMap.deinit();

    for (map) |line| {
        var label = line[0..3];

        var node = try allocator.create(TreeishNode);
        node.label = label;
        node.left = undefined;
        node.right = undefined;
        try nodeMap.put(label, node);
    }

    for (map) |line| {
        var label = line[0..3];
        var left = line[7..10];
        var right = line[12..15];

        var labelNode = nodeMap.get(label).?;
        var leftNode = nodeMap.get(left).?;
        var rightNode = nodeMap.get(right).?;

        labelNode.*.left = leftNode;
        labelNode.*.right = rightNode;
    }

    // var starting: []const u8 = "AAA";
    // var part1: usize = 0;
    //
    // while (!std.mem.eql(u8, starting, "ZZZ")) {
    //     for (instructions) |letter| {
    //         part1 += 1;
    //         var current = nodeMap.get(starting).?;
    //         if (letter == 'R') {
    //             starting = current.*.right.?.label;
    //         } else {
    //             starting = current.*.left.?.label;
    //         }
    //     }
    // }

    var startingPaths = std.ArrayList([]const u8).init(allocator);
    var pathLength = std.ArrayList(usize).init(allocator);

    defer startingPaths.deinit();
    defer pathLength.deinit();

    var iter = nodeMap.keyIterator();
    while (iter.next()) |key| {
        if (key.*[2] == 'A') {
            try startingPaths.append(key.*);
        }
    }

    for (startingPaths.items) |path| {
        var s: []const u8 = path;
        var length: usize = 0;

        while (s[2] != 'Z') {
            for (instructions) |letter| {
                length += 1;
                var current = nodeMap.get(s).?;
                if (letter == 'R') {
                    s = current.*.right.?.label;
                } else {
                    s = current.*.left.?.label;
                }
            }
        }

        try pathLength.append(length);
    }

    var lengths = try pathLength.toOwnedSlice();
    print("{any}\n", .{lengths});

    var part2 = lcm(lengths[0], lengths[1]);
    for (2..lengths.len) |n| {
        part2 = lcm(part2, lengths[n]);
    }

    // print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}
