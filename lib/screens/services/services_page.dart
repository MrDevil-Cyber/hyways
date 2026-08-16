part of '../../main.dart';

enum _ServiceJourney { dashboard, request, scan, planner }

class _ServicesPage extends StatefulWidget {
  const _ServicesPage({required this.api});

  final HywayApi api;

  @override
  State<_ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<_ServicesPage> {
  _ServiceJourney _journey = _ServiceJourney.dashboard;

  @override
  void initState() {
    super.initState();
    widget.api.addListener(_onAuthChanged);
  }

  @override
  void didUpdateWidget(covariant _ServicesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.api, widget.api)) {
      oldWidget.api.removeListener(_onAuthChanged);
      widget.api.addListener(_onAuthChanged);
    }
  }

  void _onAuthChanged() {
    if (!mounted) return;
    setState(() {
      if (!widget.api.isAuthenticated) {
        _journey = _ServiceJourney.dashboard;
      }
    });
  }

  void _open(_ServiceJourney journey) => setState(() => _journey = journey);

  Future<void> _logout() async {
    if (mounted) setState(() => _journey = _ServiceJourney.dashboard);
    await widget.api.logout();
  }

  @override
  void dispose() {
    widget.api.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.api.session;
    final content = widget.api.restoring
        ? const _ServicesSessionRestoring(key: ValueKey('services-restoring'))
        : session == null
        ? _ServicesAuthGate(
            key: const ValueKey('services-auth'),
            api: widget.api,
          )
        : switch (_journey) {
            _ServiceJourney.dashboard => _ServicesDashboard(
              key: const ValueKey('services-dashboard'),
              session: session,
              onOpen: _open,
              onLogout: () => unawaited(_logout()),
            ),
            _ServiceJourney.request => _ServiceRequestFlow(
              key: const ValueKey('service-request'),
              api: widget.api,
              onClose: () => _open(_ServiceJourney.dashboard),
            ),
            _ServiceJourney.scan => _MachineScanFlow(
              key: const ValueKey('machine-scan'),
              api: widget.api,
              onClose: () => _open(_ServiceJourney.dashboard),
            ),
            _ServiceJourney.planner => _SpacePlannerFlow(
              key: const ValueKey('space-planner'),
              api: widget.api,
              onClose: () => _open(_ServiceJourney.dashboard),
            ),
          };

    return SafeArea(
      bottom: false,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.035, .015),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: content,
      ),
    );
  }
}

class _ServicesSessionRestoring extends StatelessWidget {
  const _ServicesSessionRestoring({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            children: [
              TextSpan(text: 'HY'),
              TextSpan(
                text: 'WAY',
                style: TextStyle(color: red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: red, strokeWidth: 2.4),
        ),
        const SizedBox(height: 12),
        const Text(
          'Restoring your secure session...',
          style: TextStyle(color: Colors.white54, fontSize: 11.5),
        ),
      ],
    ),
  );
}

class _ServicesAuthGate extends StatefulWidget {
  const _ServicesAuthGate({super.key, required this.api});

  final HywayApi api;

  @override
  State<_ServicesAuthGate> createState() => _ServicesAuthGateState();
}

