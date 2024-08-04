const graph = @import("../graph/graph.zig");
const std = @import("std");

const print = std.debug.print;

fn coord(myX: usize, myY: usize) u128 {
    return @as(u128, myX) << 64 | @as(u128, myY);
}

const Coord = struct { x: usize, y: usize };

fn from_coord(c: u128) Coord {
    const x: usize = @truncate(c >> 64);
    const y: usize = @truncate(c);

    return Coord{ .x = x, .y = y };
}

const MAX_STRAIGHT_LINE_MOVE = 3;

fn create_nodes(allocator: std.mem.Allocator, input: [][]const u8, label: []const u8) !std.AutoHashMap(u128, *graph.Node) {
    var node_map = std.AutoHashMap(u128, *graph.Node).init(allocator);

    for (0..input.len) |y| {
        for (0..input[0].len) |x| {
            const c = coord(x, y);

            const node = try allocator.create(graph.Node);
            node.label = label;
            node.work_distance = 0;
            node.out_edges = undefined;

            try node_map.put(c, node);
        }
    }

    return node_map;
}

pub fn solve(input: [][]const u8) !void {
    const allocator = std.heap.page_allocator;

    var h_map = try create_nodes(allocator, input, "h-node");
    var v_map = try create_nodes(allocator, input, "v-node");

    var clean_h_map = std.AutoHashMap(u128, *graph.Node).init(allocator);
    var clean_v_map = std.AutoHashMap(u128, *graph.Node).init(allocator);

    var h_map_iter = h_map.iterator();
    while (h_map_iter.next()) |entry| {
        const map_c = entry.key_ptr.*;
        const h_node = entry.value_ptr.*;

        const c = from_coord(map_c);

        var y = c.y;
        var counter: usize = MAX_STRAIGHT_LINE_MOVE;

        var edge_array = std.ArrayList(graph.Edge).init(allocator);

        var accumulated_distance: usize = 0;

        while (counter > 0) : (counter -= 1) {
            if (y == 0) {
                break;
            }

            const edge_out_coord = coord(c.x, y);
            const out_node = v_map.get(edge_out_coord).?;

            accumulated_distance += input[y][c.x] - '0';

            const edge = graph.Edge{ .in_node = h_node, .out_node = out_node, .distance = accumulated_distance };
            try edge_array.append(edge);

            y -= 1;
        }

        y = c.y;
        counter = MAX_STRAIGHT_LINE_MOVE;
        accumulated_distance = 0;

        while (counter > 0) : (counter -= 1) {
            if (y == input.len - 1) {
                break;
            }

            const edge_out_coord = coord(c.x, y);
            const out_node = v_map.get(edge_out_coord).?;

            accumulated_distance += input[y][c.x] - '0';

            const edge = graph.Edge{ .in_node = h_node, .out_node = out_node, .distance = accumulated_distance };
            try edge_array.append(edge);

            y += 1;
        }

        h_node.out_edges = try edge_array.toOwnedSlice();
        try clean_h_map.put(map_c, h_node);
    }

    h_map.deinit();

    var v_map_iter = v_map.iterator();
    while (v_map_iter.next()) |entry| {
        const map_c = entry.key_ptr.*;
        const v_node = entry.value_ptr.*;

        const c = from_coord(map_c);

        var x = c.x;
        var counter: usize = MAX_STRAIGHT_LINE_MOVE;

        var edge_array = std.ArrayList(graph.Edge).init(allocator);
        var accumulated_distance: usize = 0;

        while (counter > 0) : (counter -= 1) {
            if (x == 0) {
                break;
            }

            const edge_out_coord = coord(x, c.y);
            const out_node = clean_h_map.get(edge_out_coord).?;

            accumulated_distance += input[c.y][x] - '0';

            const edge = graph.Edge{ .in_node = v_node, .out_node = out_node, .distance = accumulated_distance };
            try edge_array.append(edge);

            x -= 1;
        }

        x = c.x;
        counter = MAX_STRAIGHT_LINE_MOVE;
        accumulated_distance = 0;

        while (counter > 0) : (counter -= 1) {
            if (x == input[0].len - 1) {
                break;
            }

            const edge_out_coord = coord(x, c.y);
            const out_node = clean_h_map.get(edge_out_coord).?;

            accumulated_distance += input[c.y][x] - '0';

            const edge = graph.Edge{ .in_node = v_node, .out_node = out_node, .distance = accumulated_distance };
            try edge_array.append(edge);

            x += 1;
        }

        v_node.out_edges = try edge_array.toOwnedSlice();
        try clean_v_map.put(map_c, v_node);
    }

    v_map.deinit();

    var all_nodes = try allocator.alloc(*graph.Node, input.len * input[0].len * 2);
    var index: usize = 0;

    var node_iter = clean_h_map.valueIterator();
    while (node_iter.next()) |n| {
        all_nodes[index] = n.*;
        index += 1;
    }

    node_iter = clean_v_map.valueIterator();
    while (node_iter.next()) |n| {
        all_nodes[index] = n.*;
        index += 1;
    }

    const g = graph.Graph{ .nodes = all_nodes };

    const start = clean_v_map.get(coord(0, 0)).?;
    const end = clean_v_map.get(coord(input[0].len - 1, input.len - 1)).?;

    const part1 = try graph.dijkstra(allocator, g, start, end);
    print("Part 1: {}\n", .{part1});
}
