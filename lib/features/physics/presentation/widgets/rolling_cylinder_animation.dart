// lib/features/physics/presentation/widgets/rolling_cylinder_animation.dart
//
// Improvements over previous version:
//   1) Platform looks realistic — stone/concrete blocks with mortar grid,
//      aggregate noise texture, specular highlights, and proper 3D side-face.
//   2) Colors changed to natural earth tones: warm concrete, brushed-steel
//      cylinder, amber/gold annotations instead of neon purple.
//   3) Part-1 ends with cylinder upright at corner (0°). Part-2 start
//      animates 0° → defaultAngle (_Phase.tiltingToDefault) then allows drag.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sub-problem phase selector
// ─────────────────────────────────────────────────────────────────────────────

enum SubProblemPhase {
  /// Part 1: rolls to edge, stops upright at corner (0°), then freezes.
  rollingOnly,
  /// Part 2: starts directly at corner in waiting state for drag-angle input.
  angleOnly,
}

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

class RollingCylinderAnimation extends StatefulWidget {
  final void Function(double angleDeg)? onAngleSubmitted;
  final bool? answerCorrect;
  final SubProblemPhase subProblemPhase;
  final double trueAngleDeg;
  final double angleTolerance;
  final double defaultAngleDeg; // shown after Part-1 lock-in
  final void Function(bool correct)? onSubmitResult;
final double animationHeight;
  const RollingCylinderAnimation({
    super.key,
    this.onAngleSubmitted,
    this.answerCorrect,
    this.subProblemPhase = SubProblemPhase.angleOnly,
    this.trueAngleDeg    = 44.76,
    this.angleTolerance  = 1.0,
    this.defaultAngleDeg = 35.0,
    this.onSubmitResult,
    this.animationHeight = 130,
    
  });

  @override
  State<RollingCylinderAnimation> createState() =>
      RollingCylinderAnimationState();
}

class RollingCylinderAnimationState extends State<RollingCylinderAnimation> {
  late final _CylinderGame _game;

  @override
  void initState() {
    super.initState();
    _game = _CylinderGame(
      onAngleSubmitted: (a) => widget.onAngleSubmitted?.call(a),
      subProblemPhase:  widget.subProblemPhase,
      trueAngleDeg:     widget.trueAngleDeg,
      angleTolerance:   widget.angleTolerance,
      defaultAngleDeg:  widget.defaultAngleDeg,
      onSubmitResult:   (c) => widget.onSubmitResult?.call(c),
    );
  }

