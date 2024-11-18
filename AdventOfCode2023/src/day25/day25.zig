const std = @import("std");
const rand = std.crypto.random;

const print = std.debug.print;
const Map = std.StringHashMap;
const List = std.ArrayList([]const u8);

const VERTEX_NAME_SIZE = 3;

// Thanks to: https://www.geeksforgeeks.org/introduction-and-implementation-of-kargers-algorithm-for-minimum-cut/
//
// Struggled to understand the algorithm and the resource above helped so much.

const MincutReturn = struct {
    mincut: usize,
    vertex1: usize,
    vertex2: usize,
};

const Edge = struct {
    source: usize,
    destination: usize,
};

const Subset = struct {
    parent: usize,
    rank: usize,
};

const Graph = struct {
    allocator: std.mem.Allocator,

    vertex_number: usize,
    edge_number: usize,

    edges: []Edge,

    pub fn new(allocator: std.mem.Allocator, vertex_number: usize, edge_number: usize) Graph {
        return Graph{
            .allocator = allocator,
            .vertex_number = vertex_number,
            .edge_number = edge_number,
            .edges = allocator.alloc(Edge, edge_number) catch unreachable,
        };
    }

    fn find(subsets: []Subset, i: usize) usize {
        if (subsets[i].parent != i) {
            subsets[i].parent = find(subsets, subsets[i].parent);
        }

        return subsets[i].parent;
    }

    fn Union(subsets: []Subset, i: usize, j: usize) void {
        const iroot = find(subsets, i);
        const jroot = find(subsets, j);

        if (subsets[iroot].rank < subsets[jroot].rank) {
            subsets[iroot].parent = jroot;
        } else {
            if (subsets[iroot].rank > subsets[jroot].rank) {
                subsets[jroot].parent = iroot;
            }
            // If ranks are same, then make one as root and
            // increment its rank by one
            else {
                subsets[jroot].parent = iroot;
                subsets[iroot].rank += 1;
            }
        }
    }

    pub fn mincut(self: Graph) MincutReturn {
        const vertex_number = self.vertex_number;
        const edge_number = self.edge_number;

        const copied_edges = self.allocator.alloc(Edge, self.edges.len) catch unreachable;
        @memcpy(copied_edges, self.edges);

        var subsets = self.allocator.alloc(Subset, vertex_number) catch unreachable;
        for (0..vertex_number) |index| {
            subsets[index] = Subset{ .parent = index, .rank = 0 };
        }

        var vertices = vertex_number;
        while (vertices > 2) {
            const i = rand.intRangeLessThan(usize, 0, edge_number);

            const subset1 = find(subsets, copied_edges[i].source);
            const subset2 = find(subsets, copied_edges[i].destination);

            if (subset1 == subset2) {
                continue;
            }

            vertices -= 1;
            Union(subsets, subset1, subset2);
        }

        var cutedges: usize = 0;
        for (0..edge_number) |i| {
            const subset1 = find(subsets, copied_edges[i].source);
            const subset2 = find(subsets, copied_edges[i].destination);
            if (subset1 != subset2) {
                cutedges += 1;
            }
        }

        var vertex1: usize = 0;
        var vertex2: usize = 0;

        const first_parent = subsets[0].parent;

        for (subsets) |subset| {
            if (subset.parent == first_parent) {
                vertex1 += 1;
            } else {
                vertex2 += 1;
            }
        }

        return MincutReturn{ .mincut = cutedges, .vertex1 = vertex1, .vertex2 = vertex2 };
    }
};

pub fn solve(input: [][]const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    defer arena.deinit();

    var number: usize = 0;
    var name_to_num = Map(usize).init(allocator);

    var edge_list = std.ArrayList(Edge).init(allocator);
    defer edge_list.deinit();

    for (input) |line| {
        const vertex = line[0..VERTEX_NAME_SIZE];
        const edges = line[VERTEX_NAME_SIZE + 2 ..];
        var edges_tokenizer = std.mem.tokenizeSequence(u8, edges, " ");

        if (name_to_num.get(vertex) == null) {
            try name_to_num.put(vertex, number);
            number += 1;
        }

        const source_vertex = name_to_num.get(vertex).?;

        while (edges_tokenizer.next()) |edge| {
            if (name_to_num.get(edge) == null) {
                try name_to_num.put(edge, number);
                number += 1;
            }

            const destination_vertex = name_to_num.get(edge).?;

            try edge_list.append(Edge{ .source = source_vertex, .destination = destination_vertex });
        }
    }

    var graph = Graph.new(allocator, number, edge_list.items.len);
    graph.edges = try edge_list.toOwnedSlice();

    const part1 = while (true) {
        const mincut_values = graph.mincut();

        if (mincut_values.mincut == 3) {
            break mincut_values.vertex1 * mincut_values.vertex2;
        }
    };

    print("Part 1: {}\n", .{part1});
}
