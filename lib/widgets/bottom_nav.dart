part of '../main.dart';

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selected, required this.onTap});

  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            label: 'Home',
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            active: selected == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            label: 'Products',
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2,
            active: selected == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            label: 'Services',
            icon: Icons.miscellaneous_services_outlined,
            selectedIcon: Icons.miscellaneous_services,
            active: selected == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            label: 'About Us',
            icon: Icons.business_outlined,
            selectedIcon: Icons.business,
            active: selected == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 520;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: active ? 112 : 48,
          height: 48,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2B3238) : const Color(0xFF151B20),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? const Color(0x66FFFFFF) : const Color(0x1FFFFFFF),
            ),
          ),
          child: active
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NavIcon(
                      icon: selectedIcon,
                      color: red,
                      compact: compact,
                      valueKey: '$label-active',
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 11.5 : 12.5,
                          height: 1.05,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: _NavIcon(
                    icon: icon,
                    color: Colors.white70,
                    compact: compact,
                    valueKey: '$label-inactive',
                  ),
                ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.color,
    required this.compact,
    required this.valueKey,
  });

  final IconData icon;
  final Color color;
  final bool compact;
  final String valueKey;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 180),
    transitionBuilder: (child, animation) => ScaleTransition(
      scale: animation,
      child: FadeTransition(opacity: animation, child: child),
    ),
    child: Icon(
      icon,
      key: ValueKey(valueKey),
      color: color,
      size: compact ? 24 : 26,
    ),
  );
}