  void submitAngle()      => _game.submitAngle();
  void replay()           => _game.replay();
  void startSubProblem2() => _game.startSubProblem2();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: widget.animationHeight, child: GameWidget(game: _game)),
        if (widget.subProblemPhase == SubProblemPhase.angleOnly)
          ValueListenableBuilder<_Phase>(
            valueListenable: _game.phaseNotifier,
            builder: (_, phase, __) {
              if (phase != _Phase.waiting) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: ValueListenableBuilder<double>(
                  valueListenable: _game.userAngleNotifier,
                  builder: (_, angle, __) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.touch_app, size: 13, color: Color(0xFF8D7B6B)),
                      const SizedBox(width: 4),
                      Text(
                        'Drag cylinder  ·  ${angle.toStringAsFixed(1)}°',
                        style: const TextStyle(
                            color: Color(0xFFA89880), fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase enum
// ─────────────────────────────────────────────────────────────────────────────

enum _Phase {
  rolling,
  tiltingToDefault, // NEW: smooth 0° → defaultAngle after rolling
  atEdge,
  waiting,
  pivoting,
  falling,
  wrongAngle,
}

// ─────────────────────────────────────────────────────────────────────────────
// Flame Game
// ─────────────────────────────────────────────────────────────────────────────

class _CylinderGame extends FlameGame with TapCallbacks, DragCallbacks {
  static const double kRadius    = 34.0;
  static const double kEdgeXFrac = 0.62;
  static const double kSurfYFrac = 0.58;
  static const double kLossAngle = 48.19;
  SubProblemPhase _activePhase;

  final void Function(double) onAngleSubmitted;
  final SubProblemPhase subProblemPhase;
  final double trueAngleDeg;
  final double angleTolerance;
  final double defaultAngleDeg;
  final void Function(bool correct) onSubmitResult;

  _CylinderGame({
    required this.onAngleSubmitted,
    required this.subProblemPhase,
    required this.trueAngleDeg,
    required this.angleTolerance,
    required this.defaultAngleDeg,
    required this.onSubmitResult,
  }): _activePhase = subProblemPhase;

  final phaseNotifier     = ValueNotifier<_Phase>(_Phase.rolling);
  final userAngleNotifier = ValueNotifier<double>(35.0);

  late _PlatformComponent _platform;
  late _CylinderComponent _cylinder;
  late _GhostComponent    _ghost;
  late _OverlayRenderer   _overlay;

  _Phase get _phase => phaseNotifier.value;

  @override
  Color backgroundColor() => const Color(0xFF1A1510);

@override
Future<void> onLoad() async {
  await super.onLoad();
  camera.viewfinder.anchor = Anchor.topLeft;
  _platform = _PlatformComponent();
  _ghost    = _GhostComponent();
  _cylinder = _CylinderComponent(onDragUpdate: _onCylinderDrag, onTap: _onCylinderTap);
  _overlay  = _OverlayRenderer();
  await addAll([_platform, _ghost, _cylinder, _overlay]);
  if (subProblemPhase == SubProblemPhase.rollingOnly) {
    _startRolling();
  } else {
    // Delay so Flutter has committed the new canvas size before we compute geometry
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!isLoaded) return;
      _ghost.showAt(_ghostPos);          // now uses correct size
      _cylinder.stopAtCornerWithAngle(_cornerPos, defaultAngleDeg);
      userAngleNotifier.value = defaultAngleDeg;
      _toWaiting();
    });
  }
}

  // ── Phase transitions ──────────────────────────────────────────────────────

  void _startRolling() {
    phaseNotifier.value = _Phase.rolling;
    _cylinder.startRolling(size);
    _ghost.showAt(_ghostPos);
  }

  /// Part 1 end: cylinder sits upright at corner (0°).
  void _toAtEdge() {
    phaseNotifier.value = _Phase.atEdge;
    userAngleNotifier.value = 0.0;
    _cylinder.stopAtCornerWithAngle(_cornerPos, 0.0);
    _overlay.setPhase(_Phase.atEdge);
    _overlay.setUserAngle(0.0);
  }

 void _toWaiting() {
  phaseNotifier.value = _Phase.waiting;
  _cylinder.stopAtCornerWithAngle(_cornerPos, userAngleNotifier.value);
  _overlay.setPhase(_Phase.waiting);
  _overlay.setUserAngle(userAngleNotifier.value); // ADD THIS LINE
}

  // ── Submit ─────────────────────────────────────────────────────────────────

  void submitAngle() {
    if (_phase != _Phase.waiting) return;
    final angle   = userAngleNotifier.value;
    final correct = (angle - trueAngleDeg).abs() <= angleTolerance;
    onAngleSubmitted(angle);
    if (correct) {
      phaseNotifier.value = _Phase.pivoting;
      _cylinder.startPivot(_cornerPos, angle, kLossAngle, _onPivotComplete);
      _overlay.setPhase(_Phase.pivoting);
      _overlay.setUserAngle(angle);
    } else {
      phaseNotifier.value = _Phase.wrongAngle;
      _overlay.setPhase(_Phase.wrongAngle);
      _overlay.setUserAngle(angle);
      onSubmitResult(false);
    }
  }

  void _onPivotComplete() {
    phaseNotifier.value = _Phase.falling;
    _cylinder.startFall(size);
    _overlay.setPhase(_Phase.falling);
    _spawnCornerParticles();
    onSubmitResult(true);
  }

  /// Part 2 start: animate cylinder from 0° → defaultAngle, then allow dragging.
  void startSubProblem2() {
    _activePhase = SubProblemPhase.angleOnly; // ADD THIS
  _overlay.reset();
  userAngleNotifier.value = 0.0;

  Future.delayed(const Duration(milliseconds: 50), () {
    if (!isLoaded) return;
    _ghost.showAt(_ghostPos);            // recomputed from new canvas size
    _cylinder.stopAtCornerWithAngle(_cornerPos, 0.0);
    phaseNotifier.value = _Phase.tiltingToDefault;
    _overlay.setPhase(_Phase.tiltingToDefault);
    _overlay.setUserAngle(0.0);
    _cylinder.startPivot(_cornerPos, 0.0, defaultAngleDeg, () {
      userAngleNotifier.value = defaultAngleDeg;
      _toWaiting();
    });
  });
}

  void replay() {
    phaseNotifier.value     = _Phase.rolling;
    userAngleNotifier.value = defaultAngleDeg;
    _cylinder.reset();
    _ghost.reset();
    _overlay.reset();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (subProblemPhase == SubProblemPhase.rollingOnly) {
        _startRolling();
      } else {
        _toWaiting();
      }
    });
  }

  // ── Geometry ───────────────────────────────────────────────────────────────

  Vector2 get _cornerPos => Vector2(size.x * kEdgeXFrac - 1, size.y * kSurfYFrac + 2);
  Vector2 get _ghostPos  => Vector2(size.x * 0.08 + kRadius, size.y * kSurfYFrac - kRadius);

  void _onCylinderDrag(Vector2 worldPos) {
    if (_phase != _Phase.waiting) return;
    final corner = _cornerPos;
    double angle = math.atan2(worldPos.x - corner.x, -(worldPos.y - corner.y)) * 180 / math.pi;
    angle = angle.clamp(0.0, 85.0);
    userAngleNotifier.value = angle;
    _cylinder.setAngle(angle, _cornerPos);
    _overlay.setUserAngle(angle);
  }

  void _onCylinderTap() {}

  void notifyRollingDone() {
    if (subProblemPhase == SubProblemPhase.rollingOnly) {
      _toAtEdge();
    } else {
      _toWaiting();
    }
  }

  void _spawnCornerParticles() {
    final corner = _cornerPos;
    final rng = math.Random();
    add(ParticleSystemComponent(
      particle: Particle.generate(
        count: 18, lifespan: 0.7,
        generator: (i) {
          final a = rng.nextDouble() * math.pi;
          final s = 30.0 + rng.nextDouble() * 60;
          return AcceleratedParticle(
            position: corner.clone(),
            speed: Vector2(math.cos(a) * s, -math.sin(a) * s),
            acceleration: Vector2(0, 120),
            child: CircleParticle(
              radius: 2.0 + rng.nextDouble() * 2,
              paint: Paint()
                ..color = Color.lerp(const Color(0xFFD4A44C),
                    const Color(0xFFA07830), rng.nextDouble())!.withOpacity(0.85),
            ),
          );
        },
      ),
    ));
  }

  // ── Input ──────────────────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    if (_phase == _Phase.waiting || _phase == _Phase.atEdge) {
      _ghost.handleTap(event.canvasPosition);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (_phase == _Phase.waiting) _cylinder.handleDragStart(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_phase == _Phase.waiting)
      _cylinder.handleDragUpdate(event.canvasEndPosition, _onCylinderDrag);
  }

  @override
  void onDragEnd(DragEndEvent event) => _cylinder.handleDragEnd();
}

