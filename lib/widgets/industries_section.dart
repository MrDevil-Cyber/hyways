part of '../main.dart';

class _Industries extends StatelessWidget {
  const _Industries();

  Widget _industryItem(int index, {required bool bottomBorder}) {
    final industry = industries[index];
    final rightBorder = index % 3 != 2;

    return Expanded(
      child: Container(
        height: 104,
        decoration: BoxDecoration(
          border: Border(
            right: rightBorder
                ? const BorderSide(color: Color(0x55E31B23))
                : BorderSide.none,
            bottom: bottomBorder
                ? const BorderSide(color: Color(0x55E31B23))
                : BorderSide.none,
          ),
        ),
        child: _PressScale(
          pressedScale: .94,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(industry.$1, color: red, size: 30),
              const SizedBox(height: 9),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  industry.$2,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD9DEE1),
                    fontSize: 10,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _industryItem(0, bottomBorder: true),
              _industryItem(1, bottomBorder: true),
              _industryItem(2, bottomBorder: true),
            ],
          ),
          Row(
            children: [
              _industryItem(3, bottomBorder: false),
              _industryItem(4, bottomBorder: false),
              _industryItem(5, bottomBorder: false),
            ],
          ),
        ],
      ),
    ),
  );
}
