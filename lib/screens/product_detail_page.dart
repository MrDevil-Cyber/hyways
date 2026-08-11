part of '../main.dart';

class _ConveyorProduct {
  const _ConveyorProduct(this.name, this.description, this.image);

  final String name;
  final String description;
  final String image;
}

const _conveyorProducts = [
  _ConveyorProduct(
    'Continuous Vertical Chain Conveyor',
    'Continuous vertical movement for high-throughput multi-level lines.',
    'assets/images/vertical-chain-conveyor.png',
  ),
  _ConveyorProduct(
    'Cooling Conveyor',
    'Controlled product cooling with continuous, hygienic movement.',
    'assets/images/cooling-conveyor.png',
  ),
  _ConveyorProduct(
    'IQF Line Conveying',
    'Food-grade conveying engineered for IQF freezing lines.',
    'assets/images/iqf-line-conveying.png',
  ),
  _ConveyorProduct(
    'Knife Edge Conveyor',
    'Seamless small-product transfer across minimal conveyor gaps.',
    'assets/images/knife-edge-conveyor.png',
  ),
  _ConveyorProduct(
    'Roller Conveyor',
    'Reliable carton, crate and pallet movement for automated lines.',
    'assets/images/roller-conveyor.png',
  ),
  _ConveyorProduct(
    'Spiral Conveyor',
    'Continuous elevation change with a compact factory footprint.',
    'assets/images/subcategory-spiral-conveyor.png',
  ),
  _ConveyorProduct(
    'Screw Conveyor',
    'Enclosed and controlled transfer for powders and bulk materials.',
    'assets/images/screw-conveyor.png',
  ),
  _ConveyorProduct(
    'Belt Conveyor',
    'Flexible and hygienic transport for packaged or loose products.',
    'assets/images/belt-conveyor.png',
  ),
  _ConveyorProduct(
    'C-Type Vertical Chain Conveyor',
    'Continuous C-path lifting for crates and packaged goods.',
    'assets/images/c-type-vertical-chain-conveyor.png',
  ),
  _ConveyorProduct(
    'Z-Type',
    'Z-profile elevation with convenient infeed and discharge points.',
    'assets/images/z-type-conveyor.png',
  ),
  _ConveyorProduct(
    'L-Type',
    'Compact L-profile conveying for controlled product elevation.',
    'assets/images/l-type-conveyor.png',
  ),
  _ConveyorProduct(
    'Vertical Pallet Lifter',
    'Safe vertical transfer of loaded pallets between floor levels.',
    'assets/images/vertical-pallet-lifter.png',
  ),
  _ConveyorProduct(
    'Vertical Pallet Handling Conveyor',
    'Integrated lifting and roller conveying for automated pallet flow.',
    'assets/images/vertical-pallet-handling-conveyor.png',
  ),
];

const _mixerProducts = [
  _ConveyorProduct(
    'Cone Blender',
    'Gentle and uniform blending for powders and granular ingredients.',
    'assets/images/cone-blender.png',
  ),
  _ConveyorProduct(
    'ARM Blender',
    'High-performance mixing for dense and demanding food batches.',
    'assets/images/arm-blender.png',
  ),
  _ConveyorProduct(
    'Ribbon Blender',
    'Fast homogeneous mixing through a precision ribbon agitator.',
    'assets/images/ribbon-blender.png',
  ),
];

const _washerProducts = [
  _ConveyorProduct(
    'Crate Washer',
    'Automated hygienic washing for reusable crates and containers.',
    'assets/images/subcategory-crate-washer.png',
  ),
  _ConveyorProduct(
    'Pallet Washer',
    'Heavy-duty automated cleaning for industrial pallets.',
    'assets/images/pallet-washer.png',
  ),
];

