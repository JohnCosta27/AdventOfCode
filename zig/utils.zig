const std = @import("std");

const mem = std.mem;
const ArrayList = std.ArrayList;
const expect = std.testing.expect;

const MAX_SIZE = 1_000_000_000;

//
// Takes an input file path, and returns a list with
// the lines split by new line '\n'
//
pub fn splitLines(file_path: []const u8, allocator: mem.Allocator) !ArrayList([]const u8) {
    const file = try std.fs.cwd().openFile(file_path, .{});
    var content = try file.reader().readAllAlloc(allocator, MAX_SIZE);

    var lines = ArrayList([]const u8).init(allocator);
    var iterator = mem.tokenize(u8, content, "\n");

    while (iterator.next()) |line| {
        try lines.append(line);
    }

    return lines;
}

//
// Returns a slice the same size as `strings`
// Can return an error if there's parsing issues with the string to int.
//
pub fn stringsToInt(strings: ArrayList([]const u8), allocator: mem.Allocator, base: u8) ![]i64 {
    var ints = try allocator.alloc(i64, strings.items.len);
    for (0..strings.items.len) |index| {
        ints[index] = try std.fmt.parseInt(i64, strings.items[index], base);
    }
    return ints;
}

test "Reads file" {
    var test_alloc = std.heap.page_allocator;
    var lines = try splitLines("test.txt", test_alloc);

    defer lines.deinit();

    try expect(lines.items.len == 2);
    try expect(mem.eql(u8, lines.items[0], "hello"));
    try expect(mem.eql(u8, lines.items[1], "world"));
}

test "Takes strings into ints" {
    var test_alloc = std.heap.page_allocator;
    var stringList = ArrayList([]const u8).init(test_alloc);
    defer stringList.deinit();

    try stringList.append("10");
    try stringList.append("12");
    try stringList.append("987");

    var nums = try stringsToInt(stringList, test_alloc, 10);

    try expect(nums.len == 3);
    try expect(nums[0] == 10);
    try expect(nums[1] == 12);
    try expect(nums[2] == 987);
}
