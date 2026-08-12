part of '../main.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, this.servicesApi});

  final HywayApi? servicesApi;
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int tab = 0;
  final List<int> _tabHistory = [];
  bool _productsVisited = false;
  bool _servicesVisited = false;
  bool _aboutVisited = false;
  late final Widget _productsPage;
  late final HywayApi _servicesApi;
  late final Widget _servicesPage;
  late final bool _ownsServicesApi;

  @override
  void initState() {
    super.initState();
    _productsPage = _ProductsHubPage(onClose: _showHome);
    _ownsServicesApi = widget.servicesApi == null;
    _servicesApi = widget.servicesApi ?? HywayApi();
    _servicesPage = _ServicesPage(api: _servicesApi);
    unawaited(_servicesApi.restoreSession());
  }

  @override
  void dispose() {
    if (_ownsServicesApi) _servicesApi.dispose();
    super.dispose();
  }

  void _showHome() {
    if (tab != 0) {
      setState(() {
        _tabHistory.add(tab);
        tab = 0;
      });
    }
  }

  void toast(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value), backgroundColor: red));

  void _handleHeroAction(String value) {
    if (value == 'Products opened') {
      setState(() {
        tab = 1;
        _productsVisited = true;
      });
      return;
    }
    if (value == 'Quote request started') {
      setState(() {
        tab = 2;
        _servicesVisited = true;
      });
      return;
    }
    toast(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_tabHistory.isNotEmpty) {
            setState(() => tab = _tabHistory.removeLast());
            return;
          }
          if (tab != 0) {
            setState(() => tab = 0);
            return;
          }
          SystemNavigator.pop();
        },
        child: IndexedStack(
          index: tab,
          children: [
            _AnimatedTabPage(
              active: tab == 0,
              child: CustomScrollView(
                key: const PageStorageKey<String>('home-scroll'),
                slivers: [
                  SliverToBoxAdapter(child: _Hero(onTap: _handleHeroAction)),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, kBottomNavInset),
                          child: Column(
                            children: [
                              const SizedBox(height: 26),
                              const _ScrollReveal(
                                child: _Title('OUR ', 'PRODUCTS'),
                              ),
                              const SizedBox(height: 18),
                              const _ScrollReveal(
                                delay: Duration(milliseconds: 80),
                                child: _Products(),
                              ),
                              const SizedBox(height: 32),
                              const _ScrollReveal(
                                child: _Title('INDUSTRIES ', 'WE SERVE'),
                              ),
                              const SizedBox(height: 16),
                              const _ScrollReveal(
                                delay: Duration(milliseconds: 70),
                                child: _Industries(),
                              ),
                              const SizedBox(height: 24),
                              const _ScrollReveal(child: _StatsStrip()),
                              const SizedBox(height: 28),
                              _ScrollReveal(child: _ContactCard(onTap: toast)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _AnimatedTabPage(
              active: tab == 1,
              child: _productsVisited ? _productsPage : const SizedBox.shrink(),
            ),
            _AnimatedTabPage(
              active: tab == 2,
              child: _servicesVisited ? _servicesPage : const SizedBox.shrink(),
            ),
            _AnimatedTabPage(
              active: tab == 3,
              child: _aboutVisited
                  ? const _AboutUsPage()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: ColoredBox(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: _BottomNav(
            selected: tab,
            onTap: (i) {
              if (i != tab) {
                setState(() {
                  _tabHistory.add(tab);
                  tab = i;
                  if (i == 1) _productsVisited = true;
                  if (i == 2) _servicesVisited = true;
                  if (i == 3) _aboutVisited = true;
                });
              } else {
                // Already selected; keep silent to avoid noisy UI.
              }
            },
          ),
        ),
      ),
    );
  }
}
