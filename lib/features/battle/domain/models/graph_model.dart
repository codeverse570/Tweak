class GraphNode {
  final String id;
  final double x;
  final double y;

  const GraphNode({required this.id, required this.x, required this.y});
}

class GraphEdge {
  final String from;
  final String to;
  final int weight;

  const GraphEdge({required this.from, required this.to, required this.weight});
}
abstract class SubProblem {
  String get title;
  String get description;
  int get timeLimitSeconds;
  bool isCorrect(dynamic answer); // answer can be a path, int, list, etc.
  int get correctCost;            // or "score" for non-graph types
}

class GraphProblem extends SubProblem {
  @override
  final String title;
  @override
  final String description;
  final String startNode;
  final String endNode;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final List<String> correctPath;
  @override
  final int correctCost;
  @override
  final int timeLimitSeconds;

  GraphProblem({  // ← removed const
    required this.title,
    required this.description,
    required this.startNode,
    required this.endNode,
    required this.nodes,
    required this.edges,
    required this.correctPath,
    required this.correctCost,
    this.timeLimitSeconds = 45,
  });

  @override
  bool isCorrect(dynamic answer) {
    if (answer is! Map) return false;
    final path = answer['path'] as List<String>?;
    final cost = answer['cost'] as int?;
    return path?.join() == correctPath.join() || cost == correctCost;
  }
}
// ─── Sub-problem 1: A → E (5 nodes, tricky detours) ─────────────────────────
// Dijkstra: A→C→E = 3+4 = 7  (not A→B→D→E = 2+6+5=13, not A→D→E = 5+5=10)
final subProblem1 = GraphProblem(
  title: 'Sub-Problem 1 of 4',
  description: 'Find the shortest path from A to E.',
  startNode: 'A',
  endNode: 'E',
  timeLimitSeconds: 35,
  nodes: const [
    GraphNode(id: 'A', x: 0.08, y: 0.50),
    GraphNode(id: 'B', x: 0.35, y: 0.15),
    GraphNode(id: 'C', x: 0.35, y: 0.50),
    GraphNode(id: 'D', x: 0.62, y: 0.25),
    GraphNode(id: 'E', x: 0.88, y: 0.50),
  ],
  edges: const [
    GraphEdge(from: 'A', to: 'B', weight: 2),
    GraphEdge(from: 'A', to: 'C', weight: 3),
    GraphEdge(from: 'B', to: 'C', weight: 7),
    GraphEdge(from: 'B', to: 'D', weight: 6),
    GraphEdge(from: 'C', to: 'D', weight: 8),
    GraphEdge(from: 'C', to: 'E', weight: 4),
    GraphEdge(from: 'D', to: 'E', weight: 5),
  ],
  correctPath: ['A', 'C', 'E'],
  correctCost: 7,
);

// ─── Sub-problem 2: F → K (6 nodes, diamond + bypass) ───────────────────────
// Dijkstra: F→G→I→K = 1+3+4 = 8  (not F→H→J→K = 2+5+3=10, not F→G→J→K = 1+6+3=10)
final subProblem2 = GraphProblem(
  title: 'Sub-Problem 2 of 4',
  description: 'Find the shortest path from F to K.',
  startNode: 'F',
  endNode: 'K',
  timeLimitSeconds: 40,
  nodes: const [
    GraphNode(id: 'F', x: 0.08, y: 0.50),
    GraphNode(id: 'G', x: 0.30, y: 0.20),
    GraphNode(id: 'H', x: 0.30, y: 0.78),
    GraphNode(id: 'I', x: 0.57, y: 0.35),
    GraphNode(id: 'J', x: 0.57, y: 0.70),
    GraphNode(id: 'K', x: 0.88, y: 0.50),
  ],
  edges: const [
    GraphEdge(from: 'F', to: 'G', weight: 1),
    GraphEdge(from: 'F', to: 'H', weight: 2),
    GraphEdge(from: 'G', to: 'I', weight: 3),
    GraphEdge(from: 'G', to: 'J', weight: 6),
    GraphEdge(from: 'H', to: 'J', weight: 5),
    GraphEdge(from: 'H', to: 'I', weight: 9),
    GraphEdge(from: 'I', to: 'K', weight: 4),
    GraphEdge(from: 'J', to: 'K', weight: 3),
    GraphEdge(from: 'I', to: 'J', weight: 7),
  ],
  correctPath: ['F', 'G', 'I', 'K'],
  correctCost: 8,
);