class _ServicesAuthGateState extends State<_ServicesAuthGate> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _register = false;
  bool _obscurePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectMode(bool register) {
    if (_register == register || _busy) return;
    setState(() {
      _register = register;
      _error = null;
    });
  }

  void _showPopup(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (_register) {
        await widget.api.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          phone: _phoneController.text.trim(),
          company: _companyController.text.trim(),
          jobTitle: _jobTitleController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await widget.api.login(
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
        );
      }
    } on _ApiException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
        _showPopup(error.message);
      }
    } catch (error, stackTrace) {
      debugPrint('HYWAY authentication failed: $error\n$stackTrace');
      if (mounted) {
        const message =
            'Authentication failed. Please check the backend response or logs.';
        setState(() => _error = message);
        _showPopup(message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const PageStorageKey<String>('services-auth-scroll'),
    padding: const EdgeInsets.fromLTRB(18, 14, 18, kBottomNavInset),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ServiceBrandHeader(),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A2025), Color(0xFF0D1216)],
                ),
                border: Border.all(color: const Color(0xFF303940)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0x22E31B23),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x66E31B23)),
                        ),
                        child: const Icon(
                          Icons.engineering_outlined,
                          color: red,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Services',
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const _ServiceAuthVisual(),
                  const SizedBox(height: 18),
                  const Text(
                    'Keep your machines moving.',
                    style: TextStyle(
                      fontSize: 27,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.5,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Sign in to identify a machine, build a technician-ready service request, or plan the right machine for your space.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _AuthModeSwitch(register: _register, onChanged: _selectMode),
                  const SizedBox(height: 18),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: _register
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    children: [
                                      _ServiceTextField(
                                        controller: _nameController,
                                        label: 'Full name',
                                        hint: 'Enter your name',
                                        icon: Icons.person_outline,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) =>
                                            (value?.trim().length ?? 0) < 2
                                            ? 'Please enter your full name'
                                            : null,
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        _ServiceTextField(
                          controller: _emailController,
                          label: 'Email address',
                          hint: 'you@company.com',
                          icon: Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            return email.contains('@') && email.contains('.')
                                ? null
                                : 'Please enter a valid email';
                          },
                        ),
                        const SizedBox(height: 12),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: _register
                              ? Column(
                                  children: [
                                    _ServiceTextField(
                                      controller: _phoneController,
                                      label: 'Mobile number',
                                      hint: '+91 98765 43210',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) =>
                                          RegExp(
                                            r'^[0-9+()\-\s]{7,20}$',
                                          ).hasMatch(value?.trim() ?? '')
                                          ? null
                                          : 'Please enter a valid mobile number',
                                    ),
                                    const SizedBox(height: 12),
                                    _ServiceTextField(
                                      controller: _companyController,
                                      label: 'Company name',
                                      hint: 'Your organisation',
                                      icon: Icons.business_outlined,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) =>
                                          (value?.trim().length ?? 0) < 2
                                          ? 'Please enter your company name'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    _ServiceTextField(
                                      controller: _jobTitleController,
                                      label: 'Job title',
                                      hint: 'For example, Plant Manager',
                                      icon: Icons.badge_outlined,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) =>
                                          (value?.trim().length ?? 0) < 2
                                          ? 'Please enter your job title'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ServiceTextField(
                                            controller: _cityController,
                                            label: 'City',
                                            hint: 'Your city',
                                            icon: Icons.location_city_outlined,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: (value) =>
                                                (value?.trim().length ?? 0) < 2
                                                ? 'Enter your city'
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _ServiceTextField(
                                            controller: _stateController,
                                            label: 'State',
                                            hint: 'Your state',
                                            icon: Icons.map_outlined,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: (value) =>
                                                (value?.trim().length ?? 0) < 2
                                                ? 'Enter your state'
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        _ServiceTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Minimum 8 characters',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 19,
                            ),
                          ),
                          validator: (value) => (value?.length ?? 0) < 8
                              ? 'Password must contain at least 8 characters'
                              : null,
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 180),
                          child: _error == null
                              ? const SizedBox(height: 18)
                              : Padding(
                                  padding: const EdgeInsets.only(top: 13),
                                  child: _InlineMessage(
                                    icon: Icons.error_outline,
                                    message: _error!,
                                    color: const Color(0xFFFF6A70),
                                  ),
                                ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _busy ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: red,
                              disabledBackgroundColor: const Color(0x66E31B23),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            icon: _busy
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _register
                                        ? Icons.person_add_alt_1
                                        : Icons.login,
                                    size: 19,
                                  ),
                            label: Text(
                              _busy
                                  ? 'Please wait...'
                                  : (_register
                                        ? 'Create account'
                                        : 'Log in securely'),
                            ),
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
  );
}

class _ServiceBrandHeader extends StatelessWidget {
  const _ServiceBrandHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          children: [
            TextSpan(text: 'HY'),
            TextSpan(
              text: 'WAY',
              style: TextStyle(color: red),
            ),
          ],
        ),
      ),
      const SizedBox(width: 10),
      Container(width: 1, height: 18, color: Colors.white24),
      const SizedBox(width: 10),
      const Text(
        'SERVICE HUB',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    ],
  );
}

