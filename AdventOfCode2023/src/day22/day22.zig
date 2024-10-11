const std = @import("std");

const print = std.debug.print;
const expect = std.testing.expect;

const Node = struct {
    index: usize,
    leaf: []Node,

    pub fn pretty_print(self: Node, indent: usize) void {
        for (0..indent) |_| {
            print(" ", .{});
        }

        print("-> {}\n", .{self.index});
        for (self.leaf) |leaf| {
            leaf.pretty_print(indent + 1);
        }
    }
};

const Brick = struct {
    min_x: usize,
    min_y: usize,
    min_z: usize,

    max_x: usize,
    max_y: usize,
    max_z: usize,

    supported_by: []usize,
    supports: []usize,

    pub fn create(x1: usize, y1: usize, z1: usize, x2: usize, y2: usize, z2: usize) Brick {
        const min_x = if (x1 > x2) x2 else x1;
        const min_y = if (y1 > y2) y2 else y1;
        const min_z = if (z1 > z2) z2 else z1;

        const max_x = if (x1 < x2) x2 else x1;
        const max_y = if (y1 < y2) y2 else y1;
        const max_z = if (z1 < z2) z2 else z1;

        return Brick{ .supported_by = &[_]usize{}, .supports = &[_]usize{}, .min_x = min_x, .min_y = min_y, .min_z = min_z, .max_x = max_x, .max_y = max_y, .max_z = max_z };
    }

    pub fn deinit(self: Brick) void {
        self.supports.deinit();
        self.supported_by.deinit();
    }

    pub fn overlaps(self: Brick, other: Brick) bool {
        if (self.min_x > other.max_x or other.min_x > self.max_x) {
            return false;
        }

        if (self.min_y > other.max_y or other.min_y > self.max_y) {
            return false;
        }

        return true;
    }

    pub fn is_above(self: Brick, other: Brick) bool {
        return self.min_z > other.max_z;
    }

    /// Is self right above other.
    pub fn is_right_above(self: Brick, other: Brick) bool {
        return self.min_z == other.max_z + 1;
    }
};

fn compareBricks(_: void, brick1: Brick, brick2: Brick) bool {
    return brick1.min_z < brick2.min_z;
}

fn is_something_below(bricks: []Brick, brick: Brick, current_index: usize) bool {
    if (brick.min_z == 1) {
        // The floor is below us.
        return true;
    }

    for (bricks, 0..) |other_brick, index| {
        if (index == current_index) {
            continue;
        }

        if (!brick.is_above(other_brick)) {
            continue;
        }

        if (brick.overlaps(other_brick) and brick.is_right_above(other_brick)) {
            return true;
        }
    }

    return false;
}

fn doesnt_causes_falling(bricks: []Brick, brick: Brick) bool {
    return for (brick.supports) |brick_supporting_index| {
        const supported_brick = bricks[brick_supporting_index];

        if (supported_brick.supported_by.len == 1) {
            break false;
        }
    } else true;
}

fn count(counted_bricks: *std.AutoHashMap(usize, bool), bricks: []Brick, brick_index: usize) usize {
    var c: usize = 0;

    counted_bricks.put(brick_index, true) catch unreachable;

    for (bricks[brick_index].supports) |supported_brick_index| {
        if (counted_bricks.get(supported_brick_index) != null) {
            continue;
        }

        const all_in_map = for (bricks[supported_brick_index].supported_by) |supported_by_index| {
            if (counted_bricks.get(supported_by_index) == null) {
                break false;
            }
        } else true;

        if (!all_in_map) {
            continue;
        }

        counted_bricks.put(supported_brick_index, true) catch unreachable;

        c += 1 + count(counted_bricks, bricks, supported_brick_index);
    }

    return c;
}

