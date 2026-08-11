part of 'main.dart';

const red = Color(0xFFE31B23);
const ink = Color(0xFF050A0E);
const panel = Color(0xFF10161B);
const kBottomNavInset = 132.0;

class Hyway extends StatelessWidget {
  const Hyway({super.key, this.servicesApi});

  final HywayApi? servicesApi;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'HYWAY Procons',
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: ink,
      colorScheme: const ColorScheme.dark(primary: red),
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Arial'),
    ),
    home: _StartupSplash(servicesApi: servicesApi),
  );
}

class _StartupSplash extends StatefulWidget {
  const _StartupSplash({this.servicesApi});

  final HywayApi? servicesApi;

  @override
  State<_StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<_StartupSplash> {
  var _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 280),
    child: _showSplash
        ? const ColoredBox(
            key: ValueKey('hyway-startup-splash'),
            color: Color(0xFFE60000),
            child: Center(
              child: Image(
                image: AssetImage('assets/images/hyway_splash.png'),
                fit: BoxFit.contain,
              ),
            ),
          )
        : LandingPage(
            key: const ValueKey('hyway-landing-page'),
            servicesApi: widget.servicesApi,
          ),
  );
}
