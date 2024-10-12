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
        const child: u128 = c;
        const size: usize = qLength.dequeue().?;
        const paths: []u128 = qPaths.dequeue().?;

        if (child == goal) {
            part1 = size + 1;
            continue;
        }

        const up = child - 1;
        const upX = x(up);
        const upY = y(up);

        const down = child + 1;
        const downX = x(down);
        const downY = y(down);

        const right = child + (@as(u128, 1) << 64);
        const rightX = x(right);
        const rightY = y(right);

        const left = child - (@as(u128, 1) << 64);
        const leftX = x(left);
        const leftY = y(left);

        const lastStep = paths[paths.len - 1];
        const lastStepX = x(lastStep);
        const lastStepY = y(lastStep);
        var l = grid[lastStepY][lastStepX];

        if (part2) {
            l = '.';
        }

        if (grid[upY][upX] != WALL and isStep(l, '^') and !linear_search(paths, up)) {
            var pathsCopy = try allocator.alloc(u128, paths.len + 1);
            short_copy(pathsCopy, paths);
            pathsCopy[pathsCopy.len - 1] = up;

            try q.enqueue(up);
            try qLength.enqueue(size + 1);
            try qPaths.enqueue(pathsCopy);
        }

        if (grid[downY][downX] != WALL and isStep(l, 'v') and !linear_search(paths, down)) {
            var pathsCopy = try allocator.alloc(u128, paths.len + 1);
            short_copy(pathsCopy, paths);
            pathsCopy[pathsCopy.len - 1] = down;

            try q.enqueue(down);
            try qLength.enqueue(size + 1);
            try qPaths.enqueue(pathsCopy);
        }

        if (grid[rightY][rightX] != WALL and isStep(l, '>') and !linear_search(paths, right)) {
            var pathsCopy = try allocator.alloc(u128, paths.len + 1);
            short_copy(pathsCopy, paths);
            pathsCopy[pathsCopy.len - 1] = right;

            try q.enqueue(right);
            try qLength.enqueue(size + 1);
            try qPaths.enqueue(pathsCopy);
        }

        if (grid[leftY][leftX] != WALL and isStep(l, '<') and !linear_search(paths, left)) {
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

const Direction = enum { up, down, right, left };

fn num_of_non_wall(input: *const [][]const u8, coord1: u128, coord2: u128, coord3: u128, coord4: u128) u8 {
    var counter: u8 = 0;

    if (input.*[y(coord1)][x(coord1)] != WALL) {
        counter += 1;
    }
    if (input.*[y(coord2)][x(coord2)] != WALL) {
        counter += 1;
    }
    if (input.*[y(coord3)][x(coord3)] != WALL) {
        counter += 1;
    }
    if (input.*[y(coord4)][x(coord4)] != WALL) {
        counter += 1;
    }

    return counter;
}

fn direction(input: *const [][]const u8, explored: *std.AutoHashMap(u128, bool), up: u128, down: u128, right: u128, left: u128) Direction {
    if (explored.get(up) == null and input.*[y(up)][x(up)] != WALL) {
        return Direction.up;
    }
    if (explored.get(down) == null and input.*[y(down)][x(down)] != WALL) {
        return Direction.down;
    }
    if (explored.get(left) == null and input.*[y(left)][x(left)] != WALL) {
        return Direction.left;
    }
    if (explored.get(right) == null and input.*[y(right)][x(right)] != WALL) {
        return Direction.right;
    }

    unreachable;
}

const Edge = struct { distance: usize, to_x: usize, to_y: usize };

fn compress_graph(allocator: std.mem.Allocator, input: [][]const u8) !std.AutoHashMap(u128, []Edge) {
    var nodes = std.ArrayList(u128).init(allocator);
    defer nodes.deinit();

    for (1..input.len - 1) |y_part| {
        for (1..input[0].len - 1) |x_part| {
            if (input[y_part][x_part] != '.') {
                continue;
            }

            const up = coord(x_part, y_part - 1);
            const down = coord(x_part, y_part + 1);
            const right = coord(x_part + 1, y_part);
            const left = coord(x_part - 1, y_part);

            const non_wall_count = num_of_non_wall(&input, up, down, right, left);
            if (non_wall_count == 0 or non_wall_count == 1) {
                unreachable;
            }

            if (non_wall_count == 2) {
                if (input[y(up)][x(up)] != WALL and input[y(down)][x(down)] != WALL) {
                    continue;
                }

                if (input[y(left)][x(left)] != WALL and input[y(right)][x(right)] != WALL) {
                    continue;
                }
            }

            try nodes.append(coord(x_part, y_part));
        }
    }

    var edges_map = std.AutoHashMap(u128, []Edge).init(allocator);

    for (nodes.items) |a| {
        lower: for (nodes.items) |b| {
            if (a == b) {
                continue;
            }

            if (x(a) == x(b)) {
                // Check they can see each other.
                const min_y = if (y(a) < y(b)) y(a) else y(b);
                const max_y = if (y(a) > y(b)) y(a) else y(b);

                const contains_walls = for (min_y..max_y) |counter_y| {
                    if (input[counter_y][x(a)] == WALL) {
                        break true;
                    }
                } else false;

                if (contains_walls) {
                    continue :lower;
                }

                const new_edge = Edge{ .to_x = x(b), .to_y = y(b), .distance = max_y - min_y };

                if (edges_map.get(a)) |edges_arr| {
                    var new_edges_arr = try allocator.realloc(edges_arr, edges_arr.len + 1);
                    new_edges_arr[new_edges_arr.len - 1] = new_edge;

                    try edges_map.put(a, new_edges_arr);
                } else {
                    var new_edges_arr = try allocator.alloc(Edge, 1);
                    new_edges_arr[0] = new_edge;

                    try edges_map.put(a, new_edges_arr);
                }
            }

            if (y(a) == y(b)) {
                // Check they can see each other.
                const min_x = if (x(a) < x(b)) x(a) else x(b);
                const max_x = if (x(a) > x(b)) x(a) else x(b);

                const contains_walls = for (min_x..max_x) |counter_x| {
                    if (input[y(a)][counter_x] == WALL) {
                        break true;
                    }
                } else false;

                if (contains_walls) {
                    continue :lower;
                }

                const new_edge = Edge{ .to_x = x(b), .to_y = y(b), .distance = max_x - min_x };

                if (edges_map.get(a)) |edges_arr| {
                    var new_edges_arr = try allocator.realloc(edges_arr, edges_arr.len + 1);
                    new_edges_arr[new_edges_arr.len - 1] = new_edge;

                    try edges_map.put(a, new_edges_arr);
                } else {
                    var new_edges_arr = try allocator.alloc(Edge, 1);
                    new_edges_arr[0] = new_edge;

                    try edges_map.put(a, new_edges_arr);
                }
            }
        }
    }

    return edges_map;
}

fn includes(nodes: []u128, node: u128) bool {
    for (nodes) |n| {
        if (n == node) {
            return true;
        }
    }

    return false;
}

fn dfs(allocator: std.mem.Allocator, edges_map: std.AutoHashMap(u128, []Edge), end: u128) !usize {
    var stack = std.ArrayList(u128).init(allocator);
    var stack_distance = std.ArrayList(usize).init(allocator);
    var stack_explored = std.ArrayList([]u128).init(allocator);

    defer stack.deinit();
    defer stack_distance.deinit();
    defer stack_explored.deinit();

    const initial_explored = try allocator.alloc(u128, 0);

    try stack.append(coord(1, 1));
    try stack_distance.append(2);
    try stack_explored.append(initial_explored);

    var longest_distance: usize = 0;

    while (stack.items.len > 0) {
        const popped_node = stack.pop();
        const popped_distance = stack_distance.pop();
        const popped_explored = stack_explored.pop();

        defer allocator.free(popped_explored);

        if (includes(popped_explored, popped_node)) {
            continue;
        }

        if (popped_node == end and popped_distance > longest_distance) {
            longest_distance = popped_distance;
        }

        const edges = edges_map.get(popped_node).?;
        for (edges) |edge| {
            var copied_edges = try allocator.alloc(u128, popped_explored.len + 1);
            std.mem.copyForwards(u128, copied_edges, popped_explored);
            copied_edges[copied_edges.len - 1] = popped_node;

            try stack.append(coord(edge.to_x, edge.to_y));
            try stack_distance.append(popped_distance + edge.distance);
            try stack_explored.append(copied_edges);
        }
    }

    return longest_distance;
}

pub fn solve(input: [][]const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var explored = std.AutoHashMap(u128, bool).init(allocator);

    const start = coord(1, 0);
    try explored.put(start, true);

    const goal = coord(input[0].len - 2, input.len - 2);

    // const part1 = try bfs(input, goal, &explored, fakeStart, allocator, false);
    // print("Part 1: {}\n", .{part1});

    const edges = try compress_graph(allocator, input);
    const part2 = try dfs(allocator, edges, goal);
    print("Part 2: {}\n", .{part2});
}