const _snacksMachineProducts = [
  _ConveyorProduct(
    'Flavoring Drum',
    'Uniform seasoning and coating for consistent snack flavour.',
    'assets/images/flavoring-drum.png',
  ),
  _ConveyorProduct(
    'Fryer',
    'Continuous controlled frying for reliable product quality.',
    'assets/images/fryer.png',
  ),
  _ConveyorProduct(
    'Grading',
    'Accurate size grading for consistent downstream processing.',
    'assets/images/grading-machine.png',
  ),
  _ConveyorProduct(
    'Inspection',
    'Automated visual inspection for dependable product quality.',
    'assets/images/inspection-machine.png',
  ),
];

class _ProductDetailPage extends StatelessWidget {
  const _ProductDetailPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.image,
    this.showCatalogue = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final String image;
  final bool showCatalogue;

  List<_ConveyorProduct> get catalogueProducts => switch (title) {
    'Conveyors' => _conveyorProducts,
    'Mixer' => _mixerProducts,
    'Washer' => _washerProducts,
    'Snacks Machines' => _snacksMachineProducts,
    _ => const [],
  };

  String get catalogueHeading => switch (title) {
    'Conveyors' => 'Conveyor Solutions',
    'Mixer' => 'Industrial Blenders',
    'Washer' => 'Washing Solutions',
    'Snacks Machines' => 'Snacks Processing Machines',
    _ => title,
  };