class _ServiceAuthVisual extends StatelessWidget {
  const _ServiceAuthVisual();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 300;
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: compact ? 136 : 158,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/industrial-hero.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                cacheWidth: 900,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFF151B20),
                  child: Center(
                    child: Icon(
                      Icons.precision_manufacturing_outlined,
                      color: Colors.white24,
                      size: 42,
                    ),
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x11000000),
                      Color(0x5504080B),
                      Color(0xF2080C0F),
                    ],
                    stops: [0, .42, 1],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xD90A0E11),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x66E31B23)),
                  ),
                  child: const Text(
                    'HYWAY AFTER-SALES',
                    style: TextStyle(
                      color: red,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 13,
                right: 13,
                bottom: 12,
                child: Text(
                  'Industrial support, from first clue to final resolution.',
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 13.5 : 15,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _AuthModeSwitch extends StatelessWidget {
  const _AuthModeSwitch({required this.register, required this.onChanged});

  final bool register;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 43,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0xFF080C0F),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(
      children: [
        _AuthModeButton(
          label: 'Log in',
          selected: !register,
          onTap: () => onChanged(false),
        ),
        _AuthModeButton(
          label: 'Register',
          selected: register,
          onTap: () => onChanged(true),
        ),
      ],
    ),
  );
}

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF242B30) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white38,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

class _ServicesDashboard extends StatelessWidget {
  const _ServicesDashboard({
    super.key,
    required this.session,
    required this.onOpen,
    required this.onLogout,
  });