// ─────────────────────────────────────────────────────────────────────────────
// Platform Component — realistic stone/concrete blocks
// ─────────────────────────────────────────────────────────────────────────────

class _CrackLine  { final double x1,y1,x2,y2,width,opacity;
  const _CrackLine({required this.x1,required this.y1,required this.x2,required this.y2,required this.width,required this.opacity}); }
class _MortarLine { final double x1,y1,x2,y2;
  const _MortarLine({required this.x1,required this.y1,required this.x2,required this.y2}); }

class _PlatformComponent extends Component with HasGameRef<_CylinderGame> {
  final _rng = math.Random(42);
  List<_CrackLine>  _cracks            = [];
  List<_MortarLine> _horizontalMortars = [];
  List<_MortarLine> _verticalMortars   = [];
  // bool _initialized = false;
  double _cachedEx = -1, _cachedSy = -1;
  void _init(double ex, double sy, double h) {
    if ((ex - _cachedEx).abs() < 0.5 && (sy - _cachedSy).abs() < 0.5) return;
    _cachedEx = ex;
    _cachedSy = sy;

    // Horizontal mortar rows
    _horizontalMortars = [];
    double y = sy + 16 + _rng.nextDouble() * 4;

    while (y < sy + h) {
      _horizontalMortars.add(_MortarLine(x1: 0, y1: y, x2: ex, y2: y));
      y += 14 + _rng.nextDouble() * 6;
    }

    // Vertical mortar — brick-offset pattern
    _verticalMortars = [];
    int row = 0; double ry = sy;
    while (ry < sy + h) {
      final rowH   = 14.0 + _rng.nextDouble() * 6;
      final offset = row.isEven ? 0.0 : 11.0;
      double x = offset;
      while (x < ex) {
        _verticalMortars.add(_MortarLine(x1: x, y1: ry, x2: x, y2: math.min(ry + rowH, sy + h)));
        x += 18 + _rng.nextDouble() * 8;
      }
      ry += rowH; row++;
    }

    // Surface cracks
    _cracks = List.generate(6, (i) {
      final sx = ex * (0.04 + _rng.nextDouble() * 0.84);
      final sy2 = sy + 2 + _rng.nextDouble() * 6;
      final len = 10.0 + _rng.nextDouble() * 24;
      final ang = (_rng.nextDouble() - 0.5) * 0.9;
      return _CrackLine(
        x1: sx, y1: sy2,
        x2: sx + math.cos(ang) * len, y2: sy2 + math.sin(ang) * len,
        width:   0.4 + _rng.nextDouble() * 0.5,
        opacity: 0.18 + _rng.nextDouble() * 0.20,
      );
    });
  }

