const std = @import("std");
const expect = std.testing.expect;
const Order = std.math.Order;
const print = std.debug.print;
const log = std.log;
const mem = std.mem;

const Edge = struct {
    in_node: *Node,
    out_node: *Node,

    distance: usize,
};

const Node = struct {
    out_edges: []const Edge,

    label: []const u8,
    work_distance: usize,
};

const Graph = struct {
    nodes: []*Node,
};

// 1  function Dijkstra(Graph, source):
//  2
//  3      for each vertex v in Graph.Vertices:
//  4          dist[v] ← INFINITY
//  5          prev[v] ← UNDEFINED
//  6          add v to Q
//  7      dist[source] ← 0
//  8
//  9      while Q is not empty:
// 10          u ← vertex in Q with minimum dist[u]
// 11          remove u from Q
// 12
// 13          for each neighbor v of u still in Q:
// 14              alt ← dist[u] + Graph.Edges(u, v)
// 15              if alt < dist[v]:
// 16                  dist[v] ← alt
// 17                  prev[v] ← u
// 18
// 19      return dist[], prev[]

fn find_shortest_index(list: *std.ArrayList(*const Node)) usize {
    var shortestIndex: usize = 0;

    for (list.items, 0..) |item, index| {
        if (item.work_distance < list.items[shortestIndex].work_distance) {
            shortestIndex = index;
        }
    }

    return shortestIndex;
}

fn dijkstra(allocator: std.mem.Allocator, graph: Graph, source: *Node, destination: *Node) !usize {
    var work_map = std.AutoHashMap(*const Node, *const Node).init(allocator);

    // this is for sure the wrong data structure
    // properly look at 'priority queue'.
    var work_queue = std.ArrayList(*const Node).init(allocator);

    for (graph.nodes) |node| {
        node.*.work_distance = 99999999999;
        try work_queue.append(node);
    }

    source.work_distance = 0;

    while (work_queue.items.len > 0) {
        const closest_node_index = find_shortest_index(&work_queue);
        const closest_node = work_queue.orderedRemove(closest_node_index);

        for (closest_node.out_edges) |edge| {
            const neighbor = edge.out_node;
            const alternative_path = closest_node.work_distance + edge.distance;

            if (alternative_path < neighbor.work_distance) {
                neighbor.*.work_distance = alternative_path;
                try work_map.put(neighbor, closest_node);
            }
        }
    }

    return destination.work_distance;
}

//    B
//  4/ 1\
// A     D
//  3\ 5/
//    C

test "Can find shortest path between A and D" {
    const page_allocator = std.heap.page_allocator;

    var a = Node{ .out_edges = undefined, .label = "A", .work_distance = 0 };
    var b = Node{ .out_edges = undefined, .label = "B", .work_distance = 0 };
    var c = Node{ .out_edges = undefined, .label = "C", .work_distance = 0 };
    var d = Node{ .out_edges = undefined, .label = "D", .work_distance = 0 };

    const ab = Edge{ .in_node = &a, .out_node = &b, .distance = 4 };
    const bd = Edge{ .in_node = &b, .out_node = &d, .distance = 1 };

    const ac = Edge{ .in_node = &a, .out_node = &c, .distance = 3 };
    const cd = Edge{ .in_node = &c, .out_node = &d, .distance = 5 };

    a.out_edges = &[_]Edge{ ab, ac };
    b.out_edges = &[_]Edge{bd};
    c.out_edges = &[_]Edge{cd};

    var nodes = [_]*Node{ &a, &b, &c, &d };
    const graph = Graph{ .nodes = &nodes };

    const shortest_path_a_d = try dijkstra(page_allocator, graph, &a, &d);
    const shortest_path_b_d = try dijkstra(page_allocator, graph, &b, &d);
    const shortest_path_a_c = try dijkstra(page_allocator, graph, &a, &c);

    try expect(shortest_path_a_d == 5);
    try expect(shortest_path_b_d == 1);
    try expect(shortest_path_a_c == 3);
}
