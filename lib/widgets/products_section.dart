part of '../main.dart';

class _Products extends StatelessWidget {
  const _Products();

  void _openProduct(
    BuildContext context,
    (String, String, IconData, String) product,
  ) {
    Navigator.of(context).push(
      _AppPageRoute<void>(
        page: _ProductDetailPage(
          title: product.$1,
          description: product.$2,
          icon: product.$3,
          image: product.$4,
          showCatalogue: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 242,
    child: ListView.separated(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(width: 7),
      itemBuilder: (context, i) {
        final p = products[i];
        return _ScrollReveal(
          delay: Duration(milliseconds: i * 55),
          offset: const Offset(.14, 0),
          child: _PressScale(
            child: InkWell(
              onTap: () => _openProduct(context, p),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: (MediaQuery.sizeOf(context).width * .44).clamp(
                  158.0,
                  178.0,
                ),
                height: 230,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF151C21), Color(0xFF0D1216)],
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x99000000),
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                    BoxShadow(color: Color(0x22E31B23), blurRadius: 8),
                  ],
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: const Color(0xFF303A41),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 126,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: [
                          Hero(
                            tag: 'product-${p.$1}',
                            child: Image.asset(
                              p.$4,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0x99050A0E)],
                                stops: [.55, 1],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 1,
                              color: const Color(0x33E31B23),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Transform.translate(
                              offset: const Offset(0, 17),
                              child: Container(
                                margin: const EdgeInsets.only(left: 11),
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(p.$3, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 20, 12, 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    p.$1,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(height: 2, color: red),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _openProduct(context, p),
                                style: TextButton.styleFrom(
                                  foregroundColor: red,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 22),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  textStyle: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                label: const Text('See All'),
                                icon: const Icon(Icons.arrow_forward, size: 14),
                                iconAlignment: IconAlignment.end,
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
        );
      },
    ),
  );
}
