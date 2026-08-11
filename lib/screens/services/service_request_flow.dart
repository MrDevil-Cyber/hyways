part of '../../main.dart';

const _machineServiceCategories = [
  ('Conveyors', Icons.precision_manufacturing_outlined, _conveyorProducts),
  ('Mixer', Icons.blender_outlined, _mixerProducts),
  ('Washer', Icons.water_drop_outlined, _washerProducts),
  ('Snacks Machines', Icons.fastfood_outlined, _snacksMachineProducts),
];

const _serviceTypes = [
  ('Breakdown / Repair', 'REPAIR', Icons.build_outlined),
  ('Preventive Maintenance', 'MAINTENANCE', Icons.health_and_safety_outlined),
  ('Installation', 'INSTALLATION', Icons.precision_manufacturing_outlined),
  ('Inspection', 'INSPECTION', Icons.fact_check_outlined),
  ('Spare Parts / AMC', 'CONSULTATION', Icons.settings_suggest_outlined),
];

const _serviceUrgencies = [
  ('Normal', 'NORMAL', 'Schedule at the earliest slot'),
  ('Priority', 'HIGH', 'Production is affected'),
  ('Emergency', 'CRITICAL', 'Machine or line is stopped'),
];

class _ServiceRequestFlow extends StatefulWidget {
  const _ServiceRequestFlow({
    super.key,
    required this.api,
    required this.onClose,
  });

  final _HywayApi api;
  final VoidCallback onClose;

  @override
  State<_ServiceRequestFlow> createState() => _ServiceRequestFlowState();
}

class _ServiceRequestFlowState extends State<_ServiceRequestFlow> {
  final _issueController = TextEditingController();
  int _step = 0;
  int _categoryIndex = 0;
  _ConveyorProduct? _machine;
  int _serviceTypeIndex = 0;
  int _urgencyIndex = 0;
  DateTime? _preferredVisit;
  bool _submitting = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  String get _category => _machineServiceCategories[_categoryIndex].$1;

  void _back() {
    if (_result != null || _step == 0) {
      widget.onClose();
    } else {
      setState(() {
        _step--;
        _error = null;
      });
    }
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step == 0 && _machine == null) {
      setState(() => _error = 'Please select the machine that needs service.');
      return;
    }
    if (_step == 1 && _issueController.text.trim().length < 10) {
      setState(
        () => _error =
            'Please describe the issue in at least 10 characters so our technician gets a useful clue.',
      );
      return;
    }
    setState(() {
      _error = null;
      _step++;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _preferredVisit ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: red, surface: panel),
        ),
        child: child!,
      ),
    );
    if (value != null && mounted) setState(() => _preferredVisit = value);
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await widget.api.createServiceRequest(
        body: {
          'machineName': _machine!.name,
          'machineCategory': _category,
          'serviceType': _serviceTypes[_serviceTypeIndex].$2,
          'issueDescription': _issueController.text.trim(),
          'urgency': _serviceUrgencies[_urgencyIndex].$2,
          if (_preferredVisit != null)
            'preferredVisitAt': _preferredVisit!.toUtc().toIso8601String(),
        },
      );
      if (mounted) setState(() => _result = result);
    } on _ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Service request submit nahi ho paayi. Backend connection check karke dobara try karein.',
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
      return _ServiceRequestSuccess(result: result, onDone: widget.onClose);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: _ServicePageHeader(
                eyebrow: 'SERVICE MY MACHINE',
                title: switch (_step) {
                  0 => 'Select Your Machine',
                  1 => 'What does it need?',
                  _ => 'Review your brief',
                },
                subtitle: switch (_step) {
                  0 => 'Choose a category, then select the exact machine.',
                  1 => 'A few precise details help us route the right expert.',
                  _ => 'Confirm the details before sending them to HYWAY.',
                },
                onBack: _back,
                trailing: _ServiceStepBadge(current: _step + 1, total: 3),
              ),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 230),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: switch (_step) {
              0 => _MachineSelectionStep(
                key: const ValueKey('machine-selection'),
                categoryIndex: _categoryIndex,
                selectedMachine: _machine,
                error: _error,
                onCategoryChanged: (index) => setState(() {
                  _categoryIndex = index;
                  _machine = null;
                  _error = null;
                }),
                onMachineChanged: (machine) => setState(() {
                  _machine = machine;
                  _error = null;
                }),
                onNext: _next,
              ),
              1 => _ServiceIssueStep(
                key: const ValueKey('service-issue'),
                machine: _machine!,
                issueController: _issueController,
                serviceTypeIndex: _serviceTypeIndex,
                urgencyIndex: _urgencyIndex,
                preferredVisit: _preferredVisit,
                error: _error,
                onServiceTypeChanged: (index) => setState(() {
                  _serviceTypeIndex = index;
                  _error = null;
                }),
                onUrgencyChanged: (index) => setState(() {
                  _urgencyIndex = index;
                  _error = null;
                }),
                onPickDate: _pickDate,
                onNext: _next,
              ),
              _ => _ServiceReviewStep(
                key: const ValueKey('service-review'),
                category: _category,
                machine: _machine!,
                serviceType: _serviceTypes[_serviceTypeIndex].$1,
                urgency: _serviceUrgencies[_urgencyIndex].$1,
                issue: _issueController.text.trim(),
                preferredVisit: _preferredVisit,
                error: _error,
                submitting: _submitting,
                onSubmit: _submit,
              ),
            },
          ),
        ),
      ],
    );
  }
}