  @override
  void render(Canvas canvas) {
    final sz = gameRef.size;
    final ex = sz.x * _CylinderGame.kEdgeXFrac;
    final sy = sz.y * _CylinderGame.kSurfYFrac;
    final h  = sz.y - sy;
    _init(ex, sy, h);

    final baseRect = Rect.fromLTWH(0, sy, ex, h);

    // 1. Base concrete gradient
    canvas.drawRect(baseRect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: const [Color(0xFF8A7A68), Color(0xFF6B5C4C), Color(0xFF4E3F31), Color(0xFF3A2E22)],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(baseRect));

    // 2. Aggregate noise
    final noisePaint = Paint()..style = PaintingStyle.fill;
    final nRng = math.Random(7);
    for (int i = 0; i < 130; i++) {
      final nx = nRng.nextDouble() * ex;
      final ny = sy + nRng.nextDouble() * h;
      final nr = 0.5 + nRng.nextDouble() * 1.1;
      noisePaint.color = (nRng.nextDouble() > 0.5 ? Colors.white : Colors.black)
          .withOpacity(0.04 + nRng.nextDouble() * 0.06);
      canvas.drawCircle(Offset(nx, ny), nr, noisePaint);
    }

    // 3. Horizontal mortar shadows + highlights
    final mortarShadow = Paint()
      ..color = const Color(0xFF1E1408).withOpacity(0.60)
      ..strokeWidth = 1.3;
    final mortarHi = Paint()
      ..color = const Color(0xFFCCB898).withOpacity(0.12)
      ..strokeWidth = 0.7;
    for (final m in _horizontalMortars) {
      canvas.drawLine(Offset(m.x1, m.y1), Offset(m.x2, m.y2), mortarShadow);
      canvas.drawLine(Offset(m.x1, m.y1 + 1.0), Offset(m.x2, m.y2 + 1.0), mortarHi);
    }

    // 4. Vertical mortar
    final vertMortar = Paint()
      ..color = const Color(0xFF1E1408).withOpacity(0.45)
      ..strokeWidth = 0.9;
    for (final m in _verticalMortars) {
      canvas.drawLine(Offset(m.x1, m.y1), Offset(m.x2, m.y2), vertMortar);
    }

    // 5. Brick top-edge glints
    final brickGlint = Paint()
      ..color = const Color(0xFFD4C4A8).withOpacity(0.10)
      ..strokeWidth = 0.7;
    for (final m in _horizontalMortars) {
      canvas.drawLine(Offset(m.x1, m.y1 - 1), Offset(m.x2, m.y2 - 1), brickGlint);
    }

    // 6. Top-surface specular band
    canvas.drawRect(Rect.fromLTWH(0, sy, ex, 6), Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFFD4C4A0).withOpacity(0.70),
                 const Color(0xFFD4C4A0).withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, sy, ex, 6)));

    // 7. Bottom ambient-occlusion
    canvas.drawRect(Rect.fromLTWH(0, sy + h - 12, ex, 12), Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black.withOpacity(0.42)],
      ).createShader(Rect.fromLTWH(0, sy + h - 12, ex, 12)));

    // 8. Surface cracks
    for (final c in _cracks) {
      canvas.drawLine(Offset(c.x1, c.y1), Offset(c.x2, c.y2),
          Paint()..color = Colors.black.withOpacity(c.opacity)
                 ..strokeWidth = c.width ..strokeCap = StrokeCap.round);
    }

    // 9. Right-face (3-D depth)
    final sideRect = Rect.fromLTWH(ex - 4, sy, 4, h);
    canvas.drawRect(sideRect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft, end: Alignment.centerRight,
        colors: const [Color(0xFF4E3F31), Color(0xFF2A1E10)],
      ).createShader(sideRect));

    // 10. Top edge line — amber glow
    canvas.drawLine(Offset(0, sy), Offset(ex, sy), Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFFB8A070).withOpacity(0.0),
                 const Color(0xFFD4B870).withOpacity(0.90),
                 const Color(0xFFB8A070).withOpacity(0.20)],
        stops: const [0.0, 0.62, 1.0],
      ).createShader(Rect.fromLTWH(0, sy - 1, ex, 2))
      ..strokeWidth = 2.2);

    // 11. Corner pivot amber glow
    canvas.drawCircle(Offset(ex, sy), 10, Paint()
      ..color = const Color(0xFFD4A030).withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
    canvas.drawCircle(Offset(ex, sy), 5, Paint()
      ..color = const Color(0xFFE8C060).withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(Offset(ex, sy), 3.5, Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFFFF0C0), Color(0xFFD4A030)],
      ).createShader(Rect.fromCircle(center: Offset(ex, sy), radius: 3.5)));

    // 12. Right vertical edge highlight
    canvas.drawLine(Offset(ex, sy), Offset(ex, sz.y), Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFFD4B870).withOpacity(0.85),
                 const Color(0xFF8A6830).withOpacity(0.25)],
      ).createShader(Rect.fromPoints(Offset(ex, sy), Offset(ex, sz.y)))
      ..strokeWidth = 2.0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ghost Component
// ─────────────────────────────────────────────────────────────────────────────

class _GhostComponent extends Component with HasGameRef<_CylinderGame> {
  Vector2 _pos = Vector2.zero();
  bool _visible = false, _showV0Info = false;
  double _pulseT = 0.0;

  void showAt(Vector2 pos) { _pos = pos.clone(); _visible = true; }
  void reset() { _visible = false; _showV0Info = false; _pulseT = 0.0; }
  void handleTap(Vector2 tap) {
    if (_visible && (tap - _pos).length <= _CylinderGame.kRadius * 1.5)
      _showV0Info = !_showV0Info;
  }

  @override void update(double dt) => _pulseT += dt * 1.8;

  @override
  void render(Canvas canvas) {
    if (!_visible) return;
    final cx = _pos.x, cy = _pos.y, R = _CylinderGame.kRadius;
    final p  = 0.35 + 0.15 * math.sin(_pulseT);
    canvas.drawCircle(Offset(cx, cy), R, Paint()..color = const Color(0xFF1A1208).withOpacity(0.55));
    _dashedCircle(canvas, cx, cy, R,      Color.fromRGBO(160, 120, 60, p), 1.6);
    _dashedCircle(canvas, cx, cy, R*0.55, Color.fromRGBO(160, 120, 60, p*0.7), 0.9);
    canvas.drawCircle(Offset(cx, cy), 3.5, Paint()..color = const Color(0xFFD4A868).withOpacity(p));
    _arrow(canvas, cx, cy, R);
    if (_showV0Info) _bubble(canvas, cx, cy); else _hint(canvas, cx, cy, R);
  }