  void _swipeCatalogue(BuildContext context, double velocity) {
    if (velocity.abs() < 250) return;

    final currentIndex = products.indexWhere((product) => product.$1 == title);
    if (currentIndex < 0) return;

    final step = velocity > 0 ? 1 : -1;
    final nextIndex = (currentIndex + step) % products.length;
    final nextProduct = products[nextIndex];

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _ProductDetailPage(
              title: nextProduct.$1,
              description: nextProduct.$2,
              icon: nextProduct.$3,
              image: nextProduct.$4,
              showCatalogue: true,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final begin = Offset(velocity > 0 ? -1 : 1, 0);
          return SlideTransition(
            position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          );
        },
      ),
    );
  }

  List<String> get additionalImages => switch (title) {
    'Conveyors' => const [
      'assets/images/spiral-conveyor.png',
      'assets/images/telescopic-conveyor.png',
      'assets/images/vertical-conveyor-front.png',
    ],
    'Washer' => const [
      'assets/images/crate-washer.png',
      'assets/images/crate-washer-entry.png',
      'assets/images/crate-washer-side.png',
      'assets/images/crate-washer-discharge.png',
    ],
    _ => const [],
  };

  List<String> get detailImages => [image, ...additionalImages];

  List<String> get features => switch (title) {
    'Conveyors' => [
      'Belt, roller, spiral and vertical conveyor solutions',
      'Efficient product movement across production areas',
      'Custom layouts for automated material handling',
    ],
    'Mixer' => [
      'Cone, arm and ribbon blender configurations',
      'Uniform blending with consistent batch quality',
      'Food-grade stainless-steel construction',
    ],
    'Washer' => [
      'Automated crate and pallet washing solutions',
      'Hygienic stainless-steel construction',
      'Consistent washing with reduced water consumption',
    ],
    'Snacks Machines' => [
      'Flavoring, frying, grading and inspection solutions',
      'Consistent processing for high-volume snack production',
      'Integrated hygienic production-line design',
    ],
    _ => [
      'Engineered around the required product and production flow',
      'Durable industrial construction for reliable daily operation',
      'Custom dimensions, controls and line integration available',
    ],
  };

  @override
  Widget build(BuildContext context) =>
      showCatalogue ? _buildCatalogue(context) : _buildDetailPage(context);

  Widget _buildCatalogue(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: ink,
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
    body: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) =>
          _swipeCatalogue(context, details.primaryVelocity ?? 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              MediaQuery.sizeOf(context).width < 380 ? 12 : 16,
              12,
              MediaQuery.sizeOf(context).width < 380 ? 12 : 16,
              32,
            ),
            children: [
              const _ScrollReveal(
                offset: Offset(-.08, 0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Divider(color: red, thickness: 2),
                    ),
                    SizedBox(width: 9),
                    Text(
                      'PRODUCT CATALOGUE',
                      style: TextStyle(
                        color: red,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              _ScrollReveal(
                delay: const Duration(milliseconds: 65),
                offset: const Offset(-.06, 0),
                child: Text(
                  catalogueHeading,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const _ScrollReveal(
                delay: Duration(milliseconds: 120),
                child: Text(
                  'Select a system to view specifications and request a quote.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _ScrollReveal(
                delay: const Duration(milliseconds: 170),
                child: Text(
                  'ALL ${title.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (
                var index = 0;
                index < catalogueProducts.length;
                index++
              ) ...[
                _ScrollReveal(
                  delay: Duration(milliseconds: index > 7 ? 320 : index * 45),
                  child: _buildSubProductCard(
                    context,
                    catalogueProducts[index],
                  ),
                ),
                if (index != catalogueProducts.length - 1)
                  const SizedBox(height: 11),
              ],
            ],
          ),
        ),
      ),
    ),
  );

  void _openSubProduct(BuildContext context, _ConveyorProduct product) =>
      Navigator.of(context).push(
        _AppPageRoute<void>(
          page: _ProductDetailPage(
            title: product.name,
            description: product.description,
            icon: Icons.precision_manufacturing_outlined,
            image: product.image,
          ),
        ),
      );

  Widget _buildSubProductCard(BuildContext context, _ConveyorProduct product) =>
      _PressScale(
        child: Material(
          color: panel,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openSubProduct(context, product),
            child: Container(
              height: 254,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF303A41), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: Hero(
                        tag: 'product-${product.name}',
                        child: Image.asset(product.image, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Container(height: 1, color: const Color(0x44E31B23)),
                  SizedBox(
                    height: 76,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 10, 8, 10),
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'View Details',
                                style: TextStyle(
                                  color: red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0x1AE31B23),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: const Color(0x66E31B23),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: red,
                                  size: 15,
                                ),
                              ),
                            ],
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
      );

  Widget _buildDetailPage(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: ink,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Product Details',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 380 ? 14 : 20,
            8,
            MediaQuery.sizeOf(context).width < 380 ? 14 : 20,
            32,
          ),
          children: [
            _ScrollReveal(
              scaleFrom: .94,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: detailImages.length > 1 ? null : 1,
                        itemBuilder: (_, index) {
                          final imageWidget = Image.asset(
                            detailImages[index % detailImages.length],
                            fit: BoxFit.cover,
                          );
                          final content = index == 0
                              ? Hero(tag: 'product-$title', child: imageWidget)
                              : imageWidget;
                          return _ScrollReveal(
                            offset: const Offset(.08, 0),
                            scaleFrom: 1.04,
                            duration: const Duration(milliseconds: 360),
                            child: content,
                          );
                        },
                      ),
                      if (detailImages.length > 1)
                        Positioned(
                          right: 12,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xCC050A0E),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.swipe, color: red, size: 15),
                                SizedBox(width: 5),
                                Text(
                                  'Swipe',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            _ScrollReveal(
              offset: const Offset(-.08, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: const BoxDecoration(
                      color: red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 23),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _ScrollReveal(
              delay: const Duration(milliseconds: 70),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 26),
            const _ScrollReveal(
              child: Text(
                'KEY FEATURES',
                style: TextStyle(
                  color: red,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...features.asMap().entries.map(
              (entry) => _ScrollReveal(
                delay: Duration(milliseconds: entry.key * 65),
                offset: const Offset(.08, 0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: red, size: 19),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ScrollReveal(
              child: _PressScale(
                child: FilledButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Quote request started for $title'),
                      backgroundColor: red,
                    ),
                  ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Request a Quote'),
                  style: FilledButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
