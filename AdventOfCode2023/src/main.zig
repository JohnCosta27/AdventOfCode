const std = @import("std");
// const day1 = @import("./day1/day1.zig");
// const day2 = @import("./day2/day2.zig");
// const day3 = @import("./day3/day3.zig");
// const day4 = @import("./day4/day4.zig");
// const day5 = @import("./day5/day5.zig");
// const day6 = @import("./day6/day6.zig");
// const day7 = @import("./day7/day7.zig");
// const day9 = @import("./day9/day9.zig");
// const day10 = @import("./day10/day10.zig");
// const day11 = @import("./day11/day11.zig");
// const day12 = @import("./day12/day12.zig");
const day15 = @import("./day15/day15.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var input = try utils.getInput("./src/day15/input.txt", allocator);
    defer allocator.free(input);

    try day15.solve(input);
}
