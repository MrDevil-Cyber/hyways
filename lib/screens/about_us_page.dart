part of '../main.dart';

class _AboutUsPage extends StatelessWidget {
  const _AboutUsPage();

  static const _clientLogos = [
    'assets/images/clients/official/itc.png',
    'assets/images/clients/official/perfetti.png',
    'assets/images/clients/client-03.webp',
    'assets/images/clients/official/akums.webp',
    'assets/images/clients/official/bikaji.png',
    'assets/images/clients/official/haldirams.webp',
    'assets/images/clients/official/dominos.png',
    'assets/images/clients/official/ds-group.png',
    'assets/images/clients/official/rr-kabel.png',
    'assets/images/clients/official/baba-logo-retail.png',
    'assets/images/clients/official/hmd.png',
    'assets/images/clients/official/goldiee.webp',
    'assets/images/clients/official/kwality.jpeg',
    'assets/images/clients/official/mother-dairy.png',
    'assets/images/clients/official/hitachi.png',
    'assets/images/clients/official/allana.png',
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: CustomScrollView(
      key: const PageStorageKey<String>('about-us-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScrollReveal(
                      scaleFrom: .94,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 16 / 11,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/category-conveyors.png',
                                fit: BoxFit.cover,
                              ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x33050A0E),
                                      Color(0xF2050A0E),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                top: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'ABOUT HYWAY',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              const Positioned(
                                left: 16,
                                right: 16,
                                bottom: 17,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Engineering Movement.\nEnabling Growth.',
                                      style: TextStyle(
                                        fontSize: 27,
                                        height: 1.05,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 9),
                                    Text(
                                      'Vertical Conveyor Systems & Material Handling Solutions',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        height: 1.3,
                                        fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 20),
                    const _SectionEyebrow('WHO WE ARE'),
                    const SizedBox(height: 7),
                    const _AboutSectionTitle(
                      'Built to Move Industries Forward',
                    ),
                    const SizedBox(height: 15),
                    const _StoryPoint(
                      number: '01',
                      title: 'Vertical Movement Specialists',
                      text:
                          'HYWAY Procons is a leading Vertical Conveyor Systems manufacturer. We design safe, high-performance systems that move goods efficiently across multiple floor levels while maximizing valuable floor space.',
                    ),
                    const _StoryPoint(
                      number: '02',
                      title: 'Complete Engineering Capability',
                      text:
                          'Our expertise includes Vertical Reciprocating Conveyors, Continuous Vertical Chain Conveyors and customized lifting solutions—from design and manufacturing through installation and after-sales support.',
                    ),
                    const _StoryPoint(
                      number: '03',
                      title: 'Smarter Internal Logistics',
                      text:
                          'Space-saving and energy-efficient systems improve workflow, reduce manual handling, increase productivity and streamline internal logistics through advanced technology and precision engineering.',
                    ),
                    const _StoryPoint(
                      number: '04',
                      title: 'Reliability Across Industries',
                      text:
                          'Robust components and strict quality checks deliver safety, durability and long service life across warehousing, logistics, manufacturing, e-commerce and distribution operations.',
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Expanded(
                          child: _AboutStat(
                            value: '120+',
                            label: 'Happy Customers',
                          ),
                        ),
                        SizedBox(width: 11),
                        Expanded(
                          child: _AboutStat(
                            value: '350+',
                            label: 'Succeeded Projects',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _DifferenceSpotlight(),
                    const SizedBox(height: 28),
                    const _SectionEyebrow('WHY CHOOSE US'),
                    const SizedBox(height: 7),
                    const _AboutSectionTitle('Engineering That Delivers More'),
                    const SizedBox(height: 15),
                    const _AboutFeature(
                      icon: Icons.verified_outlined,
                      title: 'Quality Engineering',
                      text:
                          'High-quality vertical and telescopic conveyors built with premium-grade materials for superior durability, load capacity and reliable industrial performance.',
                    ),
                    const _AboutFeature(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Food Safety',
                      text:
                          'Food-grade conveyor systems designed around hygiene standards and contamination control for safe, clean and efficient production environments.',
                    ),
                    const _AboutFeature(
                      icon: Icons.support_agent,
                      title: 'Expertise & Support',
                      text:
                          'Experienced engineers support design, customization, installation and after-sales service to reduce downtime and deliver long-term operational value.',
                    ),
                    const _AboutFeature(
                      icon: Icons.lightbulb_outline,
                      title: 'Continuous Innovation',
                      text:
                          'Advanced vertical conveyors, truck loading-unloading telescopic conveyors and washers that improve productivity across logistics, e-commerce and manufacturing.',
                    ),
                    const SizedBox(height: 14),
                    const _SectionEyebrow('OUR PURPOSE'),
                    const SizedBox(height: 7),
                    const _AboutSectionTitle('What Guides Every Solution'),
                    const SizedBox(height: 14),
                    const _PurposeCard(
                      icon: Icons.flag_outlined,
                      title: 'Our Mission',
                      text:
                          'To become the most trusted vertical conveyor specialist in the material handling industry, known for efficient, durable and scalable solutions.',
                    ),
                    const SizedBox(height: 11),
                    const _PurposeCard(
                      icon: Icons.visibility_outlined,
                      title: 'Our Vision',
                      text:
                          'To design and manufacture industrial vertical conveyor systems that solve real operational challenges, improve workflow, reduce manual handling and maximize space utilization.',
                    ),
                    const SizedBox(height: 11),
                    const _PurposeCard(
                      icon: Icons.favorite_border,
                      title: 'Our Value',
                      text:
                          'Quality, innovation and efficient vertical conveyor solutions that maximize performance and reliability guide every decision we make.',
                    ),
                    const SizedBox(height: 30),
                    const _CompanyInformation(),
                    const SizedBox(height: 30),
                    const Center(child: _AboutSectionTitle('Trusted By')),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Companies that rely on HYWAY solutions',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const _ScrollReveal(
                      scaleFrom: .95,
                      child: _ClientsMarquee(logos: _clientLogos),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    offset: const Offset(-.08, 0),
    child: Text(
      text,
      style: const TextStyle(
        color: red,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.7,
      ),
    ),
  );
}

class _StoryPoint extends StatelessWidget {
  const _StoryPoint({
    required this.number,
    required this.title,
    required this.text,
  });

  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    offset: const Offset(.08, 0),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 58,
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0x44E31B23),
                fontSize: 37,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 13),
                const Divider(height: 1, color: Colors.white10),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DifferenceSpotlight extends StatelessWidget {
  const _DifferenceSpotlight();

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    offset: const Offset(-.08, 0),
    child: Container(
      padding: const EdgeInsets.fromLTRB(18, 4, 0, 4),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: red, width: 3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionEyebrow('WHAT MAKES US DIFFERENT'),
          SizedBox(height: 7),
          Text(
            'Performance, Engineered Around You',
            style: TextStyle(
              fontSize: 23,
              height: 1.08,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 11),
          Text(
            'We go beyond supplying equipment. Every vertical conveyor is custom-engineered around your load capacity, building structure, workflow and application needs—improving throughput, reducing costs and maximizing space utilization.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.55),
          ),
          SizedBox(height: 9),
          Text(
            'Heavy-duty components, precision engineering and low-maintenance construction are supported by complete design, manufacturing, installation and after-sales service for a dependable end-to-end experience.',
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.55),
          ),
        ],
      ),
    ),
  );
}

class _CompanyInformation extends StatelessWidget {
  const _CompanyInformation();

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    child: Container(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = constraints.maxWidth >= 700
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _CompanySummary()),
                    SizedBox(width: 30),
                    Expanded(flex: 6, child: _ContactAndLocation()),
                  ],
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CompanySummary(),
                    _InfoDivider(),
                    _ContactAndLocation(),
                  ],
                );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              const SizedBox(height: 24),
              const Divider(height: 1, color: Colors.white12),
              const SizedBox(height: 17),
              const _UsefulLinks(),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Copyright (c) HYWAY Procons Pvt. Ltd. All Rights Reserved',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _ContactAndLocation extends StatelessWidget {
  const _ContactAndLocation();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 480) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoHeading('Contact & Location'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _CompanyContactDetails(showHeading: false)),
                SizedBox(width: 20),
                Expanded(child: _CompanyLocation(showHeading: false)),
              ],
            ),
          ],
        );
      }

      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompanyContactDetails(),
          SizedBox(height: 22),
          _CompanyLocation(),
        ],
      );
    },
  );
}

