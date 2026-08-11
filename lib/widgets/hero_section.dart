part of '../main.dart';

class _Hero extends StatelessWidget {
  const _Hero({required this.onTap});
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final wide = screenWidth > 700;
    final compact = screenWidth < 380;
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/industrial-hero.png',
            fit: BoxFit.cover,
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xF2050A0E),
                  Color(0xC0050A0E),
                  Color(0x18050A0E),
                ],
                stops: [0, .48, 1],
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Colors.transparent, ink],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  wide ? 34 : 24,
                  22,
                  wide ? 34 : 24,
                  6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScrollReveal(
                      offset: const Offset(-.10, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                              ),
                              children: [
                                TextSpan(text: 'HY'),
                                TextSpan(
                                  text: 'WAY',
                                  style: TextStyle(color: red),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'MATERIAL HANDLING SOLUTIONS',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _ScrollReveal(
                      delay: Duration(milliseconds: 90),
                      offset: Offset(-.08, 0),
                      child: Text(
                        'SMART SOLUTIONS FOR',
                        style: TextStyle(
                          color: red,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ScrollReveal(
                      delay: const Duration(milliseconds: 150),
                      offset: const Offset(-.08, 0),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: wide ? 54 : (compact ? 36 : 43),
                            fontWeight: FontWeight.w900,
                            height: 1.02,
                          ),
                          children: const [
                            TextSpan(text: 'MODERN\n'),
                            TextSpan(
                              text: 'INDUSTRIES',
                              style: TextStyle(color: red),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _ScrollReveal(
                      delay: const Duration(milliseconds: 210),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: const Text(
                          'We design and manufacture innovative material handling systems that improve efficiency and productivity.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: Color(0xFFD6DADD),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _ScrollReveal(
                      delay: const Duration(milliseconds: 270),
                      child: wide
                          ? Row(
                              children: [
                                _ActionButton(
                                  label: 'Get a Quote',
                                  filled: true,
                                  icon: Icons.chat_bubble_outline,
                                  onTap: () => onTap('Quote request started'),
                                ),
                                const SizedBox(width: 14),
                                _ActionButton(
                                  label: 'Explore Products',
                                  onTap: () => onTap('Products opened'),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Get a Quote',
                                    filled: true,
                                    compact: true,
                                    icon: Icons.chat_bubble_outline,
                                    onTap: () => onTap('Quote request started'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Explore Products',
                                    compact: true,
                                    onTap: () => onTap('Products opened'),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.filled = false,
    this.compact = false,
    this.icon,
  });
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool compact;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => _PressScale(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 20,
          vertical: compact ? 13 : 16,
        ),
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF3D44), red, Color(0xFFD0151F)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xA6050A0E), Color(0x7A0A1015)],
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: filled ? const Color(0xFFEA3943) : Colors.white38,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 17 : 18, color: Colors.white),
              SizedBox(width: compact ? 7 : 9),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(width: compact ? 7 : 9),
            const Icon(Icons.arrow_forward, size: 17, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}