class _MachineSelectionStep extends StatelessWidget {
  const _MachineSelectionStep({
    super.key,
    required this.categoryIndex,
    required this.selectedMachine,
    required this.error,
    required this.onCategoryChanged,
    required this.onMachineChanged,
    required this.onNext,
  });

  final int categoryIndex;
  final _ConveyorProduct? selectedMachine;
  final String? error;
  final ValueChanged<int> onCategoryChanged;
  final ValueChanged<_ConveyorProduct> onMachineChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final machines = _machineServiceCategories[categoryIndex].$3;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, kBottomNavInset + 78),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ServiceSectionTitle(
                    eyebrow: 'STEP 01',
                    title: 'Machine category',
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
                            selected: index == categoryIndex,
                            onTap: () => onCategoryChanged(index),
                          ),
                          if (index < _machineServiceCategories.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ServiceSectionTitle(
                    eyebrow: 'SELECT ONE',
                    title:
                        '${_machineServiceCategories[categoryIndex].$1} machines',
                  ),
                  const SizedBox(height: 13),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 850
                          ? 4
                          : (constraints.maxWidth >= 560 ? 3 : 2);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: machines.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 164,
                        ),
                        itemBuilder: (context, index) {
                          final machine = machines[index];
                          return _MachineChoiceCard(
                            machine: machine,
                            selected: identical(machine, selectedMachine),
                            onTap: () => onMachineChanged(machine),
                          );
                        },
                      );
                    },
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    _InlineMessage(
                      icon: Icons.info_outline,
                      message: error!,
                      color: const Color(0xFFFFAF58),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (selectedMachine != null)
          Positioned(
            left: 18,
            right: 18,
            bottom: kBottomNavInset,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: ink.withValues(alpha: .72),
                        blurRadius: 18,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: _ServicePrimaryButton(
                    label: 'Continue with selected machine',
                    icon: Icons.arrow_forward,
                    onPressed: onNext,
                    bottomPadding: 0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MachineChoiceCard extends StatelessWidget {
  const _MachineChoiceCard({
    required this.machine,
    required this.selected,
    required this.onTap,
  });

  final _ConveyorProduct machine;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _PressScale(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? red : const Color(0xFF30383E),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x44E31B23),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(machine.image, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0x66000000)],
                          ),
                        ),
                      ),
                      if (selected)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: const BoxDecoration(
                              color: red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(height: 1, color: const Color(0x33E31B23)),
                SizedBox(
                  height: 53,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        machine.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

class _ServiceIssueStep extends StatelessWidget {
  const _ServiceIssueStep({
    super.key,
    required this.machine,
    required this.issueController,
    required this.serviceTypeIndex,
    required this.urgencyIndex,
    required this.preferredVisit,
    required this.error,
    required this.onServiceTypeChanged,
    required this.onUrgencyChanged,
    required this.onPickDate,
    required this.onNext,
  });

  final _ConveyorProduct machine;
  final TextEditingController issueController;
  final int serviceTypeIndex;
  final int urgencyIndex;
  final DateTime? preferredVisit;
  final String? error;
  final ValueChanged<int> onServiceTypeChanged;
  final ValueChanged<int> onUrgencyChanged;
  final VoidCallback onPickDate;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, kBottomNavInset),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      machine.image,
                      width: 64,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SELECTED MACHINE',
                          style: TextStyle(
                            color: red,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          machine.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_outlined,
                    color: Colors.white30,
                    size: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _ServiceSectionTitle(
              eyebrow: 'SERVICE TYPE',
              title: 'What support do you need?',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < _serviceTypes.length; index++)
                  _ChoiceChipCard(
                    label: _serviceTypes[index].$1,
                    icon: _serviceTypes[index].$3,
                    selected: index == serviceTypeIndex,
                    onTap: () => onServiceTypeChanged(index),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const _ServiceSectionTitle(
              eyebrow: 'SERVICE CLUE',
              title: 'Describe what is happening',
            ),
            const SizedBox(height: 12),
            _ServiceTextField(
              controller: issueController,
              label: 'Issue or requirement',
              hint:
                  'Example: belt slips after 20 minutes and makes a grinding sound...',
              icon: Icons.notes_outlined,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            const _ServiceSectionTitle(
              eyebrow: 'URGENCY',
              title: 'How is production affected?',
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                for (var index = 0; index < _serviceUrgencies.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _serviceUrgencies.length - 1 ? 0 : 8,
                    ),
                    child: _UrgencyChoice(
                      title: _serviceUrgencies[index].$1,
                      subtitle: _serviceUrgencies[index].$3,
                      selected: index == urgencyIndex,
                      onTap: () => onUrgencyChanged(index),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onPickDate,
              icon: const Icon(Icons.event_outlined, size: 18),
              label: Text(
                preferredVisit == null
                    ? 'Add preferred visit date (optional)'
                    : 'Preferred: ${_formatServiceDate(preferredVisit!)}',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                textStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 14),
              _InlineMessage(
                icon: Icons.info_outline,
                message: error!,
                color: const Color(0xFFFFAF58),
              ),
            ],
            const SizedBox(height: 20),
            _ServicePrimaryButton(
              label: 'Review service brief',
              icon: Icons.arrow_forward,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    ),
  );
}

class _UrgencyChoice extends StatelessWidget {
  const _UrgencyChoice({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? const Color(0x18E31B23) : panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? red : Colors.white10),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 19,
            height: 19,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? red : Colors.transparent,
              border: Border.all(color: selected ? red : Colors.white30),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
          const SizedBox(width: 11),
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
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ServiceReviewStep extends StatelessWidget {
  const _ServiceReviewStep({
    super.key,
    required this.category,
    required this.machine,
    required this.serviceType,
    required this.urgency,
    required this.issue,
    required this.preferredVisit,
    required this.error,
    required this.submitting,
    required this.onSubmit,
  });

  final String category;
  final _ConveyorProduct machine;
  final String serviceType;
  final String urgency;
  final String issue;
  final DateTime? preferredVisit;
  final String? error;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, kBottomNavInset),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFF30383E)),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(machine.image, fit: BoxFit.cover),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xE510161B)],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.toUpperCase(),
                                  style: const TextStyle(
                                    color: red,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  machine.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _ReviewRow(label: 'Service', value: serviceType),
                        const _ReviewDivider(),
                        _ReviewRow(label: 'Urgency', value: urgency),
                        const _ReviewDivider(),
                        _ReviewRow(
                          label: 'Visit date',
                          value: preferredVisit == null
                              ? 'First available slot'
                              : _formatServiceDate(preferredVisit!),
                        ),
                        const _ReviewDivider(),
                        _ReviewRow(
                          label: 'Service clue',
                          value: issue,
                          alignTop: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _InlineMessage(
              icon: Icons.verified_user_outlined,
              message:
                  'Your request is securely linked to your account. HYWAY will review it before confirming the visit.',
              color: Color(0xFF76D7A5),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              _InlineMessage(
                icon: Icons.error_outline,
                message: error!,
                color: const Color(0xFFFF6A70),
              ),
            ],
            const SizedBox(height: 18),
            _ServicePrimaryButton(
              label: 'Submit service request',
              icon: Icons.send_outlined,
              busy: submitting,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.alignTop = false,
  });

  final String label;
  final String value;
  final bool alignTop;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: alignTop
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 86,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11.5,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _ReviewDivider extends StatelessWidget {
  const _ReviewDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 11),
    child: Divider(height: 1, color: Colors.white10),
  );
}

class _ServiceStepBadge extends StatelessWidget {
  const _ServiceStepBadge({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0x20E31B23),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0x55E31B23)),
    ),
    child: Text(
      '$current/$total',
      style: const TextStyle(
        color: red,
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _ServiceRequestSuccess extends StatelessWidget {
  const _ServiceRequestSuccess({required this.result, required this.onDone});

  final Map<String, dynamic> result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final rawNumber =
        result['requestNumber'] ?? result['ticketNumber'] ?? result['id'];
    final number = rawNumber?.toString() ?? 'Created';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 54, 22, kBottomNavInset),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  color: Color(0x20E31B23),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: red, size: 42),
              ),
              const SizedBox(height: 22),
              const Text(
                'Service request received',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 9),
              const Text(
                'A HYWAY service expert will review your machine details and contact you with the next step.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'REQUEST REFERENCE',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    SelectableText(
                      number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: red,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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

String _formatServiceDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}
