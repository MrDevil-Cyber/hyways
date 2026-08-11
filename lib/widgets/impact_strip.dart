// ignore_for_file: unused_element

part of '../main.dart';

class _ImpactStrip extends StatelessWidget {
  const _ImpactStrip();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 700 ? 4 : 2;
      return _Glass(
        color: const Color(0xFF36070A),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: GridView.count(
          padding: EdgeInsets.zero,
          primary: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisExtent: 54,
          mainAxisSpacing: columns == 2 ? 10 : 0,
          children: const [
            _Impact(
              Icons.workspace_premium_outlined,
              '10+',
              'Years Experience',
            ),
            _Impact(
              Icons.precision_manufacturing_outlined,
              '350+',
              'Installations',
            ),
            _Impact(Icons.location_on_outlined, 'PAN India', 'Service Network'),
            _Impact(Icons.groups_outlined, '100%', 'Customer Satisfaction'),
          ],
        ),
      );
    },
  );
}

class _Impact extends StatelessWidget {
  const _Impact(this.icon, this.value, this.label);

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: red, size: 33),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 8, color: Colors.white70),
            ),
          ],
        ),
      ),
    ],
  );
}
