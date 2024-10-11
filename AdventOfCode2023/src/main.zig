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
// const day = @import("./day12/day12.zig");
// const day14 = @import("./day14/day14.zig");
// const day13 = @import("./day13/day13.zig");
// const day15 = @import("./day15/day15.zig");
// const day16 = @import("./day16/day16.zig");
// const day17 = @import("./day17/day17.zig");
// const day18 = @import("./day18/day18.zig");
// const day19 = @import("./day19/day19.zig");
// const day20 = @import("./day20/day20.zig");
// const day21 = @import("./day21/day21.zig");
const day22 = @import("./day22/day22.zig");
// const day23 = @import("./day23/day23.zig");
// const day24 = @import("./day24/day24.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const input = try utils.getInput("./src/day22/input.txt", allocator);
    defer allocator.free(input);

    try day22.solve(input);
}
