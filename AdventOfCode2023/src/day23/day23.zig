const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

const WALL = '#';

pub fn Queue(comptime Child: type) type {
    return struct {
        const This = @This();
        const Node = struct {
            data: Child,
            next: ?*Node,
        };
        gpa: std.mem.Allocator,
        start: ?*Node,
        end: ?*Node,

        pub fn init(gpa: std.mem.Allocator) This {
            return This{
                .gpa = gpa,
                .start = null,
                .end = null,
            };
        }
        pub fn enqueue(this: *This, value: Child) !void {
            const node = try this.gpa.create(Node);
            node.* = .{ .data = value, .next = null };
            if (this.end) |end| end.next = node //
            else this.start = node;
            this.end = node;
        }
        pub fn dequeue(this: *This) ?Child {
            const start = this.start orelse return null;
            defer this.gpa.destroy(start);
            if (start.next) |next|
                this.start = next
            else {
                this.start = null;
                this.end = null;
            }
            return start.data;
        }
    };
}

test "Hash maps as refs" {
    var allocator = std.heap.page_allocator;

    var q = Queue(*std.AutoHashMap(u128, bool)).init(allocator);
    var m = std.AutoHashMap(u128, bool).init(allocator);

    try m.put(0, true);
    try m.put(1, true);
    try expect(m.count() == 2);

    try q.enqueue(&m);
    var mPointer: *std.AutoHashMap(u128, bool) = q.dequeue().?;

    try expect(mPointer.*.count() == 2);
}

fn coord(myX: usize, myY: usize) u128 {
    return @as(u128, myX) << 64 | @as(u128, myY);
}

fn x(c: u128) usize {
    return @truncate(c >> 64);
}

fn y(c: u128) usize {
    return @truncate(c);
}

fn linear_search(arr: []u128, search: u128) bool {
    for (arr) |i| {
        if (i == search) {
            return true;
        }
    }
    return false;
}

fn short_copy(longerArr: []u128, shorterArr: []u128) void {
    for (0..shorterArr.len) |i| {
        longerArr[i] = shorterArr[i];
    }
}

fn isStep(s: u8, want: u8) bool {
    if (s == '.') {
        return true;
    }

    return want == s;
}

// const Edge = struct {
//     weight: usize,
//     node: *Node,
// };
//
// const Node = struct {
//     edges: []?Edge,
// };

fn bfs(grid: [][]const u8, goal: u128, explored: *std.AutoHashMap(u128, bool), root: u128, allocator: std.mem.Allocator, part2: bool) !usize {
    var q = Queue(u128).init(allocator);
    var qLength = Queue(usize).init(allocator);
    var qPaths = Queue([]u128).init(allocator);

    try explored.*.put(root, true);
    try q.enqueue(root);
    try qLength.enqueue(0);

    var myPaths = try allocator.alloc(u128, 2);

    var keyIter = explored.keyIterator();
    var index: usize = 0;
    while (keyIter.next()) |key| {
        myPaths[index] = key.*;
        index += 1;
    }

    try qPaths.enqueue(myPaths);

    var part1: usize = 0;

    while (q.dequeue()) |c| {
        var child: u128 = c;
        var size: usize = qLength.dequeue().?;
        var paths: []u128 = qPaths.dequeue().?;

        if (child == goal) {
            // don't return, because we need all routes.
            print("Size: {}\n", .{size + 1});
            part1 = size + 1;
            continue;
        }

        var up = child - 1;
        var upX = x(up);
        var upY = y(up);

        var down = child + 1;
        var downX = x(down);
        var downY = y(down);

        var right = child + (@as(u128, 1) << 64);
        var rightX = x(right);
        var rightY = y(right);

        var left = child - (@as(u128, 1) << 64);
        var leftX = x(left);
        var leftY = y(left);

        var lastStep = paths[paths.len - 1];
        var lastStepX = x(lastStep);
        var lastStepY = y(lastStep);
        var l = grid[lastStepY][lastStepX];
        if (part2) {
            l = '.';
        }

        if (!linear_search(paths, up) and grid[upY][upX] != WALL and isStep(l, '^')) {
            var pathsCopy = try allocator.alloc(u128, paths.len + 1);
            short_copy(pathsCopy, paths);
            pathsCopy[pathsCopy.len - 1] = up;

            try q.enqueue(up);
            try qLength.enqueue(size + 1);
            try qPaths.enqueue(pathsCopy);
        }
        if (!linear_search(paths, down) and grid[downY][downX] != WALL and isStep(l, 'v')) {
            var pathsCopy = try allocator.alloc(u128, paths.len + 1);
            short_copy(pathsCopy, paths);
            pathsCopy[pathsCopy.len - 1] = down;

            try q.enqueue(down);
            try qLength.enqueue(size + 1);
            try qPaths.enqueue(pathsCopy);
        }
        if (!linear_search(paths, right) and grid[rightY][rightX] != WALL and isStep(l, '>')) {
            var pathsCopy = try allocator.alloc(u128, paths.len + 1);
            short_copy(pathsCopy, paths);
            pathsCopy[pathsCopy.len - 1] = right;

            try q.enqueue(right);
            try qLength.enqueue(size + 1);
            try qPaths.enqueue(pathsCopy);
        }
        if (!linear_search(paths, left) and grid[leftY][leftX] != WALL and isStep(l, '<')) {
            var pathsCopy = try allocator.alloc(u128, paths.len + 1);
            short_copy(pathsCopy, paths);
            pathsCopy[pathsCopy.len - 1] = left;

            try q.enqueue(left);
            try qLength.enqueue(size + 1);
            try qPaths.enqueue(pathsCopy);
        }

        allocator.free(paths);
    }

    return part1;
}

fn dps(grid: [][]const u8, root: u128, goal: u128, explored: []u128, size: usize, allocator: std.mem.Allocator) !usize {
    if (root == goal) {
        print("Size: {}\n", .{size});
        return size;
    }

    var up = root - 1;
    var down = root + 1;
    var right = root + (@as(u128, 1) << 64);
    var left = root - (@as(u128, 1) << 64);
    var neighbours = [_]u128{ up, down, right, left };

    var highest: usize = 0;

    for (neighbours) |n| {
        var nx = x(n);
        var ny = y(n);
        if (!linear_search(explored, n) and grid[ny][nx] != WALL) {
            var copyExplored = try allocator.alloc(u128, explored.len + 1);
            short_copy(copyExplored, explored);
            copyExplored[copyExplored.len - 1] = n;
            var h = try dps(grid, n, goal, copyExplored, size + 1, allocator);
            if (h > highest) {
                highest = h;
            }

            allocator.free(copyExplored);
        }
    }

    return highest;
}

pub fn solve(input: [][]const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    var explored = std.AutoHashMap(u128, bool).init(allocator);

    var start = coord(1, 0);
    try explored.put(start, true);

    var fakeStart = coord(1, 1);

    var goal = coord(input[0].len - 2, input.len - 1);
    _ = goal;

    // var part1 = try bfs(input, goal, &explored, fakeStart, allocator, false);
    // print("Part 1: {}\n", .{part1});

    // var part2 = try bfs(input, goal, &explored, fakeStart, allocator, true);
    // print("Part 2: {}\n", .{part2});

    var exp = try allocator.alloc(u128, 1);
    exp[0] = start;

    // var exampleLastInter = coord(19, 20);
    var exampleLastInter = coord(133, 137);

    var part2 = try dps(input, fakeStart, exampleLastInter, exp, 0, allocator);
    print("Part 2: {}\n", .{part2 + 21});
}