  void _arrow(Canvas canvas, double cx, double cy, double R) {
      final phase = gameRef.phaseNotifier.value;
  if (phase == _Phase.waiting || phase == _Phase.tiltingToDefault) return;
  
  const len = 22.0;
  final sx = cx + R + 3, ex = sx + len;
    final paint = Paint()..color = const Color(0xFFD4A030).withOpacity(0.60)
      ..strokeWidth = 1.5 ..strokeCap = StrokeCap.round;
    double x = sx; bool draw = true;
    while (x < ex) { final e = math.min(x+(draw?4.0:3.0), ex);
      if (draw) canvas.drawLine(Offset(x,cy), Offset(e,cy), paint);
      x += draw?4.0:3.0; draw = !draw; }
    canvas.drawPath(Path()..moveTo(ex,cy)..lineTo(ex-6,cy-3.5)..lineTo(ex-6,cy+3.5)..close(),
        Paint()..color = const Color(0xFFD4A030).withOpacity(0.60));
    _text(canvas, 'v₀', Offset(sx+2, cy-13), const Color(0xFFD4A030).withOpacity(0.70), 9);
  }

  void _hint(Canvas canvas, double cx, double cy, double R) =>
    _text(canvas, '⊙ tap for initial state', Offset(cx-34, cy+R+5),
        const ui.Color.fromARGB(255, 250, 243, 231).withOpacity(0.60), 9);

  void _bubble(Canvas canvas, double cx, double cy) {
    final phase = gameRef.phaseNotifier.value;
    final l1 = phase == _Phase.atEdge ? 'v₀ = ?' : 'v₀ = √(gR/3)';
    final l2 = phase == _Phase.atEdge ? 'ω₀ = √(g/3R)' : 'ω₀ = v₀ / R';
    // final l1 = phase == _Phase.atEdge ? 'v₀ = ?' : 'v₀ = √(gR/3)';
    final l3 = phase == _Phase.atEdge ? '' : 'I_c= mR^2 / 2';
    final bx = cx-6, by = cy-78;
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, 110, 54), const Radius.circular(10));
    canvas.drawRRect(rr, Paint()..color = const Color(0xFF1C150A).withOpacity(0.96));
    canvas.drawRRect(rr, Paint()..color = const Color(0xFFA07030).withOpacity(0.50)
      ..style = PaintingStyle.stroke ..strokeWidth = 1);
    _text(canvas, l1, Offset(bx+10, by+9),  const Color(0xFFE8D4A8), 10);
    _text(canvas, l2, Offset(bx+10, by+24), const Color(0xFFD4B870).withOpacity(0.82), 9);
    _text(canvas, l3, Offset(bx+10, by+40), const ui.Color.fromARGB(255, 245, 209, 118).withOpacity(0.82), 9);
  }

  void _dashedCircle(Canvas canvas, double cx, double cy, double r, Color c, double sw) {
    final circ = 2*math.pi*r;
    const dl = 5.0, gl = 4.0;
    final segs = circ/(dl+gl), da = (dl/circ)*2*math.pi, ga = (gl/circ)*2*math.pi;
    final paint = Paint()..color=c..strokeWidth=sw..style=PaintingStyle.stroke..strokeCap=StrokeCap.round;
    double a = -math.pi/2;
    for (int i = 0; i < segs.ceil(); i++) {
      canvas.drawArc(Rect.fromCircle(center:Offset(cx,cy),radius:r), a, da, false, paint);
      a += da+ga;
    }
  }

  void _text(Canvas canvas, String t, Offset pos, Color c, double sz) =>
    (TextPainter(text: TextSpan(text:t, style:TextStyle(color:c,fontSize:sz,fontFamily:'monospace')),
        textDirection:TextDirection.ltr)..layout()).paint(canvas, pos);
}

// ─────────────────────────────────────────────────────────────────────────────
// Cylinder Component — brushed steel / natural metal look
// ─────────────────────────────────────────────────────────────────────────────

class _CylinderComponent extends Component with HasGameRef<_CylinderGame> {
  final void Function(Vector2) onDragUpdate;
  final void Function()        onTap;
  _CylinderComponent({required this.onDragUpdate, required this.onTap});

  Vector2 _pos = Vector2.zero();
  double _spinRad = 0.0, _phase2 = 0.0;
  Vector2 _rollStart = Vector2.zero(), _rollEnd = Vector2.zero();
  bool _isRolling = false;
  Vector2 _cornerPos = Vector2.zero();
  double _pivotTarget = 0.0, _pivotCurrent = 0.0;
  bool _isPivoting = false;
  void Function()? _onPivotDone;
  bool _isFalling = false;
  double _fallVx = 0.0, _fallVy = 0.0, _fallGrav = 0.0;
  bool _dragging = false;

  void startRolling(Vector2 sz) {
    final ex = sz.x * _CylinderGame.kEdgeXFrac;
    final sy = sz.y * _CylinderGame.kSurfYFrac;
    _rollStart = Vector2(sz.x * 0.08 + _CylinderGame.kRadius, sy - _CylinderGame.kRadius);
    _rollEnd   = Vector2(ex, sy - _CylinderGame.kRadius);
    _pos = _rollStart.clone(); _isRolling = true; _phase2 = 0.0; _spinRad = 0.0;
  }

  void stopAtCornerWithAngle(Vector2 corner, double deg) {
    _isRolling = false; _isPivoting = false;
    final rad = deg * math.pi / 180;
    _pos = Vector2(corner.x + _CylinderGame.kRadius * math.sin(rad),
                   corner.y - _CylinderGame.kRadius * math.cos(rad));
    _spinRad = rad;
  }

