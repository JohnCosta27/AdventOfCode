const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;

pub fn getInput(fileName: []const u8, allocator: mem.Allocator) !([][]const u8) {
    const file = try std.fs.cwd().openFile(fileName, .{});
    var content = try file.reader().readAllAlloc(allocator, 999999);

    var lines = ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var iterator = mem.tokenize(u8, content, "\n");

    while (iterator.next()) |line| {
        try lines.append(line);
    }

    var input = try lines.toOwnedSlice();
    return input;
}
