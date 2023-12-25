const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

const Line = struct {
    x: i128,
    y: i128,
    z: i128,

    dx: i128,
    dy: i128,
    dz: i128,

    pub fn isNegative(self: Line) bool {
        if (self.dx < 0 and self.dy < 0) {
            return false;
        }

        return self.dx < 0 or self.dy < 0;
    }

    pub fn time(self: Line, point: f128) f128 {
        var fx: f128 = @floatFromInt(self.x);
        var fdx: f128 = @floatFromInt(self.dx);

        return (point - fx) / fdx;
    }
};

// const LOWER = 7;
// const HIGHER = 27;
const LOWER = 200000000000000;
const HIGHER = 400000000000000;

const Solution = struct {
    x: f128,
    y: f128,
    z: f128,
};

test "Floating points" {
    var a: i128 = 5.123;
    var b: i128 = 5.123;

    try expect(a - b == 0);
}

fn asFloat(a: i128) f128 {
    return @as(f128, @floatFromInt(a));
}

fn linear_algebra_2d(line1: Line, line2: Line) ?Solution {
    var m1: f128 = asFloat(line1.dy) / asFloat(line1.dx);
    var A: f128 = asFloat(line1.y) - m1 * asFloat(line1.x);

    var m2: f128 = asFloat(line2.dy) / asFloat(line2.dx);
    var B: f128 = asFloat(line2.y) - m2 * asFloat(line2.x);

    if (m1 == m2) {
        return null;
    }

    var deltaM = m2 - m1;

    var x = A / deltaM - B / deltaM;
    var y = (A * m2) / deltaM - (B * m1) / deltaM;

    return Solution{ .x = x, .y = y, .z = 0 };
}

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;
    var lines = try allocator.alloc(Line, input.len);

    for (input, 0..) |line, i| {
        var tokenizer = std.mem.tokenizeAny(u8, line, " ,@");
        var x = try std.fmt.parseInt(i128, tokenizer.next().?, 10);
        var y = try std.fmt.parseInt(i128, tokenizer.next().?, 10);
        var z = try std.fmt.parseInt(i128, tokenizer.next().?, 10);

        var dx = try std.fmt.parseInt(i128, tokenizer.next().?, 10);
        var dy = try std.fmt.parseInt(i128, tokenizer.next().?, 10);
        var dz = try std.fmt.parseInt(i128, tokenizer.next().?, 10);

        var l = Line{ .x = x, .y = y, .z = z, .dx = dx, .dy = dy, .dz = dz };
        lines[i] = l;
    }

    var part1: usize = 0;

    for (0..lines.len) |i| {
        for (i + 1..lines.len) |j| {
            var line1 = lines[i];
            var line2 = lines[j];

            var sol = linear_algebra_2d(line1, line2);
            if (sol) |s| {
                if (s.x > LOWER and s.y > LOWER and s.x < HIGHER and s.y < HIGHER) {
                    if (line1.time(s.x) < 0 or line2.time(s.x) < 0) {
                        continue;
                    }

                    part1 += 1;
                }
                continue;
            }
        }
    }

    print("Part 1: {}\n", .{part1});
}
