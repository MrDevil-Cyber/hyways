part of '../../main.dart';

const _plannerMaterials = [
  'Packed cartons',
  'Crates / Pallets',
  'Powder / Ingredients',
  'Snacks / Food',
];

class _SpacePlannerFlow extends StatefulWidget {
  const _SpacePlannerFlow({
    super.key,
    required this.api,
    required this.onClose,
  });

  final _HywayApi api;
  final VoidCallback onClose;

  @override
  State<_SpacePlannerFlow> createState() => _SpacePlannerFlowState();
}

class _SpacePlannerFlowState extends State<_SpacePlannerFlow> {
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _entryWidthController = TextEditingController();
  final _entryHeightController = TextEditingController();
  final _throughputController = TextEditingController();
  String _unit = 'MM';
  int _categoryIndex = 0;
  int _materialIndex = 0;
  bool _submitting = false;
  bool _reviewSubmitting = false;
  String? _error;
  Map<String, dynamic>? _result;
  Map<String, dynamic>? _reviewResult;

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _entryWidthController.dispose();
    _entryHeightController.dispose();
    _throughputController.dispose();
    super.dispose();
  }

  double? _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim());

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final length = _number(_lengthController);
    final width = _number(_widthController);
    final height = _number(_heightController);
    if (length == null || width == null || height == null) {
      setState(
        () => _error = 'Length, width, and height must contain valid numbers.',
      );
      return;
    }
    if (length <= 0 || width <= 0 || height <= 0) {
      setState(() => _error = 'Space dimensions must be greater than zero.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await widget.api.createSpaceAssessment(
        body: {
          'unit': _unit,
          'length': length,
          'width': width,
          'height': height,
          'entryWidth': ?_number(_entryWidthController),
          'entryHeight': ?_number(_entryHeightController),
          'machineCategory': _machineServiceCategories[_categoryIndex].$1,
          'material': _plannerMaterials[_materialIndex],
          'throughputPerHour': ?_number(_throughputController),
        },
      );
      if (mounted) setState(() => _result = result);
    } on _ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'The space assessment could not be created. Check the server connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _requestEngineerReview() async {
    final result = _result;
    if (result == null) return;
    final assessment = result['assessment'] as Map<String, dynamic>? ?? result;
    final recommendation =
        result['preliminaryRecommendation'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final assessmentId = assessment['id']?.toString() ?? 'pending';
    final category =
        recommendation['recommendedCategory']?.toString() ??
        _machineServiceCategories[_categoryIndex].$1;
    setState(() {
      _reviewSubmitting = true;
      _error = null;
    });
    try {
      final review = await widget.api.createServiceRequest(
        body: {
          'machineName': 'Space planning consultation',
          'machineCategory': category,
          'serviceType': 'CONSULTATION',
          'issueDescription':
              'Engineer review requested for space assessment $assessmentId. '
              'Available space: ${_lengthController.text} × ${_widthController.text} × ${_heightController.text} $_unit; '
              'material: ${_plannerMaterials[_materialIndex]}.',
          'urgency': 'NORMAL',
        },
      );
      if (mounted) setState(() => _reviewResult = review);
    } on _ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'The engineer review request could not be submitted. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _reviewSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result != null) {
      return _SpacePlannerResult(
        result: result,
        reviewResult: _reviewResult,
        error: _error,
        reviewSubmitting: _reviewSubmitting,
        onReview: _requestEngineerReview,
        onDone: widget.onClose,
        onEdit: () => setState(() {
          _result = null;
          _reviewResult = null;
          _error = null;
        }),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: _ServicePageHeader(
                eyebrow: 'SPACE PLANNER',
                title: 'Fit the machine to your floor',
                subtitle:
                    'Share usable dimensions. Backend rules will calculate a preliminary fit envelope.',
                onBack: widget.onClose,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, kBottomNavInset),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SpaceDiagram(),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      decoration: BoxDecoration(
                        color: panel.withValues(alpha: .72),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: _ServiceSectionTitle(
                                  eyebrow: 'AVAILABLE AREA',
                                  title: 'Enter clear dimensions',
                                ),
                              ),
                              const SizedBox(width: 12),
                              _UnitSwitch(
                                value: _unit,
                                onChanged: (value) =>
                                    setState(() => _unit = value),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Enter the room’s clear floor space. Do not include walls or obstacles.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11.2,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth >= 620 ? 3 : 2;
                              final aspectRatio = columns == 3 ? 2.28 : 1.68;

                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: columns,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: aspectRatio,
                                children: [
                                  _DimensionField(
                                    controller: _lengthController,
                                    label: 'Length',
                                    unit: _unit,
                                    icon: Icons.swap_horiz,
                                    required: true,
                                  ),
                                  _DimensionField(
                                    controller: _widthController,
                                    label: 'Width',
                                    unit: _unit,
                                    icon: Icons.width_normal_outlined,
                                    required: true,
                                  ),
                                  _DimensionField(
                                    controller: _heightController,
                                    label: 'Height',
                                    unit: _unit,
                                    icon: Icons.height,
                                    required: true,
                                  ),
                                  _DimensionField(
                                    controller: _entryWidthController,
                                    label: 'Entry width',
                                    unit: _unit,
                                    icon: Icons.door_front_door_outlined,
                                  ),
                                  _DimensionField(
                                    controller: _entryHeightController,
                                    label: 'Entry height',
                                    unit: _unit,
                                    icon: Icons.vertical_align_center,
                                  ),
                                  _DimensionField(
                                    controller: _throughputController,
                                    label: 'Units / hour',
                                    unit: '',
                                    icon: Icons.speed_outlined,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const _ServiceSectionTitle(
                      eyebrow: 'MACHINE DIRECTION',
                      title: 'What are you planning?',
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (
                            var index = 0;
                            index < _machineServiceCategories.length;
                            index++
                          ) ...[
                            _ChoiceChipCard(
                              label: _machineServiceCategories[index].$1,
                              icon: _machineServiceCategories[index].$2,
                              selected: _categoryIndex == index,
                              onTap: () =>
                                  setState(() => _categoryIndex = index),
                            ),
                            if (index < _machineServiceCategories.length - 1)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _ServiceSectionTitle(
                      eyebrow: 'MATERIAL',
                      title: 'What will the machine handle?',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (
                          var index = 0;
                          index < _plannerMaterials.length;
                          index++
                        )
                          _ChoiceChipCard(
                            label: _plannerMaterials[index],
                            selected: _materialIndex == index,
                            onTap: () => setState(() => _materialIndex = index),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _InlineMessage(
                      icon: Icons.engineering_outlined,
                      message:
                          'This result is preliminary. Floor load, utilities, safety clearance, product flow, and site access still require engineer verification.',
                      color: Color(0xFFFFAF58),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      _InlineMessage(
                        icon: Icons.error_outline,
                        message: _error!,
                        color: const Color(0xFFFF6A70),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _ServicePrimaryButton(
                      label: 'Calculate preliminary fit',
                      icon: Icons.calculate_outlined,
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

class _SpaceDiagram extends StatelessWidget {
  const _SpaceDiagram();

  @override
  Widget build(BuildContext context) => Container(
    height: 172,
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF30383E)),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF171E23), Color(0xFF0B1014)],
      ),
    ),
    child: Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _FloorGridPainter())),
        Center(
          child: Transform.rotate(
            angle: -.12,
            child: Container(
              width: 178,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0x1FE31B23),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: red, width: 1.3),
              ),
              child: const Center(
                child: Icon(
                  Icons.precision_manufacturing_outlined,
                  color: red,
                  size: 38,
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 14,
          top: 14,
          child: Text(
            'USABLE MACHINE ENVELOPE',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        const Positioned(
          left: 18,
          right: 18,
          bottom: 13,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DiagramAxis(label: 'LENGTH', icon: Icons.swap_horiz),
              _DiagramAxis(label: 'WIDTH', icon: Icons.width_normal_outlined),
              _DiagramAxis(label: 'HEIGHT', icon: Icons.height),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DiagramAxis extends StatelessWidget {
  const _DiagramAxis({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: red, size: 13),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: .7,
        ),
      ),
    ],
  );
}

class _FloorGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x163F4A52)
      ..strokeWidth = 1;
    const step = 22.0;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(
        Offset(x.toDouble(), size.height),
        Offset((x + size.height).toDouble(), 0),
        paint,
      );
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UnitSwitch extends StatelessWidget {
  const _UnitSwitch({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final unit in const ['MM', 'FT'])
          InkWell(
            onTap: () => onChanged(unit),
            borderRadius: BorderRadius.circular(7),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: value == unit ? red : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                unit,
                style: TextStyle(
                  color: value == unit ? Colors.white : Colors.white38,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _DimensionField extends StatelessWidget {
  const _DimensionField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.icon,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final String unit;
  final IconData icon;
  final bool required;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: -.1,
    ),
    decoration: InputDecoration(
      labelText: required ? '$label *' : label,
      suffixText: unit,
      prefixIcon: Icon(icon, size: 18, color: Colors.white54),
      prefixIconConstraints: const BoxConstraints(minWidth: 42),
      suffixStyle: const TextStyle(
        color: Color(0xFFFF8C91),
        fontSize: 9.5,
        fontWeight: FontWeight.w900,
      ),
      labelStyle: const TextStyle(
        color: Colors.white38,
        fontSize: 10.2,
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: const Color(0xFF13191D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF283037)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: red, width: 1.25),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6A70)),
      ),
    ),
  );
}

class _SpacePlannerResult extends StatelessWidget {
  const _SpacePlannerResult({
    required this.result,
    required this.reviewResult,
    required this.error,
    required this.reviewSubmitting,
    required this.onReview,
    required this.onDone,
    required this.onEdit,
  });

  final Map<String, dynamic> result;
  final Map<String, dynamic>? reviewResult;
  final String? error;
  final bool reviewSubmitting;
  final VoidCallback onReview;
  final VoidCallback onDone;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final recommendation =
        result['preliminaryRecommendation'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final status =
        recommendation['fitStatus']?.toString() ?? 'EXPERT_REVIEW_REQUIRED';
    final category =
        recommendation['recommendedMachine']?.toString() ??
        recommendation['recommendedMachineType']?.toString() ??
        recommendation['recommendedCategory']?.toString() ??
        'HYWAY engineered solution';
    final summary =
        recommendation['summary']?.toString() ??
        'Your dimensions have been saved for engineering review.';
    final disclaimer =
        recommendation['disclaimer']?.toString() ??
        'Preliminary guidance only. Final selection requires a HYWAY site assessment.';
    final envelope =
        recommendation['maximumMachineEnvelopeMm'] as Map<String, dynamic>?;
    final statusColor = switch (status) {
      'PRELIMINARY_FIT' => const Color(0xFF65D69E),
      'LIMITED_FIT' => const Color(0xFFFFAF58),
      'NOT_FEASIBLE' => const Color(0xFFFF6A70),
      _ => const Color(0xFF72B7FF),
    };
    final statusLabel = status.replaceAll('_', ' ');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: _ServicePageHeader(
                eyebrow: 'PRELIMINARY RESULT',
                title: 'Your fit direction',
                subtitle:
                    'Backend rules calculated this from your dimensions and use case.',
                onBack: onEdit,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, kBottomNavInset),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: statusColor.withValues(alpha: .5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: .09),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withValues(alpha: .35),
                              ),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'RECOMMENDED DIRECTION',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 23,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            summary,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                          if (envelope != null) ...[
                            const SizedBox(height: 18),
                            Container(height: 1, color: Colors.white10),
                            const SizedBox(height: 15),
                            const Text(
                              'MAXIMUM MACHINE ENVELOPE',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${envelope['length'] ?? '—'} × ${envelope['width'] ?? '—'} × ${envelope['height'] ?? '—'} mm',
                              style: const TextStyle(
                                color: red,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    _InlineMessage(
                      icon: Icons.engineering_outlined,
                      message: disclaimer,
                      color: const Color(0xFFFFAF58),
                    ),
                    if (reviewResult != null) ...[
                      const SizedBox(height: 11),
                      _InlineMessage(
                        icon: Icons.check_circle_outline,
                        message:
                            'Engineer review requested. Reference: ${reviewResult!['requestNumber'] ?? reviewResult!['id'] ?? 'Created'}',
                        color: const Color(0xFF65D69E),
                      ),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 11),
                      _InlineMessage(
                        icon: Icons.error_outline,
                        message: error!,
                        color: const Color(0xFFFF6A70),
                      ),
                    ],
                    const SizedBox(height: 18),
                    if (reviewResult == null)
                      _ServicePrimaryButton(
                        label: 'Request engineer review',
                        icon: Icons.engineering_outlined,
                        busy: reviewSubmitting,
                        onPressed: onReview,
                      )
                    else
                      _ServicePrimaryButton(
                        label: 'Back to Service Hub',
                        icon: Icons.home_repair_service_outlined,
                        onPressed: onDone,
                      ),
                    const SizedBox(height: 9),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: onEdit,
                        child: const Text('Edit dimensions'),
                      ),
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