// ─── Sub-problem 3: L → R (7 nodes, grid-like with tempting paths) ───────────
// Dijkstra: L→M→P→Q→R = 2+3+1+4 = 10 (not L→N→O→R = 1+8+6=15, not L→M→N→O→R = 2+5+8+6=21)
final subProblem3 = GraphProblem(
  title: 'Sub-Problem 3 of 4',
  description: 'Find the shortest path from L to R.',
  startNode: 'L',
  endNode: 'R',
  timeLimitSeconds: 45,
  nodes: const [
    GraphNode(id: 'L', x: 0.08, y: 0.50),
    GraphNode(id: 'M', x: 0.28, y: 0.22),
    GraphNode(id: 'N', x: 0.28, y: 0.78),
    GraphNode(id: 'O', x: 0.52, y: 0.60),
    GraphNode(id: 'P', x: 0.52, y: 0.25),
    GraphNode(id: 'Q', x: 0.75, y: 0.38),
    GraphNode(id: 'R', x: 0.90, y: 0.65),
  ],
  edges: const [
    GraphEdge(from: 'L', to: 'M', weight: 2),
    GraphEdge(from: 'L', to: 'N', weight: 1),
    GraphEdge(from: 'M', to: 'N', weight: 5),
    GraphEdge(from: 'M', to: 'P', weight: 3),
    GraphEdge(from: 'N', to: 'O', weight: 8),
    GraphEdge(from: 'P', to: 'O', weight: 6),
    GraphEdge(from: 'P', to: 'Q', weight: 1),
    GraphEdge(from: 'O', to: 'R', weight: 6),
    GraphEdge(from: 'Q', to: 'R', weight: 4),
    GraphEdge(from: 'Q', to: 'O', weight: 5),
  ],
  correctPath: ['L', 'M', 'P', 'Q', 'R'],
  correctCost: 10,
);

// ─── Sub-problem 4: S → Z (8 nodes, hardest) ────────────────────────────────
// Dijkstra: S→T→V→X→Z = 3+2+4+2 = 11 (many deceptive alternatives)
final subProblem4 = GraphProblem(
  title: 'Sub-Problem 4 of 4',
  description: 'Find the shortest path from S to Z.',
  startNode: 'S',
  endNode: 'Z',
  timeLimitSeconds: 50,
  nodes: const [
    GraphNode(id: 'S', x: 0.08, y: 0.50),
    GraphNode(id: 'T', x: 0.27, y: 0.20),
    GraphNode(id: 'U', x: 0.27, y: 0.78),
    GraphNode(id: 'V', x: 0.48, y: 0.35),
    GraphNode(id: 'W', x: 0.48, y: 0.70),
    GraphNode(id: 'X', x: 0.68, y: 0.22),
    GraphNode(id: 'Y', x: 0.68, y: 0.65),
    GraphNode(id: 'Z', x: 0.90, y: 0.45),
  ],
  edges: const [
    GraphEdge(from: 'S', to: 'T', weight: 3),
    GraphEdge(from: 'S', to: 'U', weight: 2),
    GraphEdge(from: 'T', to: 'V', weight: 2),
    GraphEdge(from: 'T', to: 'X', weight: 9),
    GraphEdge(from: 'U', to: 'W', weight: 4),
    GraphEdge(from: 'U', to: 'V', weight: 8),
    GraphEdge(from: 'V', to: 'X', weight: 4),
    GraphEdge(from: 'V', to: 'W', weight: 6),
    GraphEdge(from: 'V', to: 'Y', weight: 7),
    GraphEdge(from: 'W', to: 'Y', weight: 3),
    GraphEdge(from: 'X', to: 'Z', weight: 2),
    GraphEdge(from: 'Y', to: 'Z', weight: 5),
    GraphEdge(from: 'X', to: 'Y', weight: 8),
  ],
  correctPath: ['S', 'T', 'V', 'X', 'Z'],
  correctCost: 11,
);

final List<GraphProblem> battleProblems = [
  subProblem1,
  subProblem2,
  subProblem3,
  subProblem4,
];