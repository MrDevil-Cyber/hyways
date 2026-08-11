// ignore_for_file: unused_element

part of '../main.dart';

class _WhyChoose extends StatelessWidget {
  const _WhyChoose();

  Widget _reasonItem(int index, {required bool bottomBorder}) {
    final reason = reasons[index];
    final isLastColumn = index % 3 == 2;
    return Expanded(
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          border: Border(
            right: isLastColumn
                ? BorderSide.none
                : const BorderSide(color: Colors.white12),
            bottom: bottomBorder
                ? const BorderSide(color: Colors.white12)
                : BorderSide.none,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(reason.$1, color: red, size: 29),
            const SizedBox(height: 9),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text(
                reason.$2,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 10.5,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD9DEE1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const _Title('WHY CHOOSE ', 'HYWAY?'),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _reasonItem(0, bottomBorder: true),
                _reasonItem(1, bottomBorder: true),
                _reasonItem(2, bottomBorder: true),
              ],
            ),
            Row(
              children: [
                _reasonItem(3, bottomBorder: false),
                _reasonItem(4, bottomBorder: false),
                _reasonItem(5, bottomBorder: false),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
