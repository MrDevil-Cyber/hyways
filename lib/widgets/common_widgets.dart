part of '../main.dart';

class _ScrollReveal extends StatefulWidget {
  const _ScrollReveal({
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, .12),
    this.scaleFrom = .97,
    this.duration = const Duration(milliseconds: 480),
    this.onRevealed,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final double scaleFrom;
  final Duration duration;
  final VoidCallback? onRevealed;

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal> {
  ScrollPosition? _position;
  bool _visible = false;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextPosition = Scrollable.maybeOf(context)?.position;
    if (_position != nextPosition) {
      _position?.removeListener(_checkVisibility);
      _position = nextPosition?..addListener(_checkVisibility);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted || _visible || _scheduled) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final left = renderObject.localToGlobal(Offset.zero).dx;
    final bottom = top + renderObject.size.height;
    final right = left + renderObject.size.width;
    final viewport = MediaQuery.sizeOf(context);
    if (top < viewport.height * .94 &&
        bottom > 0 &&
        left < viewport.width * .96 &&
        right > 0) {
      _scheduled = true;
      final delay = MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : widget.delay;
      Future<void>.delayed(delay, () {
        if (!mounted) return;
        setState(() => _visible = true);
        widget.onRevealed?.call();
      });
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final visible = _visible || reduceMotion;
    final duration = reduceMotion ? Duration.zero : widget.duration;
    return RepaintBoundary(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : widget.offset,
          duration: duration,
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: visible ? 1 : widget.scaleFrom,
            duration: duration,
            curve: Curves.easeOutBack,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _CountUpText extends StatefulWidget {
  const _CountUpText({
    required this.target,
    required this.suffix,
    required this.style,
  });

  final int target;
  final String suffix;
  final TextStyle style;

  @override
  State<_CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<_CountUpText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return Text('${widget.target}${widget.suffix}', style: widget.style);
    }
    return _ScrollReveal(
      scaleFrom: .85,
      onRevealed: () {
        if (!_controller.isAnimating && _controller.value == 0) {
          _controller.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, _) => Text(
          '${(widget.target * _animation.value).round()}${widget.suffix}',
          style: widget.style,
        ),
      ),
    );
  }
}

class _AppPageRoute<T> extends PageRouteBuilder<T> {
  _AppPageRoute({required Widget page})
    : super(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(.08, .025),
                end: Offset.zero,
              ).animate(curved),
              child: ScaleTransition(
                scale: Tween<double>(begin: .97, end: 1).animate(curved),
                child: child,
              ),
            ),
          );
        },
      );
}

class _PressScale extends StatefulWidget {
  const _PressScale({required this.child, this.pressedScale = .975});

  final Widget child;
  final double pressedScale;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _setPressed(true),
    onPointerUp: (_) => _setPressed(false),
    onPointerCancel: (_) => _setPressed(false),
    child: AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1,
      alignment: Alignment.center,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: widget.child,
    ),
  );
}

class _AnimatedTabPage extends StatelessWidget {
  const _AnimatedTabPage({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) => TickerMode(
    enabled: active,
    child: AnimatedOpacity(
      opacity: active ? 1 : 0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: active ? Offset.zero : const Offset(.025, 0),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: active ? 1 : .985,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          child: child,
        ),
      ),
    ),
  );
}

class _Glass extends StatelessWidget {
  const _Glass({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? panel,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white12),
      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 24)],
    ),
    child: child,
  );
}

class _Title extends StatelessWidget {
  const _Title(this.a, this.b);
  final String a, b;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 340;
      final lineWidth = compact ? 24.0 : 38.0;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GrowingTitleLine(width: lineWidth),
          SizedBox(width: compact ? 9 : 14),
          Flexible(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .5,
                ),
                children: [
                  TextSpan(text: a),
                  TextSpan(
                    text: b,
                    style: const TextStyle(color: red),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: compact ? 9 : 14),
          _GrowingTitleLine(width: lineWidth),
        ],
      );
    },
  );
}

class _GrowingTitleLine extends StatelessWidget {
  const _GrowingTitleLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: width),
    duration: const Duration(milliseconds: 520),
    curve: Curves.easeOutCubic,
    builder: (_, value, _) => Container(width: value, height: 1, color: red),
  );
}
