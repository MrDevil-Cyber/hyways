part of '../main.dart';

class _ProductsHubPage extends StatelessWidget {
  const _ProductsHubPage({required this.onClose});

  final VoidCallback onClose;

  static const _categories = [
    ('Conveyors', Icons.precision_manufacturing_outlined, _conveyorProducts),
    ('Mixer', Icons.blender_outlined, _mixerProducts),
    ('Washer', Icons.water_drop_outlined, _washerProducts),
    ('Snacks Machines', Icons.fastfood_outlined, _snacksMachineProducts),
  ];

  void _openProduct(
    BuildContext context,
    _ConveyorProduct product,
    IconData icon,
  ) => Navigator.of(context).push(
    _AppPageRoute<void>(
      page: _ProductDetailPage(
        title: product.name,
        description: product.description,
        icon: icon,
        image: product.image,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: _categories.length,
    animationDuration: const Duration(milliseconds: 240),
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScrollReveal(
            offset: const Offset(0, -.08),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 13),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Our Products',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Explore Our Range',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: .3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _PressScale(
                    pressedScale: .90,
                    child: IconButton.filledTonal(
                      onPressed: onClose,
                      style: IconButton.styleFrom(
                        backgroundColor: panel,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _ScrollReveal(
            delay: Duration(milliseconds: 80),
            child: _ProductCategorySwitcher(categories: _categories),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: [
                for (var index = 0; index < _categories.length; index++)
                  _SwipeAnimatedProductsPage(
                    index: index,
                    child: _ProductsTab(
                      title: _categories[index].$1,
                      icon: _categories[index].$2,
                      products: _categories[index].$3,
                      onOpen: (product) => _openProduct(
                        context,
                        product,
                        _categories[index].$2,
                      ),
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

class _SwipeAnimatedProductsPage extends StatelessWidget {
  const _SwipeAnimatedProductsPage({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = DefaultTabController.of(context).animation!;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final distance = (animation.value - index)
            .abs()
            .clamp(0.0, 1.0)
            .toDouble();
        final progress = Curves.easeOutCubic.transform(1 - distance);
        return Opacity(
          opacity: .32 + (.68 * progress),
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - progress)),
            child: Transform.scale(
              scale: .94 + (.06 * progress),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _ProductCategorySwitcher extends StatelessWidget {
  const _ProductCategorySwitcher({required this.categories});

  final List<(String, IconData, List<_ConveyorProduct>)> categories;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    final pageAnimation = controller.animation!;
    return SizedBox(
      height: 76,
      child: AnimatedBuilder(
        animation: pageAnimation,
        builder: (context, _) {
          final position = pageAnimation.value
              .clamp(0.0, categories.length - 1.0)
              .toDouble();
          return LayoutBuilder(
            builder: (context, constraints) {
              const horizontalPadding = 10.0;
              final itemWidth =
                  (constraints.maxWidth - (horizontalPadding * 2)) /
                  categories.length;
              final fraction = position - position.floorToDouble();
              final stretch = 1 - ((fraction * 2) - 1).abs();
              final blobWidth = 42 + (22 * stretch);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left:
                        horizontalPadding +
                        (itemWidth * position) +
                        ((itemWidth - blobWidth) / 2),
                    top: -5,
                    child: Container(
                      width: blobWidth,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF3038), red],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x77E31B23),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var index = 0; index < categories.length; index++)
                          Expanded(
                            child: _CategoryShortcut(
                              category: categories[index],
                              progress: (1 - (position - index).abs())
                                  .clamp(0.0, 1.0)
                                  .toDouble(),
                              onTap: () => controller.animateTo(index),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  const _CategoryShortcut({
    required this.category,
    required this.progress,
    required this.onTap,
  });

  final (String, IconData, List<_ConveyorProduct>) category;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = progress > .5;
    final iconColor = Color.lerp(Colors.white54, Colors.white, progress)!;
    final labelColor = Color.lerp(Colors.white54, Colors.white, progress)!;
    final transitionTilt = progress * (1 - progress) * .8;

    return InkResponse(
      onTap: onTap,
      radius: 34,
      child: Transform.translate(
        offset: Offset(0, -5 * progress),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: .88 + (.20 * progress),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFF151C21,
                  ).withValues(alpha: 1 - progress),
                  border: Border.all(
                    color: Color.lerp(
                      const Color(0xFF303A41),
                      Colors.transparent,
                      progress,
                    )!,
                  ),
                ),
                child: Transform.rotate(
                  angle: transitionTilt,
                  child: Icon(category.$2, size: 19, color: iconColor),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.$1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: labelColor.withValues(alpha: .62 + (.38 * progress)),
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsTab extends StatefulWidget {
  const _ProductsTab({
    required this.title,
    required this.icon,
    required this.products,
    required this.onOpen,
  });

  final String title;
  final IconData icon;
  final List<_ConveyorProduct> products;
  final ValueChanged<_ConveyorProduct> onOpen;

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.separated(
      key: PageStorageKey<String>('products-tab-${widget.title}'),
      // Keep the final card scrollable above the floating bottom navigation
      // without leaving an empty panel below the complete product list.
      padding: const EdgeInsets.fromLTRB(14, 10, 14, kBottomNavInset),
      itemCount: widget.products.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(3, 3, 3, 2),
            child: Row(
              children: [
                Icon(widget.icon, color: red, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.title} Collection',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.products.length} Products',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          );
        }

        final product = widget.products[index - 1];
        return _ProductHubCard(
          key: ValueKey<String>('product-card-${product.name}'),
          product: product,
          onOpen: () => widget.onOpen(product),
        );
      },
    );
  }
}

class _ProductHubCard extends StatefulWidget {
  const _ProductHubCard({
    super.key,
    required this.product,
    required this.onOpen,
  });

  final _ConveyorProduct product;
  final VoidCallback onOpen;

  @override
  State<_ProductHubCard> createState() => _ProductHubCardState();
}

class _ProductHubCardState extends State<_ProductHubCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final product = widget.product;
    return RepaintBoundary(
      child: _PressScale(
        child: Material(
          color: panel,
          borderRadius: BorderRadius.circular(17),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onOpen,
            child: Container(
              height: 238,
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFF303A41), width: 1.1),
              ),
              child: Column(
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
                    height: 66,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0x1FE31B23),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0x66E31B23),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: red,
                              size: 17,
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
      ),
    );
  }
}
