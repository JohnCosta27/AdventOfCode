const std = @import("std");
// const day1 = @import("./day1/day1.zig");
// const day2 = @import("./day2/day2.zig");
// const day3 = @import("./day3/day3.zig");
// const day4 = @import("./day4/day4.zig");
// const day5 = @import("./day5/day5.zig");
const day6 = @import("./day6/day6.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var input = try utils.getInput("./src/day6/input.txt", allocator);
    defer allocator.free(input);

    try day6.solve(input);
}
