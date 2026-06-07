import 'dart:math';
import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/battle/domain/models/graph_model.dart';


class GraphProblemWidget extends StatefulWidget {
  final GraphProblem problem;
  final ValueChanged<List<String>>? onPathChanged;

  const GraphProblemWidget({
    super.key,
    required this.problem,
    this.onPathChanged,
  });

  @override
  State<GraphProblemWidget> createState() => _GraphProblemWidgetState();
}

class _GraphProblemWidgetState extends State<GraphProblemWidget>
    with TickerProviderStateMixin {
  List<String> _selectedPath = [];
  late AnimationController _pathController;
  late AnimationController _glowController;

  String? _animFrom;
  String? _animTo;
  bool _isUndo = false;
  final List<(String, String)> _undoQueue = [];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _selectedPath = [widget.problem.startNode];

    _pathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

  _pathController.addStatusListener((status) {
  if (status == AnimationStatus.completed && _isUndo) {
    if (_undoQueue.isNotEmpty) {
      _playNextUndo();
    } else {
      // All undos done — clear anim state so glow doesn't linger
      setState(() {
        _animFrom = null;
        _animTo = null;
        _isUndo = false;
      });
    }
  }
});
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  GraphNode _nodeById(String id) =>
      widget.problem.nodes.firstWhere((n) => n.id == id);

  bool _edgeExists(String a, String b) {
    return widget.problem.edges.any(
      (e) => (e.from == a && e.to == b) || (e.from == b && e.to == a),
    );
  }

  int _edgeWeight(String a, String b) {
    final edge = widget.problem.edges.firstWhere(
      (e) => (e.from == a && e.to == b) || (e.from == b && e.to == a),
      orElse: () => const GraphEdge(from: '', to: '', weight: 0),
    );
    return edge.weight;
  }

  int get _totalCost {
    int cost = 0;
    for (int i = 0; i < _selectedPath.length - 1; i++) {
      cost += _edgeWeight(_selectedPath[i], _selectedPath[i + 1]);
    }
    return cost;
  }

  void _playNextUndo() {
    if (_undoQueue.isEmpty) return;

    final (from, to) = _undoQueue.removeAt(0);

    setState(() {
      _animFrom = from;
      _animTo = to;
      _selectedPath = List.from(_selectedPath)..remove(to);
    });

    _pathController.forward(from: 0);
    widget.onPathChanged?.call(_selectedPath);
  }

  void _handleNodeTap(String nodeId, Size canvasSize) {
    if (_selectedPath.isEmpty) {
      setState(() => _selectedPath = [nodeId]);
      widget.onPathChanged?.call(_selectedPath);
      return;
    }

    if (_selectedPath.last == nodeId) {
      _undo();
      return;
    }

    if (_selectedPath.contains(nodeId)) {
      final idx = _selectedPath.indexOf(nodeId);
      final nodesToRemove = _selectedPath.sublist(idx + 1);

      if (nodesToRemove.isEmpty) return;

      final queue = <(String, String)>[];
      for (int i = nodesToRemove.length - 1; i >= 0; i--) {
        final toNode = nodesToRemove[i];
        final fromNode = i == 0 ? nodeId : nodesToRemove[i - 1];
        queue.add((fromNode, toNode));
      }

      final first = queue.removeAt(0);

      setState(() {
        _isUndo = true;
        _undoQueue
          ..clear()
          ..addAll(queue);
        _animFrom = first.$1;
        _animTo = first.$2;
        _selectedPath = List.from(_selectedPath)..removeLast();
      });

      _pathController.forward(from: 0);
      widget.onPathChanged?.call(_selectedPath);
      return;
    }

    if (_edgeExists(_selectedPath.last, nodeId)) {
      setState(() {
        _animFrom = _selectedPath.last;
        _animTo = nodeId;
        _isUndo = false;
        _undoQueue.clear();
        _selectedPath = [..._selectedPath, nodeId];
      });
      _pathController.forward(from: 0);
      widget.onPathChanged?.call(_selectedPath);
    }
  }

  void _undo() {
    if (_selectedPath.length <= 1) return;

    setState(() {
      _animFrom = _selectedPath[_selectedPath.length - 2];
      _animTo = _selectedPath.last;
      _isUndo = true;
      _undoQueue.clear();
      _selectedPath = List.from(_selectedPath)..removeLast();
    });

    _pathController.forward(from: 0);
    widget.onPathChanged?.call(_selectedPath);
  }

  void _clear() {
    setState(() {
      _undoQueue.clear();
      _isUndo = false;
      _animFrom = null;
      _animTo = null;
      _selectedPath = [widget.problem.startNode];
    });
    widget.onPathChanged?.call(_selectedPath);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProblemHeader(problem: widget.problem),
        const SizedBox(height: 8),
        Expanded(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    onTapUp: (details) {
                      final tapped = _nodeAtPosition(details.localPosition, size);
                      if (tapped != null) _handleNodeTap(tapped, size);
                    },
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_glowController, _pathController]),
                      builder: (context, _) {
                        return CustomPaint(
                          size: size,
                          painter: _GraphPainter(
                            nodes: widget.problem.nodes,
                            edges: widget.problem.edges,
                            selectedPath: _selectedPath,
                            startNode: widget.problem.startNode,
                            endNode: widget.problem.endNode,
                            glowValue: _glowController.value,
                            pathProgress: _pathController.value,
                            animFrom: _animFrom,
                            animTo: _animTo,
                            isUndo: _isUndo,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              Positioned(
                top: 0,
                right: 12,
                child: _ClearButton(onTap: _clear),
              ),
            ],
          ),
        ),
        _BottomControls(
          path: _selectedPath,
          totalCost: _totalCost,
          onUndo: _undo,
        ),
      ],
    );
  }

  String? _nodeAtPosition(Offset pos, Size size) {
    for (final node in widget.problem.nodes) {
      final dx = node.x * size.width - pos.dx;
      final dy = node.y * size.height - pos.dy;
      if (sqrt(dx * dx + dy * dy) < 24) return node.id;
    }
    return null;
  }
}
// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _ProblemHeader extends StatelessWidget {
  final GraphProblem problem;
  const _ProblemHeader({required this.problem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.purple.withOpacity(0.3)),
            ),
            child: const Icon(Icons.route, color: AppColors.purpleGlow, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PROBLEM',
                        style: TextStyle(
                          color: AppColors.purpleGlow,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                        color: AppColors.surface,
                      ),
                      child: const Icon(
                        Icons.question_mark,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  problem.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                _DescriptionWithHighlights(
                  description: problem.description,
                  startNode: problem.startNode,
                  endNode: problem.endNode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionWithHighlights extends StatelessWidget {
  final String description;
  final String startNode;
  final String endNode;

  const _DescriptionWithHighlights({
    required this.description,
    required this.startNode,
    required this.endNode,
  });

  @override
  Widget build(BuildContext context) {
    // Build rich text with colored node labels
    final parts = description.split(RegExp(r'(?=[A-Z]\.)|(?<=[A-Z]\.)'));
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        children: _buildSpans(description),
      ),
    );
  }

  List<InlineSpan> _buildSpans(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\b([A-Z])\b');
    int last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      final letter = match.group(1)!;
      Color color = AppColors.textSecondary;
      if (letter == startNode) color = AppColors.greenLight;
      if (letter == endNode) color = AppColors.orange;
      spans.add(TextSpan(
        text: letter,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ));
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return spans;
  }
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ClearButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.refresh, size: 13, color: AppColors.textSecondary),
            SizedBox(width: 4),
            Text(
              'Clear',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final List<String> path;
  final int totalCost;
  final VoidCallback onUndo;

  const _BottomControls({
    required this.path,
    required this.totalCost,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Path display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.back_hand_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: path.length <= 1
                        ? const Text(
                            'Tap to any next node to add path',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          )
                        : Text(
                            path.join(' → '),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  if (path.length > 1)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Cost: $totalCost',
                        style: const TextStyle(
                          color: AppColors.purpleGlow,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Undo button
          GestureDetector(
            onTap: onUndo,
            child: Container(
              width: 48,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.undo, size: 16, color: AppColors.textSecondary),
                  Text(
                    'Undo',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Hint button
          Container(
            width: 48,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 16, color: AppColors.textSecondary),
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.purpleGlow,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Hint',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Painter ──────────────────────────────────────────────────────────

class _GraphPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final List<String> selectedPath;
  final String startNode;
  final String endNode;
  final double glowValue;
  final double pathProgress;
  final String? animFrom;
  final String? animTo;
  final bool isUndo;

  _GraphPainter({
    required this.nodes,
    required this.edges,
    required this.selectedPath,
    required this.startNode,
    required this.endNode,
    required this.glowValue,
    required this.pathProgress,
    required this.animFrom,
    required this.animTo,
    required this.isUndo,
  });

  GraphNode _nodeById(String id) => nodes.firstWhere((n) => n.id == id);
  static const double verticalStretch = 1.10;

  bool _isEdgeSelected(String a, String b) {
    for (int i = 0; i < selectedPath.length - 1; i++) {
      if ((selectedPath[i] == a && selectedPath[i + 1] == b) ||
          (selectedPath[i] == b && selectedPath[i + 1] == a)) {
        return true;
      }
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawEdges(canvas, size);
    _drawNodes(canvas, size);
  }

  void _drawEdges(Canvas canvas, Size size) {
    for (final edge in edges) {
      final from = _nodeById(edge.from);
      final to = _nodeById(edge.to);

      final center1 = Offset(
        from.x * size.width,
        from.y * size.height * verticalStretch,
      );
      final center2 = Offset(
        to.x * size.width,
        to.y * size.height * verticalStretch,
      );

      final dx = center2.dx - center1.dx;
      final dy = center2.dy - center1.dy;
      final length = sqrt(dx * dx + dy * dy);
      final ux = dx / length;
      final uy = dy / length;

      const nodeRadius = 18.0;

      final p1 = Offset(
        center1.dx + ux * nodeRadius,
        center1.dy + uy * nodeRadius,
      );
      final p2 = Offset(
        center2.dx - ux * nodeRadius,
        center2.dy - uy * nodeRadius,
      );

      final isSelected = _isEdgeSelected(edge.from, edge.to);
      final isAnimatingEdge =
          (edge.from == animFrom && edge.to == animTo) ||
          (edge.from == animTo && edge.to == animFrom);

      // Glow for selected edges
      if (isSelected || (isAnimatingEdge && isUndo)) {
        final glowPaint = Paint()
          ..color = AppColors.greenLight.withOpacity(0.15 + 0.1 * glowValue)
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, glowPaint);
      }

      final paint = Paint()
        ..color = (isSelected || isAnimatingEdge)
            ? AppColors.greenLight
            : AppColors.border.withOpacity(0.7)
        ..strokeWidth = (isSelected || isAnimatingEdge) ? 2.5 : 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy);

      final metric = path.computeMetrics().first;

      if (isAnimatingEdge) {
        if (isUndo) {
          // Shrink from full → zero
          final animatedPath = metric.extractPath(
            0,
            metric.length * (1.0 - pathProgress),
          );
          canvas.drawPath(animatedPath, paint);
        } else {
          // Grow from zero → full
          final animatedPath = metric.extractPath(
            0,
            metric.length * pathProgress,
          );
          canvas.drawPath(animatedPath, paint);
        }
      } else if (isSelected) {
        canvas.drawLine(p1, p2, paint);
      } else {
        canvas.drawLine(p1, p2, paint);
      }

      // Weight label
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      final nx = -dy / length;
      final ny = dx / length;
      const offsetAmount = 8.0;
      final labelPos = Offset(
        mid.dx + nx * offsetAmount,
        mid.dy + ny * offsetAmount,
      );
      _drawWeightLabel(canvas, labelPos, edge.weight, isSelected);
    }
  }

  void _drawWeightLabel(Canvas canvas, Offset pos, int weight, bool selected) {
    final tp = TextPainter(
      text: TextSpan(
        text: '$weight',
        style: TextStyle(
          color: selected ? AppColors.greenLight : AppColors.white,
          fontSize: 10,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: pos, width: tp.width + 8, height: tp.height + 4),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = selected
            ? AppColors.green.withOpacity(0.2)
            : AppColors.bg.withOpacity(0.8),
    );
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawNodes(Canvas canvas, Size size) {
    for (final node in nodes) {
      final pos = Offset(
        node.x * size.width,
        node.y * size.height * verticalStretch,
      );
      final isSelected = selectedPath.contains(node.id);
      final isStart = node.id == startNode;
      final isEnd = node.id == endNode;
      final isLast = selectedPath.isNotEmpty && selectedPath.last == node.id;

      if (isStart || isEnd) {
        final glowPaint = Paint()
          ..color = (isEnd ? AppColors.orange : AppColors.greenLight)
              .withOpacity(0.2 + 0.1 * glowValue)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 22, glowPaint);
      }

      final ringPaint = Paint()
        ..color = isEnd
            ? AppColors.orange
            : isStart
                ? AppColors.greenLight
                : AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isStart || isEnd) ? 2.5 : 1.5;
      canvas.drawCircle(pos, 18, ringPaint);

      final fillPaint = Paint()
        ..color = isEnd
            ? AppColors.orange.withOpacity(0.15)
            : isStart
                ? AppColors.green.withOpacity(0.15)
                : AppColors.surface
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 17, fillPaint);

      if (isLast && !isEnd) {
        final pulsePaint = Paint()
          ..color = AppColors.purpleGlow.withOpacity(0.4 * (1 - glowValue))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(pos, 18 + 8 * glowValue, pulsePaint);
      }

      final tp = TextPainter(
        text: TextSpan(
          text: node.id,
          style: TextStyle(
            color: isEnd
                ? AppColors.orange
                : isStart
                    ? AppColors.greenLight
                    : isSelected
                        ? const Color.fromARGB(255, 253, 253, 253)
                        : const Color.fromARGB(255, 244, 235, 255),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_GraphPainter old) =>
      old.selectedPath != selectedPath ||
      old.glowValue != glowValue ||
      old.pathProgress != pathProgress ||
      old.animFrom != animFrom ||
      old.animTo != animTo ||
      old.isUndo != isUndo;
}