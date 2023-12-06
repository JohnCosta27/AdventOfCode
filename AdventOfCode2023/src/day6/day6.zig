const std = @import("std");
const math = std.math;
const print = std.debug.print;

const QuadraticSolution = struct {
    x1: f128,
    x2: f128,
};

const Quadratic = struct {
    a: i128,
    b: i128,
    c: i128,

    pub fn solve(self: Quadratic) QuadraticSolution {
        var discriminent: f128 = @floatFromInt(self.b * self.b - 4 * self.a * self.c);

        var floatA: f128 = @floatFromInt(self.a);
        var floatB: f128 = @floatFromInt(self.b);

        var x_1 = (-floatB + @sqrt(discriminent)) / (2 * floatA);
        var x_2 = (-floatB - @sqrt(discriminent)) / (2 * floatA);

        return QuadraticSolution{
            .x1 = x_1,
            .x2 = x_2,
        };
    }
};

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;

    var timeTokens = std.mem.tokenizeSequence(u8, input[0], " ");
    var distanceTokens = std.mem.tokenizeSequence(u8, input[1], " ");

    _ = timeTokens.next().?;
    _ = distanceTokens.next().?;

    var times = try allocator.alloc(i128, 4);
    var distances = try allocator.alloc(i128, 4);

    times[3] = 0;

    var stringTime = try allocator.alloc(u8, 100);
    var stringDistance = try allocator.alloc(u8, 100);

    defer allocator.free(stringTime);
    defer allocator.free(stringDistance);

    var index: usize = 0;
    var k: usize = 0;
    var j: usize = 0;

    while (timeTokens.next()) |time| {
        for (0..time.len) |_k| {
            stringTime[k] = time[_k];
            k += 1;
        }

        times[index] = try std.fmt.parseInt(i128, time, 10);

        var distance = distanceTokens.next().?;

        for (0..distance.len) |_k| {
            stringDistance[j] = distance[_k];
            j += 1;
        }

        distances[index] = try std.fmt.parseInt(i128, distance, 10);
        index += 1;
    }

    if (times[3] == 0) {
        // example input
        _ = allocator.resize(times, 3);
        _ = allocator.resize(distances, 3);

        var timesCopy = try allocator.alloc(i128, 3);
        var distanceCopy = try allocator.alloc(i128, 3);

        timesCopy[0] = times[0];
        timesCopy[1] = times[1];
        timesCopy[2] = times[2];

        distanceCopy[0] = distances[0];
        distanceCopy[1] = distances[1];
        distanceCopy[2] = distances[2];

        allocator.free(times);
        allocator.free(distances);

        times = timesCopy;
        distances = distanceCopy;
    }

    var part1: u32 = 1;

    for (0..times.len) |i| {
        var quad = Quadratic{ .a = -1, .b = times[i], .c = -distances[i] };
        var solution = quad.solve();
        var start: u32 = @intFromFloat(math.ceil(solution.x1));
        var end: u32 = @intFromFloat(math.floor(solution.x2));

        if (@mod(solution.x2, 1) == 0) {
            end -= 1;
        } else {
            end += 1;
        }

        part1 *= end - start;
    }

    print("Part 1: {}\n", .{part1});

    var part2Time = try std.fmt.parseInt(i128, stringTime[0..k], 10);
    var part2Distance = try std.fmt.parseInt(i128, stringDistance[0..j], 10);

    var quad = Quadratic{ .a = -1, .b = part2Time, .c = -part2Distance };
    var solution = quad.solve();
    var start: usize = @intFromFloat(math.ceil(solution.x1));
    var end: usize = @intFromFloat(math.floor(solution.x2));

    if (@mod(solution.x2, 1) == 0) {
        end -= 1;
    } else {
        end += 1;
    }

    var part2 = end - start;

    print("Part 2: {}\n", .{part2});
}
