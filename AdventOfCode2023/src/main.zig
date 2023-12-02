const std = @import("std");
// const day1 = @import("./day1/day1.zig");
const day2 = @import("./day2/day2.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var input = try utils.getInput("./src/day2/input.txt", allocator);
    defer allocator.free(input);

    try day2.solve(input);
}