pub fn solve(input: [][]const u8) !void {
    const allocator = std.heap.page_allocator;

    var bricks = try allocator.alloc(Brick, input.len);
    defer allocator.free(bricks);

    for (0..bricks.len) |index| {
        const tilda_index: usize = for (input[index], 0..) |c, c_index| {
            if (c == '~') {
                break c_index;
            }
        } else unreachable;

        const first_coord = input[index][0..tilda_index];
        const second_coord = input[index][tilda_index + 1 ..];

        var first_comma_tokenizer = std.mem.tokenizeSequence(u8, first_coord, ",");

        const x1 = try std.fmt.parseInt(usize, first_comma_tokenizer.next().?, 10);
        const y1 = try std.fmt.parseInt(usize, first_comma_tokenizer.next().?, 10);
        const z1 = try std.fmt.parseInt(usize, first_comma_tokenizer.next().?, 10);

        var second_comma_tokenizer = std.mem.tokenizeSequence(u8, second_coord, ",");

        const x2 = try std.fmt.parseInt(usize, second_comma_tokenizer.next().?, 10);
        const y2 = try std.fmt.parseInt(usize, second_comma_tokenizer.next().?, 10);
        const z2 = try std.fmt.parseInt(usize, second_comma_tokenizer.next().?, 10);

        bricks[index] = Brick.create(x1, y1, z1, x2, y2, z2);
    }

    std.mem.sort(Brick, bricks, {}, comptime compareBricks);

    var fallen_bricks = try allocator.alloc(Brick, bricks.len);

    for (bricks, 0..) |brick, brick_index| {
        var working_brick = brick;

        while (!is_something_below(fallen_bricks, working_brick, brick_index)) {
            working_brick.min_z -= 1;
            working_brick.max_z -= 1;
        }

        fallen_bricks[brick_index] = working_brick;
    }

    for (0..fallen_bricks.len) |brick_index| {
        for (brick_index + 1..fallen_bricks.len) |other_brick_index| {
            var brick = fallen_bricks[brick_index];
            var other_brick = fallen_bricks[other_brick_index];

            if (!brick.overlaps(other_brick)) {
                continue;
            }

            if (!other_brick.is_right_above(brick)) {
                continue;
            }

            other_brick.supported_by = try allocator.realloc(other_brick.supported_by, other_brick.supported_by.len + 1);
            brick.supports = try allocator.realloc(brick.supports, brick.supports.len + 1);

            other_brick.supported_by[other_brick.supported_by.len - 1] = brick_index;
            brick.supports[brick.supports.len - 1] = other_brick_index;

            fallen_bricks[brick_index] = brick;
            fallen_bricks[other_brick_index] = other_brick;
        }
    }

    var part1: usize = 0;

    for (fallen_bricks) |brick| {
        if (brick.supports.len == 0) {
            part1 += 1;
            continue;
        }

        if (doesnt_causes_falling(fallen_bricks, brick)) {
            part1 += 1;
        }
    }

    var part2: usize = 0;

    for (fallen_bricks, 0..) |brick, index| {
        if (doesnt_causes_falling(fallen_bricks, brick)) {
            continue;
        }

        var used_bricks = std.AutoHashMap(usize, bool).init(allocator);
        defer used_bricks.deinit();

        part2 += count(&used_bricks, fallen_bricks, index);
    }

    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}

test "Bricks overlap" {
    const brick1 = Brick{ .supported_by = undefined, .supports = undefined, .min_x = 0, .min_y = 0, .min_z = 0, .max_x = 3, .max_y = 3, .max_z = 3 };
    const brick2 = Brick{ .supported_by = undefined, .supports = undefined, .min_x = 1, .min_y = 1, .min_z = 1, .max_x = 2, .max_y = 2, .max_z = 2 };

    try expect(brick1.overlaps(brick2));
}

test "Bricks dont overlap" {
    const brick1 = Brick{ .supported_by = undefined, .supports = undefined, .min_x = 0, .min_y = 0, .min_z = 0, .max_x = 3, .max_y = 3, .max_z = 3 };
    const brick2 = Brick{ .supported_by = undefined, .supports = undefined, .min_x = 1, .min_y = 10, .min_z = 1, .max_x = 2, .max_y = 20, .max_z = 2 };

    try expect(!brick1.overlaps(brick2));

    const brick3 = Brick{
        .supported_by = undefined,
        .supports = undefined,
        .min_x = 0,
        .min_y = 0,
        .min_z = 2,
        .max_x = 2,
        .max_y = 0,
        .max_z = 2,
    };

    const brick4 = Brick{
        .supported_by = undefined,
        .supports = undefined,
        .min_x = 0,
        .min_y = 2,
        .min_z = 3,
        .max_x = 2,
        .max_y = 2,
        .max_z = 3,
    };

    try expect(!brick3.overlaps(brick4));
    try expect(!brick4.overlaps(brick3));
}