class _CompanySummary extends StatelessWidget {
  const _CompanySummary();

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    offset: const Offset(-.08, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 13),
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: red, width: 3)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HYWAY',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'MATERIAL HANDLING SOLUTIONS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        const Text(
          'HYWAY Procons Pvt. Ltd. is a leading provider of innovative and reliable automation solutions, offering products and services tailored to diverse industrial needs worldwide.',
          style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.55),
        ),
        const SizedBox(height: 13),
        const Row(
          children: [
            _SocialBadge(
              assetPath: 'assets/icons/social/facebook.svg',
              label: 'Facebook',
              color: Color(0xFF1877F2),
            ),
            SizedBox(width: 7),
            _SocialBadge(
              assetPath: 'assets/icons/social/x.svg',
              label: 'X',
              color: Color(0xFF000000),
            ),
            SizedBox(width: 7),
            _SocialBadge(
              assetPath: 'assets/icons/social/instagram.svg',
              label: 'Instagram',
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFEDA75), Color(0xFFD62976), Color(0xFF4F5BD5)],
              ),
            ),
            SizedBox(width: 7),
            _SocialBadge(
              assetPath: 'assets/icons/social/linkedin.svg',
              label: 'LinkedIn',
              color: Color(0xFF0A66C2),
            ),
          ],
        ),
      ],
    ),
  );
}