  void setAngle(double deg, Vector2 corner) {
    final rad = deg * math.pi / 180;
    _pos = Vector2(corner.x + _CylinderGame.kRadius * math.sin(rad),
                   corner.y - _CylinderGame.kRadius * math.cos(rad));
    _spinRad = rad;
  }

  void startPivot(Vector2 corner, double fromDeg, double toDeg, void Function() onDone) {
    _cornerPos = corner.clone();
    _pivotCurrent = fromDeg * math.pi / 180;
    _pivotTarget  = toDeg   * math.pi / 180;
    _isPivoting = true; _phase2 = 0.0; _onPivotDone = onDone;
  }

  void startFall(Vector2 sz) {
    _isPivoting = false; _isFalling = true; _phase2 = 0.0;
    final lr = _CylinderGame.kLossAngle * math.pi / 180;
    _fallVx = math.sin(lr) * 80.0; _fallVy = -math.cos(lr) * 32.0;
    _fallGrav = sz.y * 1.8;
  }

  void reset() {
    _isRolling = false; _isPivoting = false; _isFalling = false;
    _pos = Vector2.zero(); _spinRad = 0.0; _phase2 = 0.0; _dragging = false;
  }

  void handleDragStart(Vector2 pos) {
    if ((pos - _pos).length <= _CylinderGame.kRadius * 1.5) _dragging = true;
  }
  void handleDragUpdate(Vector2 pos, void Function(Vector2) cb) { if (_dragging) cb(pos); }
  void handleDragEnd() => _dragging = false;

  @override
  void update(double dt) {
    if (_isRolling)  _updateRolling(dt);
    if (_isPivoting) _updatePivot(dt);
    if (_isFalling)  _updateFall(dt);
  }

  void _updateRolling(double dt) {
    _phase2 = math.min(_phase2 + dt * 0.55, 1.0);
    final ease = _phase2 * _phase2 * (3 - 2 * _phase2);
    _pos = Vector2(_rollStart.x + (_rollEnd.x - _rollStart.x) * ease, _rollStart.y);
    _spinRad = ease * (_rollEnd.x - _rollStart.x) / _CylinderGame.kRadius;
    if (_phase2 >= 1.0) { _isRolling = false; gameRef.notifyRollingDone(); }
  }

  void _updatePivot(double dt) {
    const speed = 1.6;
    _pivotCurrent += (_pivotTarget - _pivotCurrent).clamp(-speed * dt, speed * dt);
    _spinRad = _pivotCurrent;
    _pos = Vector2(
      _cornerPos.x + _CylinderGame.kRadius * math.sin(_pivotCurrent),
      _cornerPos.y - _CylinderGame.kRadius * math.cos(_pivotCurrent),
    );
    if ((_pivotCurrent - _pivotTarget).abs() < 0.01) {
      _isPivoting = false; _onPivotDone?.call();
    }
  }

  void _updateFall(double dt) {
    _fallVy += _fallGrav * dt; _pos.x += _fallVx * dt; _pos.y += _fallVy * dt;
    _spinRad += dt * 5.0;
  }

  @override
  void render(Canvas canvas) {
    final phase = gameRef.phaseNotifier.value;
    _drawCylinder(canvas, _pos.x, _pos.y, _spinRad, _dragging);
    if (phase == _Phase.rolling          ||
        phase == _Phase.tiltingToDefault  ||
        phase == _Phase.waiting           ||
        phase == _Phase.atEdge            ||
        phase == _Phase.wrongAngle) {
      _drawVArrow(canvas, _pos.x, _pos.y,
          phase != _Phase.rolling);
    }
  }

  void _drawCylinder(Canvas canvas, double cx, double cy, double rot, bool glow) {
    final R = _CylinderGame.kRadius;
    final phase = gameRef.phaseNotifier.value;
    final isWrong = phase == _Phase.wrongAngle;

    if (glow || isWrong) {
      canvas.drawCircle(Offset(cx, cy), R + 6, Paint()
        ..color = isWrong
            ? const Color(0xFFFF5252).withOpacity(0.22)
            : const Color(0xFFD4B870).withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
    }

    // Drop shadow
    canvas.drawCircle(Offset(cx + 3, cy + 4), R, Paint()
      ..color = Colors.black.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Main body — brushed steel
    canvas.drawCircle(Offset(cx, cy), R, Paint()
      ..shader = (isWrong
              ? const RadialGradient(
                  center: Alignment(-0.35, -0.35), radius: 0.85,
                  colors: [Color(0xFFFF8A80), Color(0xFFE53935), Color(0xFF7B1212), Color(0xFF3A0808)],
                  stops: [0.0, 0.28, 0.65, 1.0])
              : const RadialGradient(
                  center: Alignment(-0.40, -0.40), radius: 0.90,
                  colors: [Color(0xFFECECF4), Color(0xFFB0B8CC), Color(0xFF687080), Color(0xFF283040)],
                  stops: [0.0, 0.30, 0.65, 1.0]))
          .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: R)));

    // Lathe rings & grain
    canvas.save();
    canvas.translate(cx, cy); canvas.rotate(rot);
    for (final r in [R * 0.45, R * 0.72]) {
      canvas.drawCircle(Offset.zero, r, Paint()
        ..color = (isWrong ? const Color(0xFFFF8A80) : Colors.white).withOpacity(0.10)
        ..style = PaintingStyle.stroke ..strokeWidth = 0.8);
    }
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(Offset(-R*0.70, -R*0.55 + i*R*0.45),
                      Offset( R*0.70, -R*0.55 + i*R*0.45),
          Paint()..color = Colors.white.withOpacity(0.05) ..strokeWidth = 0.6);
    }
    canvas.drawCircle(Offset(-R*0.28, -R*0.28), R*0.16,
        Paint()..color = Colors.white.withOpacity(0.22));
    canvas.restore();

