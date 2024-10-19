const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

const ArrayList = std.ArrayList;
const Map = std.AutoHashMap;

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

fn print_coord(c: u128, before: []const u8) void {
    print("{s}{},{}\n", .{ before, y(c) + 1, x(c) + 1 });
}

fn arraylist_contains(list: *std.ArrayList(u128), node: u128) bool {
    for (list.items) |item| {
        if (item == node) {
            return true;
        }
    }

    return false;
}

const Edge = struct { distance: usize, to_x: usize, to_y: usize };
const State = struct {
    node: u128,
    distance: usize,
    previous_node: u128,
};

fn is_explored(explored: ArrayList(u128), c: u128) bool {
    for (explored.items) |item| {
        if (item == c) {
            return true;
        }
    }

    return false;
}

const XY = struct { x: i64, y: i64 };

const directions: [4]XY = .{
    XY{ .x = 0, .y = -1 }, // up
    XY{ .x = 0, .y = 1 }, // down
    XY{ .x = -1, .y = 0 }, // left
    XY{ .x = 1, .y = 0 }, // right
};

fn adjacent_steps(input: *const [][]const u8, c: u128) usize {
    var count: usize = 0;

    const signed_x: i64 = @intCast(x(c));
    const signed_y: i64 = @intCast(y(c));

    inline for (directions) |d| {
        const new_x: usize = @intCast(signed_x + d.x);
        const new_y: usize = @intCast(signed_y + d.y);

        if (input.*[new_y][new_x] != WALL) {
            count += 1;
        }
    }

    return count;
}

fn copy_arraylist(allocator: std.mem.Allocator, source: ArrayList(u128)) !ArrayList(u128) {
    var new_list = ArrayList(u128).init(allocator);

    for (source.items) |item| {
        try new_list.append(item);
    }

    return new_list;
}

///
/// DFS over the uncompressed graph, but without a target node, so our
/// code runs over every part of the graph.
///
/// When you meet a co-ordinate you've been to, you must be at a intersection,
/// and can create a node, and add an edge.
///
fn compress_graph_v2(allocator: std.mem.Allocator, start: u128, goal: u128, exclude: u128, input: [][]const u8) !Map(u128, []Edge) {
    var nodes = Map(u128, ArrayList(Edge)).init(allocator);
    try nodes.put(start, ArrayList(Edge).init(allocator));
    defer nodes.deinit();

    var stack = ArrayList(State).init(allocator);
    defer stack.deinit();

    try stack.append(State{
        .node = start,
        .previous_node = start,
        .distance = 0,
    });

    var explored = ArrayList(u128).init(allocator);
    defer explored.deinit();

    while (stack.popOrNull()) |state| {
        const node = state.node;
        var distance = state.distance;
        var previous_node = state.previous_node;

        if (node == exclude or node == coord(1, 0)) {
            continue;
        }

        // print("Exploring: {},{}\n", .{ y(node) + 1, x(node) + 1 });

        const node_x: i64 = @intCast(x(node));
        const node_y: i64 = @intCast(y(node));

        if ((adjacent_steps(&input, node) >= 3 and node != previous_node) or node == goal) {
            // print("Found new graph node! {},{} | Prev: {},{}\n", .{ y(node) + 1, x(node) + 1, y(previous_node) + 1, x(previous_node) + 1 });
            var edges = nodes.get(previous_node).?;
            try edges.append(Edge{
                .to_x = @intCast(node_x),
                .to_y = @intCast(node_y),
                .distance = distance,
            });
            try nodes.put(previous_node, edges);

            if (nodes.get(node) == null) {
                try nodes.put(node, ArrayList(Edge).init(allocator));
            }

            distance = 0;
            previous_node = node;
        }

        if (is_explored(explored, node)) {
            continue;
        }

        try explored.append(node);

        inline for (directions) |d| {
            const new_x: usize = @intCast(node_x + d.x);
            const new_y: usize = @intCast(node_y + d.y);
            const new_coord = coord(new_x, new_y);

            if (input[new_y][new_x] != WALL) {
                try stack.append(State{
                    .distance = distance + 1,
                    .node = new_coord,
                    .previous_node = previous_node,
                });
            }
        }
    }

    var solid_nodes = Map(u128, []Edge).init(allocator);

    var nodes_iterator = nodes.iterator();

    while (nodes_iterator.next()) |entry| {
        const node = entry.key_ptr.*;
        const edges = entry.value_ptr.*;

        var expanded_edges = ArrayList(Edge).init(allocator);
        for (edges.items) |edge| {
            try expanded_edges.append(edge);
        }

        var inner_iterator = nodes.iterator();
        while (inner_iterator.next()) |inner_entry| {
            const inner_node = inner_entry.key_ptr.*;
            const inner_edges = inner_entry.value_ptr.*;

            if (inner_node == node) {
                continue;
            }

            for (inner_edges.items) |edge| {
                if (coord(edge.to_x, edge.to_y) == node) {
                    try expanded_edges.append(Edge{
                        .to_x = x(inner_node),
                        .to_y = y(inner_node),
                        .distance = edge.distance,
                    });
                }
            }
        }

        try solid_nodes.put(node, try expanded_edges.toOwnedSlice());
    }

    return solid_nodes;
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

        if (popped_node == end and popped_distance > longest_distance) {
            longest_distance = popped_distance;
            print("Longest so far: {}\n", .{longest_distance});
        }

        // print("{},{}\n", .{ y(popped_node) + 1, x(popped_node) + 1 });
        // print("Distance: {}\n", .{popped_distance});

        const edges = edges_map.get(popped_node).?;
        for (edges) |edge| {
            if (includes(popped_explored, coord(edge.to_x, edge.to_y))) {
                continue;
            }

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

    const start = coord(1, 1);
    try explored.put(start, true);

    const goal = coord(input[0].len - 2, input.len - 2);
    const real_goal = coord(input[0].len - 2, input.len - 1);

    // const part1 = try bfs(input, goal, &explored, fakeStart, allocator, false);
    // print("Part 1: {}\n", .{part1});

    var edges = try compress_graph_v2(allocator, start, goal, real_goal, input);
    defer edges.deinit();

    //var edges_iter = edges.iterator();
    //while (edges_iter.next()) |entry| {
    //print("({},{})\n", .{ y(entry.key_ptr.*) + 1, x(entry.key_ptr.*) + 1 });

    //for (entry.value_ptr.*) |edge| {
    //print(" -> ({},{}) | {}\n", .{ edge.to_y + 1, edge.to_x + 1, edge.distance });
    //}
    //}

    print("Starting longest path\n", .{});
    const part2 = try dfs(allocator, edges, goal);
    print("Part 2: {}\n", .{part2});
}