  final _AuthSession session;
  final ValueChanged<_ServiceJourney> onOpen;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: const PageStorageKey<String>('services-dashboard-scroll'),
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, kBottomNavInset),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: _ServiceBrandHeader()),
                      PopupMenuButton<String>(
                        tooltip: 'Account',
                        onSelected: (value) {
                          if (value == 'logout') onLogout();
                        },
                        offset: const Offset(0, 46),
                        constraints: const BoxConstraints(minWidth: 270),
                        color: panel,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.white12),
                        ),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            height: 0,
                            padding: EdgeInsets.zero,
                            child: _ServiceProfileSummary(session: session),
                          ),
                          const PopupMenuDivider(height: 1),
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: red,
                                  size: 18,
                                ),
                                SizedBox(width: 9),
                                Text(
                                  'Log out',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: panel,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                session.name.trim().isEmpty
                                    ? 'H'
                                    : session.name.trim()[0].toUpperCase(),
                                style: const TextStyle(
                                  color: red,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CD68B),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: panel, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ServiceDashboardHero(session: session),
                  const SizedBox(height: 26),
                  const _ServiceSectionTitle(
                    eyebrow: 'CHOOSE A SERVICE',
                    title: 'Three guided tools',
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 760) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ServiceImageCard(
                                image:
                                    'assets/images/vertical-conveyor-front.png',
                                icon: Icons.build_circle_outlined,
                                eyebrow: 'SUPPORT',
                                title: 'Service My Machine',
                                subtitle:
                                    'Build a technician-ready service brief for your machine.',
                                action: 'Start request',
                                height: 278,
                                onTap: () => onOpen(_ServiceJourney.request),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ServiceImageCard(
                                image:
                                    'assets/images/spiral-conveyor-close.png',
                                icon: Icons.document_scanner_outlined,
                                eyebrow: 'IDENTIFY',
                                title: 'Scan & Identify',
                                subtitle:
                                    'Use a nameplate, QR, serial number, or machine photo.',
                                action: 'Open scanner',
                                height: 278,
                                onTap: () => onOpen(_ServiceJourney.scan),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ServiceImageCard(
                                image:
                                    'assets/images/category-snacks-machines.png',
                                icon: Icons.straighten_outlined,
                                eyebrow: 'PLAN',
                                title: 'Space Planner',
                                subtitle:
                                    'Match your available floor space to a suitable solution.',
                                action: 'Plan my space',
                                height: 278,
                                onTap: () => onOpen(_ServiceJourney.planner),
                              ),
                            ),
                          ],
                        );
                      }

                      if (constraints.maxWidth < 360) {
                        return Column(
                          children: [
                            _ServiceImageCard(
                              image:
                                  'assets/images/vertical-conveyor-front.png',
                              icon: Icons.build_circle_outlined,
                              eyebrow: 'SUPPORT',
                              title: 'Service My Machine',
                              subtitle: 'Prepare a precise technician brief.',
                              action: 'Start request',
                              height: 154,
                              horizontal: true,
                              onTap: () => onOpen(_ServiceJourney.request),
                            ),
                            const SizedBox(height: 11),
                            _ServiceImageCard(
                              image: 'assets/images/spiral-conveyor-close.png',
                              icon: Icons.document_scanner_outlined,
                              eyebrow: 'IDENTIFY',
                              title: 'Scan & Identify',
                              subtitle: 'Nameplate, QR, serial, or photo.',
                              action: 'Open scanner',
                              height: 154,
                              horizontal: true,
                              onTap: () => onOpen(_ServiceJourney.scan),
                            ),
                            const SizedBox(height: 11),
                            _ServiceImageCard(
                              image:
                                  'assets/images/category-snacks-machines.png',
                              icon: Icons.straighten_outlined,
                              eyebrow: 'PLAN',
                              title: 'Space Planner',
                              subtitle: 'Match machine to available space.',
                              action: 'Plan space',
                              height: 154,
                              horizontal: true,
                              onTap: () => onOpen(_ServiceJourney.planner),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _ServiceImageCard(
                            image: 'assets/images/vertical-conveyor-front.png',
                            icon: Icons.build_circle_outlined,
                            eyebrow: 'SUPPORT',
                            title: 'Service My Machine',
                            subtitle:
                                'Select your machine and prepare a precise brief for a HYWAY technician.',
                            action: 'Start request',
                            height: 226,
                            onTap: () => onOpen(_ServiceJourney.request),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _ServiceImageCard(
                                  image:
                                      'assets/images/spiral-conveyor-close.png',
                                  icon: Icons.document_scanner_outlined,
                                  eyebrow: 'IDENTIFY',
                                  title: 'Scan & Identify',
                                  subtitle: 'Nameplate, QR, or serial.',
                                  action: 'Scan',
                                  height: 218,
                                  compact: true,
                                  onTap: () => onOpen(_ServiceJourney.scan),
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: _ServiceImageCard(
                                  image:
                                      'assets/images/category-snacks-machines.png',
                                  icon: Icons.straighten_outlined,
                                  eyebrow: 'PLAN',
                                  title: 'Space Planner',
                                  subtitle: 'Match machine to space.',
                                  action: 'Plan',
                                  height: 218,
                                  compact: true,
                                  onTap: () => onOpen(_ServiceJourney.planner),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const _ServiceSectionTitle(
                    eyebrow: 'CLEAR PROCESS',
                    title: 'From clue to resolution',
                  ),
                  const SizedBox(height: 14),
                  const _ServiceProcessStrip(),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _ServiceProfileSummary extends StatelessWidget {
  const _ServiceProfileSummary({required this.session});

  final _AuthSession session;

  String get _initial =>
      session.name.trim().isEmpty ? 'H' : session.name.trim()[0].toUpperCase();

  String get _role {
    final role = session.role.trim();
    if (role.isEmpty) return 'HYWAY customer';
    return '${role[0].toUpperCase()}${role.substring(1)} account';
  }

  @override
  Widget build(BuildContext context) => Container(
    width: 270,
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
          child: Text(
            _initial,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.name.trim().isEmpty
                    ? 'HYWAY user'
                    : session.name.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                session.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 11.5),
              ),
              const SizedBox(height: 9),
              if (session.company?.isNotEmpty ?? false)
                _ProfileDetail(
                  icon: Icons.business_outlined,
                  value: session.company!,
                ),
              if (session.jobTitle?.isNotEmpty ?? false)
                _ProfileDetail(
                  icon: Icons.badge_outlined,
                  value: session.jobTitle!,
                ),
              if (session.phone?.isNotEmpty ?? false)
                _ProfileDetail(
                  icon: Icons.phone_outlined,
                  value: session.phone!,
                ),
              if ((session.city?.isNotEmpty ?? false) ||
                  (session.state?.isNotEmpty ?? false))
                _ProfileDetail(
                  icon: Icons.location_on_outlined,
                  value: [session.city, session.state]
                      .whereType<String>()
                      .where((value) => value.isNotEmpty)
                      .join(', '),
                ),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1AE31B23),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _role.toUpperCase(),
                  style: const TextStyle(
                    color: red,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 10.5),
          ),
        ),
      ],
    ),
  );
}

class _ServiceDashboardHero extends StatelessWidget {
  const _ServiceDashboardHero({required this.session});

  final _AuthSession session;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 430;
      final firstName = session.name.trim().isEmpty
          ? 'there'
          : session.name.trim().split(RegExp(r'\s+')).first;
      final height = (constraints.maxWidth * .52).clamp(205.0, 292.0);

      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/conveyors-overview.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                cacheWidth: 1400,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFF141A1F),
                  child: Center(
                    child: Icon(
                      Icons.factory_outlined,
                      color: Colors.white24,
                      size: 56,
                    ),
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x18000000),
                      Color(0x73030709),
                      Color(0xF503070A),
                    ],
                    stops: [0, .48, 1],
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xB804080B), Color(0x0004080B)],
                  ),
                ),
              ),
              Positioned(
                top: narrow ? 14 : 18,
                left: narrow ? 14 : 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xD9080D10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x66E31B23)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: red, size: 6),
                      SizedBox(width: 6),
                      Text(
                        'SERVICE CONTROL CENTER',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: narrow ? 15 : 22,
                right: narrow ? 15 : 22,
                bottom: narrow ? 15 : 21,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HELLO, ${firstName.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: red,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'How can HYWAY help?',
                      style: TextStyle(
                        fontSize: narrow ? 25 : 34,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a guided path and share only the details our service team needs.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ServiceImageCard extends StatelessWidget {
  const _ServiceImageCard({
    required this.image,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
    required this.height,
    this.compact = false,
    this.horizontal = false,
  });

  final String image;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;
  final double height;
  final bool compact;
  final bool horizontal;

  @override
  Widget build(BuildContext context) => _PressScale(
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                image,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                cacheWidth: 900,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: const Color(0xFF141A1F),
                  child: Center(
                    child: Icon(icon, color: Colors.white24, size: 44),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: horizontal
                      ? const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFA070B0E),
                            Color(0xDA070B0E),
                            Color(0x44070B0E),
                          ],
                          stops: [0, .58, 1],
                        )
                      : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x1A000000),
                            Color(0x7704080B),
                            Color(0xFA070B0E),
                          ],
                          stops: [0, .44, 1],
                        ),
                ),
              ),
              Positioned(
                top: compact || horizontal ? 12 : 15,
                left: compact || horizontal ? 12 : 15,
                child: Container(
                  width: compact || horizontal ? 36 : 42,
                  height: compact || horizontal ? 36 : 42,
                  decoration: BoxDecoration(
                    color: const Color(0xE6E31B23),
                    borderRadius: BorderRadius.circular(
                      compact || horizontal ? 11 : 13,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: compact || horizontal ? 19 : 22,
                  ),
                ),
              ),
              Positioned(
                top: compact || horizontal ? 13 : 16,
                right: compact || horizontal ? 12 : 15,
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: const Color(0xB3080D10),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.north_east,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
              Positioned(
                left: compact || horizontal ? 13 : 17,
                right: horizontal ? 56 : (compact ? 13 : 17),
                bottom: compact || horizontal ? 12 : 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        color: red,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: horizontal ? 17 : (compact ? 16 : 20),
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: horizontal ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: horizontal ? 10 : (compact ? 10 : 11),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            action,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: red,
                              fontSize: compact || horizontal ? 10 : 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward, color: red, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF343C42)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ServiceProcessStrip extends StatelessWidget {
  const _ServiceProcessStrip();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white10),
    ),
    child: const Row(
      children: [
        Expanded(
          child: _ProcessStep(number: '01', label: 'Share\ndetails'),
        ),
        Icon(Icons.arrow_forward, color: Colors.white24, size: 15),
        Expanded(
          child: _ProcessStep(number: '02', label: 'HYWAY\nreviews'),
        ),
        Icon(Icons.arrow_forward, color: Colors.white24, size: 15),
        Expanded(
          child: _ProcessStep(number: '03', label: 'Get clear\nnext steps'),
        ),
      ],
    ),
  );
}

