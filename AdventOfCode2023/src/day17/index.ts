const input = await Bun.file("./input.txt").text();
const processed_input = input
  .split("\n")
  .slice(0, -1)
  .map((s) => s.split("").map(Number));

class Node {
  public id: string;
  public x: number;
  public y: number;
  public weight: number;

  constructor(id: string, x: number, y: number, weight: number) {
    this.id = `${id}-${x}-${y}`;
    this.x = x;
    this.y = y;
    this.weight = weight;
  }
}

class NodeWithWork extends Node {
  public work_distance: number;

  constructor(node: Node, work_distance: number) {
    super(node.id.split("-")[0], node.x, node.y, node.weight);
    this.work_distance = work_distance;
  }
}

function get_from_id(n: NodeWithWork[], id: string): NodeWithWork | undefined {
  return n.find((n) => n.id === id);
}

class Edge {
  public from: string;
  public to: string;
  public weight: number;

  constructor(from: string, to: string, weight: number) {
    this.from = from;
    this.to = to;
    this.weight = weight;
  }
}

class Graph {
  public nodes: Node[];
  public edges: Edge[];

  constructor(nodes: Node[], edges: Edge[]) {
    this.nodes = nodes;
    this.edges = edges;
  }

  public get_node_from_id(id: string): Node {
    const node = this.nodes.find((n) => n.id === id);
    if (node == null) {
      throw new Error("Could not find node");
    }

    return node;
  }

  public get_node_or_throw(x: number, y: number): Node {
    const node = this.nodes.find((n) => n.x === x && n.y === y);
    if (node == null) {
      throw new Error("Could not find node");
    }

    return node;
  }

  public get_node_out_edges(node: Node): Edge[] {
    return this.edges.filter((e) => e.from === node.id);
  }

  public add_edge(edge: Edge): void {
    this.edges.push(edge);
  }

  public add_node(node: Node): void {
    this.nodes.push(node);
  }

  public print(): void {
    for (const n of this.nodes) {
      console.log(`Node: ${n.id}`);
      for (const e of h_nodes.get_node_out_edges(n)) {
        console.log(` Edge: ${e.from} --- ${e.to} | Weight: ${e.weight}`);
      }
    }
  }

  public dijkstras(source: Node, destination: Node): number {
    const work_map = new Map<string, string>();
    const distances = new Map<string, number>();

    const work_queue = this.nodes.map((n) => new NodeWithWork(n, 9999999999));

    work_queue.find((n) => n.id === source.id)!.work_distance = 0;

    while (work_queue.length > 0) {
      work_queue.sort((a, b) => a.work_distance - b.work_distance);
      const closent_node = work_queue[0];

      distances.set(closent_node.id, closent_node.work_distance);

      work_queue.splice(0, 1);

      for (const e of this.get_node_out_edges(closent_node)) {
        const neighbor = get_from_id(work_queue, e.to);
        if (neighbor == null) {
          continue;
        }

        const alternative_path = closent_node.work_distance + e.weight;

        if (alternative_path < neighbor.work_distance) {
          neighbor.work_distance = alternative_path;
          work_map.set(neighbor.id, closent_node.id);
        }
      }
    }

    return distances.get(destination.id)!;
  }

  public static from_graphs(...graphs: Graph[]) {
    return new Graph(
      graphs.flatMap((g) => g.nodes),
      graphs.flatMap((g) => g.edges),
    );
  }
}

function create_graph(id: string, input: number[][]): Graph {
  const nodes: Node[] = [];

  for (const [y, row] of input.entries()) {
    for (const [x, n] of row.entries()) {
      nodes.push(new Node(id, x, y, n));
    }
  }

  return new Graph(nodes, []);
}

function create_interlaced_edges(
  first: Graph,
  second: Graph,
  offset: number,
  distance: number,
) {
  for (const n of first.nodes) {
    let accumulated_weight = 0;
    for (let i = 1; i < offset && n.x + i < processed_input[0].length; i++) {
      accumulated_weight += processed_input[n.y][n.x + i];
    }

    // Right
    for (
      let i = offset;
      i <= distance && n.x + i < processed_input[0].length;
      i++
    ) {
      accumulated_weight += processed_input[n.y][n.x + i];
      const out_node = second.get_node_or_throw(n.x + i, n.y);

      first.add_edge(new Edge(n.id, out_node.id, accumulated_weight));
    }

    accumulated_weight = 0;
    for (let i = -1; i > -offset && n.x + i >= 0; i--) {
      accumulated_weight += processed_input[n.y][n.x + i];
    }

    // Left
    for (let i = -offset; -i <= distance && n.x + i >= 0; i--) {
      accumulated_weight += processed_input[n.y][n.x + i];
      const out_node = second.get_node_or_throw(n.x + i, n.y);

      first.add_edge(new Edge(n.id, out_node.id, accumulated_weight));
    }
  }

  for (const n of second.nodes) {
    let accumulated_weight = 0;
    for (let i = 1; i < offset && n.y + i < processed_input.length; i++) {
      accumulated_weight += processed_input[n.y + i][n.x];
    }
    // Right
    for (
      let i = offset;
      i <= distance && n.y + i < processed_input.length;
      i++
    ) {
      accumulated_weight += processed_input[n.y + i][n.x];
      const out_node = first.get_node_or_throw(n.x, n.y + i);

      first.add_edge(new Edge(n.id, out_node.id, accumulated_weight));
    }

    accumulated_weight = 0;
    for (let i = -1; i > -offset && n.y + i >= 0; i--) {
      accumulated_weight += processed_input[n.y + i][n.x];
    }

    // Left
    for (let i = -offset; -i <= distance && n.y + i >= 0; i--) {
      accumulated_weight += processed_input[n.y + i][n.x];
      const out_node = first.get_node_or_throw(n.x, n.y + i);

      first.add_edge(new Edge(n.id, out_node.id, accumulated_weight));
    }
  }
}

const v_nodes = create_graph("v", processed_input);
const h_nodes = create_graph("h", processed_input);

// create_interlaced_edges(h_nodes, v_nodes, 1, 3);
create_interlaced_edges(h_nodes, v_nodes, 4, 10);

const full_graph = Graph.from_graphs(h_nodes, v_nodes);

// full_graph.print();

const INITIAL = "initial-0-0";
const FINAL = `final-${processed_input[0].length - 1}-${
  processed_input.length - 1
}`;

full_graph.add_node(new Node("initial", 0, 0, 0));
full_graph.add_node(
  new Node(
    "final",
    processed_input[0].length - 1,
    processed_input.length - 1,
    0,
  ),
);

full_graph.add_edge(new Edge(INITIAL, "v-0-0", 0));
full_graph.add_edge(new Edge(INITIAL, "h-0-0", 0));

full_graph.add_edge(
  new Edge(
    `v-${processed_input[0].length - 1}-${processed_input.length - 1}`,
    FINAL,
    0,
  ),
);
full_graph.add_edge(
  new Edge(
    `h-${processed_input[0].length - 1}-${processed_input.length - 1}`,
    FINAL,
    0,
  ),
);

const shortest_path = full_graph.dijkstras(
  full_graph.get_node_from_id(INITIAL),
  full_graph.get_node_from_id(FINAL),
);

console.log(shortest_path);
