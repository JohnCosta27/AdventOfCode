const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;

pub fn getInput(fileName: []const u8, allocator: mem.Allocator) !([][]u8) {
    const file = try std.fs.cwd().openFile(fileName, .{});
    const content = try file.reader().readAllAlloc(allocator, 999999);

    var lines = ArrayList([]u8).init(allocator);
    defer lines.deinit();

    var iterator = mem.split(u8, content, "\n");

    while (iterator.next()) |line| {
        const mutableSlice = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, mutableSlice, line);

        try lines.append(mutableSlice);
    }

    const input = try lines.toOwnedSlice();

    return input[0 .. input.len - 1];
}
