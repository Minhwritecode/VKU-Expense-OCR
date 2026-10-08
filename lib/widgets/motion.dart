part of '../main.dart';

class MotionTokens {
  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 280);
  static const enter = Duration(milliseconds: 420);
}

class LedgerlyLaunch extends StatefulWidget {
  const LedgerlyLaunch({super.key, required this.child});
  final Widget child;

  @override
  State<LedgerlyLaunch> createState() => _LedgerlyLaunchState();
}

class _LedgerlyLaunchState extends State<LedgerlyLaunch> {
  bool _ready = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: ui.TextDirection.ltr,
    child: AnimatedSwitcher(
      duration: MotionTokens.standard,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      child: _ready
          ? KeyedSubtree(
              key: const ValueKey('ledgerly-app'),
              child: widget.child,
            )
          : const _LedgerlySplash(key: ValueKey('ledgerly-splash')),
    ),
  );
}

class _LedgerlySplash extends StatefulWidget {
  const _LedgerlySplash({super.key});

  @override
  State<_LedgerlySplash> createState() => _LedgerlySplashState();
}

class _LedgerlySplashState extends State<_LedgerlySplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: MotionTokens.enter,
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final splashTheme = _theme(Brightness.dark);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(child: const _LedgerlyLoaderVisual(size: 170)),
        const SizedBox(height: 16),
        Text(
          'ledgerly',
          style: splashTheme.textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 34,
            letterSpacing: -0.7,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Chi tiêu rõ ràng hơn mỗi ngày',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            height: 1.45,
          ),
        ),
      ],
    );
    final animatedContent = reduceMotion
        ? Center(child: content)
        : FadeTransition(
            opacity: CurvedAnimation(parent: _intro, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween(begin: .94, end: 1.0).animate(
                CurvedAnimation(parent: _intro, curve: Curves.easeOutBack),
              ),
              child: content,
            ),
          );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.dark),
      home: Scaffold(
        backgroundColor: const Color(0xFF101A34),
        body: Center(child: animatedContent),
      ),
    );
  }
}

class MotionFadeSlide extends StatefulWidget {
  const MotionFadeSlide({super.key, required this.child, this.delay = 0});
  final Widget child;
  final int delay;

  @override
  State<MotionFadeSlide> createState() => _MotionFadeSlideState();
}

class _MotionFadeSlideState extends State<MotionFadeSlide>
    with SingleTickerProviderStateMixin {
  Timer? _delayTimer;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionTokens.enter,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == 0) {
      _controller.forward();
    } else {
      _delayTimer = Timer(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations && !_controller.isCompleted) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .035),
          end: Offset.zero,
        ).animate(curve),
        child: widget.child,
      ),
    );
  }
}

class LedgerlyLoading extends StatelessWidget {
  const LedgerlyLoading({super.key, this.size = 46, this.label});
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      RepaintBoundary(child: _LedgerlyLoaderVisual(size: size)),
      if (label != null) ...[
        const SizedBox(height: 10),
        Text(
          label!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05,
            height: 1.35,
          ),
        ),
      ],
    ],
  );
}

class _LedgerlyLoaderVisual extends StatefulWidget {
  const _LedgerlyLoaderVisual({required this.size});
  final double size;

  @override
  State<_LedgerlyLoaderVisual> createState() => _LedgerlyLoaderVisualState();
}

class _LedgerlyLoaderVisualState extends State<_LedgerlyLoaderVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!kIsWeb) {
      return Lottie.asset(
        'assets/animations/ledgerly_loader.json',
        width: widget.size,
        height: widget.size,
        repeat: true,
        animate: !reduceMotion,
        frameRate: FrameRate.composition,
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => CustomPaint(
        size: Size.square(widget.size),
        painter: _WebLoaderPainter(
          progress: reduceMotion ? 0 : _controller.value,
        ),
        child: child,
      ),
    );
  }
}

class _WebLoaderPainter extends CustomPainter {
  const _WebLoaderPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .33;
    final stroke = size.shortestSide * .055;
    final track = Paint()
      ..color = AppColors.blue.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, track);
    final arc = Paint()
      ..color = AppColors.blue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + progress * math.pi * 2,
      math.pi * 1.35,
      false,
      arc,
    );
    final dotAngle = -math.pi / 2 + progress * math.pi * 2;
    final dot = Offset(
      center.dx + math.cos(dotAngle) * radius,
      center.dy + math.sin(dotAngle) * radius,
    );
    canvas.drawCircle(dot, stroke * 1.45, Paint()..color = AppColors.orange);
  }

  @override
  bool shouldRepaint(covariant _WebLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class AsyncLoadingButton extends StatefulWidget {
  const AsyncLoadingButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });
  final Future<void> Function() onPressed;
  final IconData icon;
  final String label;

  @override
  State<AsyncLoadingButton> createState() => _AsyncLoadingButtonState();
}

class _AsyncLoadingButtonState extends State<AsyncLoadingButton> {
  bool _loading = false;

  Future<void> _run() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: _loading ? null : _run,
    icon: AnimatedSwitcher(
      duration: MotionTokens.fast,
      child: _loading
          ? const SizedBox(
              key: ValueKey('loading'),
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
          : Icon(widget.icon, key: const ValueKey('icon')),
    ),
    label: AnimatedSwitcher(
      duration: MotionTokens.fast,
      child: Text(
        _loading ? 'Đang lưu…' : widget.label,
        key: ValueKey(_loading),
      ),
    ),
  );
}