    // Rim
    canvas.drawCircle(Offset(cx, cy), R, Paint()
      ..color = (isWrong ? const Color(0xFFFF5252) : const Color(0xFF9AAABB)).withOpacity(0.65)
      ..style = PaintingStyle.stroke ..strokeWidth = 1.5);

    // Specular arc
    if (phase != _Phase.falling) {
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: R - 2.5),
          math.pi * 1.1, math.pi * 0.55, false, Paint()
        ..color = Colors.white.withOpacity(0.45)
        ..style = PaintingStyle.stroke ..strokeWidth = 2.5 ..strokeCap = StrokeCap.round);
    }

    // Centre pin
    canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = const Color(0xFFD4D8E0));
    canvas.drawCircle(Offset(cx, cy), 2.5, Paint()..color = Colors.white);
  }

  void _drawVArrow(Canvas canvas, double cx, double cy, bool dotted) {
    final R = _CylinderGame.kRadius;
    final sx = cx + R + 4, ex = sx + 26.0;
    final paint = Paint()..color = const Color(0xFFD4A030)..strokeWidth = 1.8..strokeCap = StrokeCap.round;
    if (dotted) {
      double x = sx; bool d = true;
      while (x < ex) { final e = math.min(x+(d?4.0:3.0),ex);
        if (d) canvas.drawLine(Offset(x,cy), Offset(e,cy), paint);
        x += d?4.0:3.0; d = !d; }
    } else {
      canvas.drawLine(Offset(sx, cy), Offset(ex, cy), paint);
    }
    canvas.drawPath(Path()..moveTo(ex,cy)..lineTo(ex-7,cy-4)..lineTo(ex-7,cy+4)..close(),
        Paint()..color = const Color(0xFFD4A030));
    _text(canvas, 'v₀', Offset(sx+3, cy-14), const Color(0xFFD4A030), 9.5);
  }

  void _text(Canvas canvas, String t, Offset pos, Color c, double sz) =>
    (TextPainter(text: TextSpan(text:t, style:TextStyle(color:c,fontSize:sz,fontFamily:'monospace')),
        textDirection:TextDirection.ltr)..layout()).paint(canvas, pos);
}

// ─────────────────────────────────────────────────────────────────────────────
// Overlay Renderer
// ─────────────────────────────────────────────────────────────────────────────

class _OverlayRenderer extends Component with HasGameRef<_CylinderGame> {
  _Phase _phase     = _Phase.rolling;
  double _userAngle = 35.0;
  final List<Vector2> _trail = [];

  void setPhase(_Phase p)     => _phase = p;
  void setUserAngle(double a) => _userAngle = a;
  void reset() { _phase = _Phase.rolling; _userAngle = 35.0; _trail.clear(); }

  @override
  void update(double dt) {
    final p = gameRef._cylinder._pos;
    if (_phase == _Phase.rolling || _phase == _Phase.pivoting || _phase == _Phase.tiltingToDefault) {
      _trail.add(p.clone()); if (_trail.length > 12) _trail.removeAt(0);
    } else { _trail.clear(); }
  }

  @override
  void render(Canvas canvas) {
    final sz = gameRef.size;
    final ex = sz.x * _CylinderGame.kEdgeXFrac;
    final sy = sz.y * _CylinderGame.kSurfYFrac;
    _drawTrail(canvas);
    _drawPivotArc(canvas, ex, sy);
    _drawAngleLines(canvas, ex, sy);
    if (_phase == _Phase.wrongAngle) _drawWrongFeedback(canvas, ex, sy);
  }

  void _drawTrail(Canvas canvas) {
    final R = _CylinderGame.kRadius;
    for (int i = 0; i < _trail.length; i++) {
      canvas.drawCircle(Offset(_trail[i].x, _trail[i].y), R,
          Paint()..color = const Color(0xFF8A7050).withOpacity((i/_trail.length)*0.14));
    }
  }

  void _drawPivotArc(Canvas canvas, double ex, double sy) {
    if (_phase != _Phase.pivoting && _phase != _Phase.falling &&
        _phase != _Phase.tiltingToDefault) return;
    canvas.drawArc(Rect.fromCircle(center: Offset(ex, sy), radius: _CylinderGame.kRadius),
        -math.pi/2, math.pi/2, false, Paint()
      ..color = Colors.white12 ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 ..strokeCap = StrokeCap.round);
  }

