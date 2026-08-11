part of '../main.dart';

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.onTap});
  final ValueChanged<String> onTap;

  Widget _intro() => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 420),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScrollReveal(
          offset: const Offset(-.08, 0),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
              children: [
                TextSpan(text: 'Ready to Build Your Next\n'),
                TextSpan(
                  text: 'Automation Project?',
                  style: TextStyle(color: red),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _ScrollReveal(
          delay: Duration(milliseconds: 80),
          offset: Offset(-.08, 0),
          child: Text(
            "Let's create a solution that drives efficiency and growth for your business.",
            style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.5),
          ),
        ),
        const SizedBox(height: 15),
        _ScrollReveal(
          delay: const Duration(milliseconds: 150),
          offset: const Offset(-.08, 0),
          child: _ActionButton(
            label: 'Request a Quote',
            filled: true,
            onTap: () => onTap('Quote request started'),
          ),
        ),
      ],
    ),
  );

  Widget _contactDetails() => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 320),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Contact(Icons.phone_outlined, '0129-2229932  |  +91 9999229410'),
        _Contact(
          Icons.mail_outline,
          'contact@arrfm.co.in',
          delay: Duration(milliseconds: 70),
        ),
        _Contact(
          Icons.location_on_outlined,
          'Indra Complex, Tigaon Road, Faridabad',
          delay: Duration(milliseconds: 140),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => _Glass(
    padding: EdgeInsets.zero,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/industrial-hero.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              color: const Color(0xAA000000),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              return Padding(
                padding: EdgeInsets.all(wide ? 30 : 22),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _intro()),
                          const SizedBox(width: 56),
                          Expanded(child: _contactDetails()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _intro(),
                          const SizedBox(height: 24),
                          _contactDetails(),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _Contact extends StatelessWidget {
  const _Contact(this.icon, this.text, {this.delay = Duration.zero});
  final IconData icon;
  final String text;
  final Duration delay;
  @override
  Widget build(BuildContext context) => _ScrollReveal(
    delay: delay,
    offset: const Offset(.08, 0),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