class _UsefulLinks extends StatelessWidget {
  const _UsefulLinks();

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Navigation',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 11),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: const Row(
            children: [
              _InfoLink('Home'),
              SizedBox(width: 8),
              _InfoLink('About Us'),
              SizedBox(width: 8),
              _InfoLink('Our Products'),
              SizedBox(width: 8),
              _InfoLink('Career'),
              SizedBox(width: 8),
              _InfoLink('Contact Us'),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CompanyContactDetails extends StatelessWidget {
  const _CompanyContactDetails({this.showHeading = true});

  final bool showHeading;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    offset: const Offset(.08, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading) const _InfoHeading('Contact Details'),
        const _InfoDetail(
          icon: Icons.location_on_outlined,
          title: 'Address',
          text:
              'ARR Food Machines\nPlot No. 33, Road No. 6, Indra Complex Industrial Area, Tigaon Road, Kheri, Faridabad 121002, India',
        ),
        const SizedBox(height: 14),
        const _InfoDetail(
          icon: Icons.email_outlined,
          title: 'Email ID',
          text: 'contact@arrfm.co.in\nashish@arrfm.co.in',
        ),
        const SizedBox(height: 14),
        const _InfoDetail(
          icon: Icons.phone_outlined,
          title: 'Phone No.',
          text:
              '0129-2229932, 4882024\n+91 9999229410, +91 9871158025\n+91 9355064166',
        ),
      ],
    ),
  );
}

class _CompanyLocation extends StatelessWidget {
  const _CompanyLocation({this.showHeading = true});

