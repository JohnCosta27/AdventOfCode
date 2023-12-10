const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

fn isAllZeroes(nums: []i128) bool {
    for (nums) |n| {
        if (n != 0) {
            return false;
        }
    }
    return true;
}

fn nextNum(allocator: std.mem.Allocator, nums: []i128) !i128 {
    if (isAllZeroes(nums)) {
        return 0;
    }

    var diff = try allocator.alloc(i128, nums.len - 1);
    for (0..nums.len - 1) |n| {
        var d = nums[n + 1] - nums[n];
        diff[n] = d;
    }

    return nums[nums.len - 1] + try nextNum(allocator, diff);
}

test "Next num finder" {
    var allocator = std.heap.page_allocator;
    var nums = [_]i128{ 0, 3, 6, 9, 12, 15 };
    try expect(try nextNum(allocator, nums[0..]) == 18);

    var nums2 = [_]i128{ 1, 3, 6, 10, 15, 21 };
    try expect(try nextNum(allocator, nums2[0..]) == 28);

    var nums3 = [_]i128{ 10, 13, 16, 21, 30, 45 };
    try expect(try nextNum(allocator, nums3[0..]) == 68);
}

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;
    var part1: i128 = 0;
    var part2: i128 = 0;

    for (input) |line| {
        var list = std.ArrayList(i128).init(allocator);
        var tokenizer = std.mem.tokenizeSequence(u8, line, " ");
        while (tokenizer.next()) |n| {
            try list.append(try std.fmt.parseInt(i128, n, 10));
        }

        var n1 = try nextNum(allocator, list.items);

        std.mem.reverse(i128, list.items);

        var n2 = try nextNum(allocator, list.items);

        part1 += n1;
        part2 += n2;

        list.deinit();
    }

    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}
