const std = @import("std");

const mem = std.mem;
const ArrayList = std.ArrayList;
const expect = std.testing.expect;

const MAX_SIZE = 1_000_000_000;

pub fn split_lines(file_path: []const u8, allocator: mem.Allocator) !ArrayList([]const u8) {
    const file = try std.fs.cwd().openFile(file_path, .{});
    var content = try file.reader().readAllAlloc(allocator, MAX_SIZE);

    var lines = ArrayList([]const u8).init(allocator);
    var iterator = mem.tokenize(u8, content, "\n");

    while (iterator.next()) |line| {
        try lines.append(line);
    }

    return lines;
}

test "Reads file" {
    var test_alloc = std.heap.page_allocator;
    var lines = try split_lines("test.txt", test_alloc);

    defer lines.deinit();

    try expect(lines.items.len == 2);
    try expect(mem.eql(u8, lines.items[0], "hello"));
    try expect(mem.eql(u8, lines.items[1], "world"));
}
