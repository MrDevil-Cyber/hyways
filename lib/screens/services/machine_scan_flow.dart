part of '../../main.dart';

const _scanCaptureTypes = [
  ('NAMEPLATE', 'Nameplate', Icons.badge_outlined),
  ('QR_CODE', 'QR / Barcode', Icons.qr_code_scanner),
  ('MACHINE_PHOTO', 'Machine photo', Icons.camera_alt_outlined),
];

class _MachineScanFlow extends StatefulWidget {
  const _MachineScanFlow({super.key, required this.api, required this.onClose});

  final _HywayApi api;
  final VoidCallback onClose;

  @override
  State<_MachineScanFlow> createState() => _MachineScanFlowState();
}

class _MachineScanFlowState extends State<_MachineScanFlow> {
  final _serialController = TextEditingController();
  final _machineController = TextEditingController();
  final _notesController = TextEditingController();
  int _captureTypeIndex = 0;
  bool _submitting = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _serialController.dispose();
    _machineController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_serialController.text.trim().isEmpty &&
        _machineController.text.trim().isEmpty &&
        _notesController.text.trim().isEmpty) {
      setState(
        () => _error =
            'Enter a serial number, machine name, or a visible nameplate detail.',
      );
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await widget.api.createMachineScan(
        body: {
          if (_serialController.text.trim().isNotEmpty)
            'serialNumber': _serialController.text.trim(),
          if (_machineController.text.trim().isNotEmpty)
            'machineName': _machineController.text.trim(),
          'notes': [
            'Capture type: ${_scanCaptureTypes[_captureTypeIndex].$1}',
            if (_notesController.text.trim().isNotEmpty)
              _notesController.text.trim(),
          ].join('. '),
        },
      );
      if (mounted) setState(() => _result = result);
    } on _ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Scan request save nahi ho paayi. Backend connection check karke dobara try karein.',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result != null) {
      return _MachineScanResult(result: result, onDone: widget.onClose);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: _ServicePageHeader(
                eyebrow: 'SCAN & IDENTIFY',
                title: 'Capture a machine clue',
                subtitle:
                    'Use the nameplate, serial, QR code, or visible machine details.',
                onBack: widget.onClose,
                trailing: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF65D69E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x8865D69E), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, kBottomNavInset),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ScanViewfinder(),
                    const SizedBox(height: 17),
                    const _InlineMessage(
                      icon: Icons.info_outline,
                      message:
                          'Automatic identification remains preliminary. A HYWAY expert verifies every machine match before service or installation advice.',
                      color: Color(0xFF72B7FF),
                    ),
                    const SizedBox(height: 24),
                    const _ServiceSectionTitle(
                      eyebrow: 'CAPTURE MODE',
                      title: 'What are you scanning?',
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (
                            var index = 0;
                            index < _scanCaptureTypes.length;
                            index++
                          ) ...[
                            _ChoiceChipCard(
                              label: _scanCaptureTypes[index].$2,
                              icon: _scanCaptureTypes[index].$3,
                              selected: _captureTypeIndex == index,
                              onTap: () =>
                                  setState(() => _captureTypeIndex = index),
                            ),
                            if (index < _scanCaptureTypes.length - 1)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _ServiceSectionTitle(
                      eyebrow: 'VISIBLE DETAILS',
                      title: 'Add anything you can read',
                    ),
                    const SizedBox(height: 12),
                    _ServiceTextField(
                      controller: _serialController,
                      label: 'Serial or QR value',
                      hint: 'Example: HY-CVC-2026-1042',
                      icon: Icons.numbers_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 11),
                    _ServiceTextField(
                      controller: _machineController,
                      label: 'Machine name or model',
                      hint: 'Example: Spiral Conveyor',
                      icon: Icons.precision_manufacturing_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 11),
                    _ServiceTextField(
                      controller: _notesController,
                      label: 'Other nameplate details',
                      hint: 'Manufacturer, voltage, capacity, visible issue...',
                      icon: Icons.description_outlined,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _InlineMessage(
                        icon: Icons.error_outline,
                        message: _error!,
                        color: const Color(0xFFFF6A70),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _ServicePrimaryButton(
                      label: 'Submit for identification',
                      icon: Icons.document_scanner_outlined,
                      busy: _submitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanViewfinder extends StatefulWidget {
  const _ScanViewfinder();

  @override
  State<_ScanViewfinder> createState() => _ScanViewfinderState();
}

class _ScanViewfinderState extends State<_ScanViewfinder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
      _controller.value = .5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1.55,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/category-conveyors.png',
            fit: BoxFit.cover,
          ),
          const ColoredBox(color: Color(0x99050A0E)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Color(0xCC050A0E)],
                stops: [.45, 1],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 238,
              height: 126,
              decoration: BoxDecoration(
                color: const Color(0x22000000),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final alignment in const [
                    Alignment.topLeft,
                    Alignment.topRight,
                    Alignment.bottomLeft,
                    Alignment.bottomRight,
                  ])
                    Align(
                      alignment: alignment,
                      child: _ScanCorner(alignment: alignment),
                    ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => Positioned(
                      left: 10,
                      right: 10,
                      top: 12 + (99 * _controller.value),
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              red,
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: red,
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.center_focus_strong,
                          color: Colors.white54,
                          size: 25,
                        ),
                        SizedBox(height: 7),
                        Text(
                          'ALIGN NAMEPLATE HERE',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xAA050A0E),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: red, size: 13),
                  SizedBox(width: 6),
                  Text(
                    'GUIDED SCAN',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ScanCorner extends StatelessWidget {
  const _ScanCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final left = alignment.x < 0;
    final top = alignment.y < 0;
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        border: Border(
          left: left ? const BorderSide(color: red, width: 3) : BorderSide.none,
          right: left
              ? BorderSide.none
              : const BorderSide(color: red, width: 3),
          top: top ? const BorderSide(color: red, width: 3) : BorderSide.none,
          bottom: top
              ? BorderSide.none
              : const BorderSide(color: red, width: 3),
        ),
      ),
    );
  }
}

class _MachineScanResult extends StatelessWidget {
  const _MachineScanResult({required this.result, required this.onDone});

  final Map<String, dynamic> result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final id = result['id']?.toString() ?? 'Saved';
    final status =
        result['status']?.toString().replaceAll('_', ' ') ?? 'PENDING';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 50, 22, kBottomNavInset),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0x1F72B7FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  color: Color(0xFF72B7FF),
                  size: 39,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Machine clue recorded',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 9),
              const Text(
                'The scan is now linked to your account. HYWAY will verify the machine identity before using it for service advice.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _ReviewRow(label: 'Status', value: status),
                    const _ReviewDivider(),
                    _ReviewRow(label: 'Scan reference', value: id),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _ServicePrimaryButton(
                label: 'Back to Service Hub',
                icon: Icons.home_repair_service_outlined,
                onPressed: onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