class _ProcessStep extends StatelessWidget {
  const _ProcessStep({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        number,
        style: const TextStyle(
          color: red,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .8,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10.5,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _ServicePageHeader extends StatelessWidget {
  const _ServicePageHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _PressScale(
        pressedScale: .9,
        child: IconButton(
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: panel,
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white12),
          ),
          icon: const Icon(Icons.arrow_back, size: 19),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: red,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                height: 1.08,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
      if (trailing != null) ...[const SizedBox(width: 10), trailing!],
    ],
  );
}

class _ServiceSectionTitle extends StatelessWidget {
  const _ServiceSectionTitle({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow,
        style: const TextStyle(
          color: red,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
    ],
  );
}

class _ServiceTextField extends StatelessWidget {
  const _ServiceTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final Widget? suffixIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    textCapitalization: textCapitalization,
    autocorrect: autocorrect,
    enableSuggestions: enableSuggestions,
    textInputAction: textInputAction,
    validator: validator,
    onFieldSubmitted: onSubmitted,
    obscureText: obscureText,
    maxLines: obscureText ? 1 : maxLines,
    style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.white38, size: 19),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF090E12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: red, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6A70)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6A70), width: 1.2),
      ),
    ),
  );
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: color.withValues(alpha: .35)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: color, fontSize: 11.5, height: 1.35),
          ),
        ),
      ],
    ),
  );
}

class _ServicePrimaryButton extends StatelessWidget {
  const _ServicePrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.busy = false,
    this.bottomPadding = kBottomNavInset,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool busy;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) => Padding(
    // The landing page uses an overlaying bottom navigation bar. Keeping the
    // clearance on the shared action ensures short forms are safe too.
    padding: EdgeInsets.only(bottom: bottomPadding),
    child: SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: red,
          disabledBackgroundColor: const Color(0x66E31B23),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        icon: busy
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(busy ? 'Please wait...' : label),
      ),
    ),
  );
}

class _ChoiceChipCard extends StatelessWidget {
  const _ChoiceChipCard({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(11),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0x20E31B23) : panel,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: selected ? red : const Color(0xFF2D353B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: selected ? red : Colors.white54, size: 16),
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white60,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