  final bool showHeading;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    scaleFrom: .95,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading) const _InfoHeading('Our Location'),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(
                      28.417481132503166,
                      77.33275676507778,
                    ),
                    initialZoom: 15.5,
                    minZoom: 4,
                    maxZoom: 19,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hyway.procons',
                    ),
                    MarkerLayer(
                      markers: const [
                        Marker(
                          point: LatLng(28.417481132503166, 77.33275676507778),
                          width: 48,
                          height: 48,
                          child: _PulseMapMarker(),
                        ),
                      ],
                    ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
                const IgnorePointer(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(9, 0, 9, 9),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xE6050A0E),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 7,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HYWAY Procons / ARR Food Machines',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tigaon Road, Kheri, Faridabad 121002',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _PulseMapMarker extends StatefulWidget {
  const _PulseMapMarker();

  @override
  State<_PulseMapMarker> createState() => _PulseMapMarkerState();
}

class _PulseMapMarkerState extends State<_PulseMapMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return const Icon(Icons.location_pin, color: red, size: 45);
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1 + (.45 * _controller.value),
              child: Opacity(
                opacity: .28 * (1 - _controller.value),
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: red, shape: BoxShape.circle),
                  child: SizedBox(width: 26, height: 26),
                ),
              ),
            ),
            Transform.scale(scale: 1 + (.06 * _controller.value), child: child),
          ],
        ),
        child: const Icon(Icons.location_pin, color: red, size: 45),
      ),
    );
  }
}

class _InfoHeading extends StatelessWidget {
  const _InfoHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    offset: const Offset(-.06, 0),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Container(width: 38, height: 2, color: red),
        ],
      ),
    ),
  );
}

class _InfoLink extends StatelessWidget {
  const _InfoLink(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => _PressScale(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF202126),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_forward, color: red, size: 13),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

class _InfoDetail extends StatelessWidget {
  const _InfoDetail({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    offset: const Offset(.06, 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: red, size: 21),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SocialBadge extends StatelessWidget {
  const _SocialBadge({
    required this.assetPath,
    required this.label,
    this.color,
    this.gradient,
  }) : assert(color != null || gradient != null);

  final String assetPath;
  final String label;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      button: true,
      label: label,
      child: Container(
        width: 31,
        height: 31,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          gradient: gradient,
          borderRadius: BorderRadius.circular(7),
        ),
        child: SvgPicture.asset(assetPath, excludeFromSemantics: true),
      ),
    ),
  );
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 22),
    child: Divider(height: 1, color: Colors.white12),
  );
}

class _ClientsMarquee extends StatefulWidget {
  const _ClientsMarquee({required this.logos});

  final List<String> logos;

  @override
  State<_ClientsMarquee> createState() => _ClientsMarqueeState();
}

class _ClientsMarqueeState extends State<_ClientsMarquee>
    with SingleTickerProviderStateMixin {
  static const _itemWidth = 126.0;
  static const _gap = 10.0;
  late final AnimationController _controller;

  double get _segmentWidth => widget.logos.length * (_itemWidth + _gap);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 38),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 62,
    child: ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(-_segmentWidth * _controller.value, 0),
          child: child,
        ),
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [..._buildLogoStrip(), ..._buildLogoStrip()],
          ),
        ),
      ),
    ),
  );

  List<Widget> _buildLogoStrip() => widget.logos
      .map(
        (logo) => Container(
          width: _itemWidth,
          height: 62,
          margin: const EdgeInsets.only(right: _gap),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white24),
          ),
          child: Image.asset(
            logo,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      )
      .toList(growable: false);
}

class _AboutSectionTitle extends StatelessWidget {
  const _AboutSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    child: Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
    ),
  );
}

class _AboutStat extends StatelessWidget {
  const _AboutStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    scaleFrom: .88,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0x44E31B23)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CountUpText(
            target: value.startsWith('120') ? 120 : 350,
            suffix: '+',
            style: const TextStyle(
              color: red,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    ),
  );
}

class _AboutFeature extends StatelessWidget {
  const _AboutFeature({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    offset: const Offset(.08, 0),
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(14, 15, 10, 15),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: red, width: 2),
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            alignment: Alignment.topLeft,
            child: Icon(icon, color: red, size: 24),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.45,
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

class _PurposeCard extends StatelessWidget {
  const _PurposeCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    offset: const Offset(-.06, 0),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 42, child: Icon(icon, color: red, size: 25)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: red,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.45,
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