  void _drawAngleLines(Canvas canvas, double ex, double sy) {
  if (gameRef._activePhase == SubProblemPhase.rollingOnly) return; 
  final R = _CylinderGame.kRadius;
  final showRef = _phase == _Phase.waiting || _phase == _Phase.pivoting ||
                  _phase == _Phase.wrongAngle || _phase == _Phase.tiltingToDefault ||
                  _phase == _Phase.atEdge;
    if (showRef) {
      _dashedLine(canvas, Offset(ex, sy), Offset(ex, sy - 70),
          Colors.white.withOpacity(0.22), 1.0);
      _paintText(canvas, '0°', Offset(ex+4, sy-68), Colors.white.withOpacity(0.28), 8.5);
    }

    final showUser = _phase == _Phase.waiting || _phase == _Phase.tiltingToDefault ||
                     _phase == _Phase.atEdge;
    if (showUser) {
      final rad = _userAngle * math.pi / 180;
      final len = R * 2.8, dx = math.sin(rad)*len, dy = -math.cos(rad)*len;
      canvas.drawLine(Offset(ex, sy), Offset(ex+dx, sy+dy), Paint()
        ..color = const Color(0xFFD4B870).withOpacity(0.80)
        ..strokeWidth = 1.8 ..strokeCap = StrokeCap.round);
      canvas.drawArc(Rect.fromCircle(center: Offset(ex, sy), radius: R*0.55),
          -math.pi/2, rad, false, Paint()
        ..color = const Color(0xFFD4B870).withOpacity(0.28)
        ..strokeWidth = 1.2 ..style = PaintingStyle.stroke);
      _paintText(canvas, '${_userAngle.toStringAsFixed(1)}°',
          Offset(ex+dx+5, sy+dy-8), const Color(0xFFE8D4A8), 10);
    }

    if (_phase == _Phase.falling) {
      final rad = _CylinderGame.kLossAngle * math.pi / 180;
      final len = R*3.2, dx = math.sin(rad)*len, dy = -math.cos(rad)*len;
      canvas.drawLine(Offset(ex, sy), Offset(ex+dx, sy+dy), Paint()
        ..color = Colors.lightGreenAccent.withOpacity(0.85) ..strokeWidth = 2.0 ..strokeCap = StrokeCap.round);
      _paintText(canvas, '${_CylinderGame.kLossAngle.toStringAsFixed(1)}°\n(cos⁻¹ 2/3)',
          Offset(ex+dx+5, sy+dy-20), Colors.lightGreenAccent, 9.5);
    }
  }

  void _drawWrongFeedback(Canvas canvas, double ex, double sy) {
    final R = _CylinderGame.kRadius;
    final rad = _userAngle * math.pi / 180;
    final len = R * 2.8, dx = math.sin(rad)*len, dy = -math.cos(rad)*len;
    final diff = (_userAngle - _CylinderGame.kLossAngle).abs();
    canvas.drawLine(Offset(ex, sy), Offset(ex+dx, sy+dy), Paint()
      ..color = const Color(0xFFFF5252).withOpacity(0.85) ..strokeWidth = 1.8 ..strokeCap = StrokeCap.round);
    canvas.drawArc(Rect.fromCircle(center: Offset(ex, sy), radius: R*0.55),
        -math.pi/2, rad, false, Paint()
      ..color = const Color(0xFFFF5252).withOpacity(0.28)
      ..strokeWidth = 1.2 ..style = PaintingStyle.stroke);
    _paintText(canvas, '${_userAngle.toStringAsFixed(1)}°',
        Offset(ex+dx+5, sy+dy-8), const Color(0xFFFF5252), 10, lineThrough: true);
    final badgeText = '✕  off by ${diff.toStringAsFixed(1)}°';
    final tp = TextPainter(text: TextSpan(text: badgeText,
        style: const TextStyle(color: Color(0xFFFF5252), fontSize: 9.5,
            fontFamily: 'monospace', fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr)..layout();
    const pad = 6.0;
    final bx = ex+dx+5, by = sy+dy+6;
    final bRect = Rect.fromLTWH(bx-pad, by-pad, tp.width+pad*2, tp.height+pad*2);
    canvas.drawRRect(RRect.fromRectAndRadius(bRect, const Radius.circular(6)),
        Paint()..color = const Color(0xFF3A0808).withOpacity(0.90));
    canvas.drawRRect(RRect.fromRectAndRadius(bRect, const Radius.circular(6)),
        Paint()..color = const Color(0xFFFF5252).withOpacity(0.50)
          ..style = PaintingStyle.stroke ..strokeWidth = 0.8);
    tp.paint(canvas, Offset(bx, by));
  }

  void _dashedLine(Canvas canvas, Offset from, Offset to, Color c, double sw) {
    final dx = to.dx-from.dx, dy = to.dy-from.dy;
    final len = math.sqrt(dx*dx+dy*dy), nx = dx/len, ny = dy/len;
    const dash = 4.0, gap = 3.5;
    final paint = Paint()..color=c..strokeWidth=sw..strokeCap=StrokeCap.round;
    double t = 0; bool draw = true;
    while (t < len) { final e = math.min(t+(draw?dash:gap), len);
      if (draw) canvas.drawLine(Offset(from.dx+nx*t, from.dy+ny*t),
          Offset(from.dx+nx*e, from.dy+ny*e), paint);
      t += draw?dash:gap; draw = !draw; }
  }

  void _paintText(Canvas canvas, String text, Offset pos, Color color, double sz,
      {bool lineThrough = false}) {
    (TextPainter(text: TextSpan(text: text,
        style: TextStyle(color: color, fontSize: sz, fontFamily: 'monospace',
            decoration: lineThrough ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white24)),
        textDirection: TextDirection.ltr)..layout()).paint(canvas, pos);
  }
}