part of '../main.dart';

class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  Widget _statItem(int index, {required bool compact}) {
    final stat = stats[index];
    return Expanded(
      child: _ScrollReveal(
        delay: Duration(milliseconds: 70 * index),
        offset: const Offset(0, .20),
        scaleFrom: .82,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(stat.$1, color: red, size: compact ? 19 : 22),
            SizedBox(width: compact ? 4 : 7),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index < 2)
                    _CountUpText(
                      target: index == 0 ? 10 : 350,
                      suffix: '+',
                      style: TextStyle(
                        fontSize: compact ? 11.5 : 13.5,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    Text(
                      stat.$2,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: compact ? 11.5 : 13.5,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 3),
                  Text(
                    stat.$3,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: compact ? 6.8 : 8,
                      height: 1.15,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 31,
    margin: const EdgeInsets.symmetric(horizontal: 3),
    color: Colors.white12,
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Container(
          height: compact ? 70 : 76,
          padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 14),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white12),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
          ),
          child: Row(
            children: [
              _statItem(0, compact: compact),
              _divider(),
              _statItem(1, compact: compact),
              _divider(),
              _statItem(2, compact: compact),
              _divider(),
              _statItem(3, compact: compact),
            ],
          ),
        ),
      );
    },
  );
}
