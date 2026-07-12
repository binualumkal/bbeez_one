import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bbeez_one/platform/services/app_lock_service.dart';
import 'package:bbeez_one/platform/core/service_locator.dart';
import 'package:bbeez_one/platform/models/record_model.dart';
import 'package:bbeez_one/platform/models/secret_field_model.dart';
import 'package:bbeez_one/platform/repositories/record_repository.dart';
import 'package:bbeez_one/platform/services/notification_service.dart';
import 'package:bbeez_one/platform/security/security_service.dart';
import 'package:bbeez_one/apps/one/widgets/common_appbar.dart';

class AddRecordPage extends StatefulWidget {
  final String domainName;
  final String institutionName;
  final String recordTypeName;
  final RecordModel? existingRecord;

  const AddRecordPage({
    super.key,
    required this.domainName,
    required this.institutionName,
    required this.recordTypeName,
    this.existingRecord,
  });

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final List<TextEditingController> labelControllers = [];

  final List<TextEditingController> valueControllers = [];

  final List<TextEditingController> value2Controllers = [];

  bool hasChanges = false;
  bool isFavorite = false;
  bool isSaving = false;
  DateTime? selectedExpiryDate;

  @override
  void initState() {
    super.initState();

    if (widget.existingRecord != null) {
      isFavorite = widget.existingRecord!.isFavorite;
      selectedExpiryDate = widget.existingRecord!.expiryDate;
      for (final field in widget.existingRecord!.fields) {
        final label = TextEditingController(text: field.label);
        final v1 = TextEditingController(
          text: SecurityService.decrypt(field.value),
        );
        final v2 = TextEditingController(
          text: SecurityService.decrypt(field.value2 ?? ""),
        );

        // Reset lock timer and update UI (for link icons) when user types
        void onTextChanged() {
          AppLockService.instance.resetTimer();
          if (mounted) setState(() {});
        }

        label.addListener(onTextChanged);
        v1.addListener(onTextChanged);
        v2.addListener(onTextChanged);

        labelControllers.add(label);
        valueControllers.add(v1);
        value2Controllers.add(v2);
      }
    } else {
      addField();
    }
  }

  void addField() {
    final label = TextEditingController();
    final v1 = TextEditingController();
    final v2 = TextEditingController();

    // Reset lock timer and update UI (for link icons) when user types
    void onTextChanged() {
      AppLockService.instance.resetTimer();
      hasChanges = true;
      if (mounted) setState(() {});
    }

    label.addListener(onTextChanged);
    v1.addListener(onTextChanged);
    v2.addListener(onTextChanged);

    labelControllers.add(label);
    valueControllers.add(v1);
    value2Controllers.add(v2);

    hasChanges = true;
    setState(() {});
  }

  void removeField(int index) {
    if (labelControllers.length == 1) {
      return;
    }

    labelControllers[index].dispose();

    valueControllers[index].dispose();

    value2Controllers[index].dispose();

    labelControllers.removeAt(index);

    valueControllers.removeAt(index);

    value2Controllers.removeAt(index);

    setState(() {});
  }

  Future<bool> confirmDiscard() async {
    if (!hasChanges) return true;

    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(
              0xFF061A44,
            ),
            title: const Text(
              "Discard Changes?",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            content: const Text(
              "Unsaved data will be lost.",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child: const Text(
                  "Cancel",
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                child: const Text(
                  "Discard",
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> saveRecord() async {
    if (isSaving) return;

    List<SecretField> fields = [];

    for (int i = 0; i < labelControllers.length; i++) {
      final label = labelControllers[i].text.trim();

      final val1 = valueControllers[i].text.trim();

      final val2 = value2Controllers[i].text.trim();

      // Skip if Label is empty OR (Value 1 is empty AND Value 2 is empty)
      if (label.isEmpty || (val1.isEmpty && val2.isEmpty)) {
        continue;
      }

      fields.add(
        SecretField()
          ..label = label
          ..value = SecurityService.encrypt(val1)
          ..value2 = SecurityService.encrypt(val2),
      );
    }

    if (fields.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Please add at least one field",
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final record = widget.existingRecord ?? RecordModel();

      record.domainName = widget.domainName;

      record.institutionName = widget.institutionName;

      record.recordTypeName = widget.recordTypeName;

      record.fields = fields;

      record.isFavorite = isFavorite;
      record.expiryDate = selectedExpiryDate;

      record.searchText = '''
${record.domainName}
${record.institutionName}
${record.recordTypeName}
${fields.map(
                (e) => e.label,
              ).join(' ')}
'''
          .toLowerCase();

      await locate<RecordRepository>().save(
        record,
      );

      // Schedule notification if expiry date is set
      try {
        if (selectedExpiryDate != null && record.key != null) {
          await NotificationService.scheduleRecordExpiry(
            record.key as int,
            record.institutionName,
            selectedExpiryDate!,
          );
        } else if (record.key != null) {
          await NotificationService.cancelNotification(record.key as int);
        }
      } catch (e) {
        debugPrint("Notification scheduling failed: $e");
      }

      if (mounted) {
        Navigator.pop(
          context,
          true,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving record: $e")),
        );
      }
    }
  }

  bool _isUrl(String text) {
    if (text.isEmpty) return false;
    final trimmed = text.trim().toLowerCase();
    if (trimmed.contains('http://') || trimmed.contains('https://')) {
      return true;
    }
    final urlPattern = r"[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}";
    return RegExp(urlPattern).hasMatch(trimmed);
  }

  Future<void> _launchURL(String url) async {
    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final Uri uri = Uri.parse(formattedUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch $formattedUrl")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error launching URL: $e")),
        );
      }
    }
  }

  Widget _buildFieldActions(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return const SizedBox.shrink();

    final isUrl = _isUrl(text);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Copied to clipboard"),
                duration: Duration(seconds: 1),
              ),
            );
          },
          tooltip: "Copy",
        ),
        if (isUrl)
          IconButton(
            icon: const Icon(Icons.open_in_new,
                color: Color(0xFF14F1FF), size: 20),
            onPressed: () => _launchURL(text),
            tooltip: "Open Link",
          ),
      ],
    );
  }

  Widget buildGlassCard(
    int index,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        24,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          margin: const EdgeInsets.only(
            bottom: 18,
          ),
          padding: const EdgeInsets.all(
            18,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.06,
            ),
            borderRadius: BorderRadius.circular(
              24,
            ),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: labelControllers[index],
                enableInteractiveSelection: true,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: inputStyle(
                  "Field Label",
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: valueControllers[index],
                      enableInteractiveSelection: true,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: inputStyle(
                        "Field Value 1",
                      ),
                    ),
                  ),
                  _buildFieldActions(valueControllers[index]),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: value2Controllers[index],
                      enableInteractiveSelection: true,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: inputStyle(
                        "Field Value 2",
                      ),
                    ),
                  ),
                  _buildFieldActions(value2Controllers[index]),
                ],
              ),
              if (labelControllers.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF061A44),
                          title: const Text(
                            "Remove Field?",
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            "Are you sure you want to remove this field and its contents?",
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                "Remove",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        removeField(
                          index,
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputStyle(
    String label, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(
        color: Colors.white70,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          16,
        ),
        borderSide: BorderSide(
          color: Colors.white.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          16,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFF9D7CFF,
          ),
        ),
      ),
    );
  }

  Widget backHomeButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 18,
        ),
        label: const Text(
          "Back to Home",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildExpiryDatePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Color(0xFF14F1FF), size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Expiry Date",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    selectedExpiryDate == null
                        ? "Not set"
                        : DateFormat('dd MMM yyyy').format(selectedExpiryDate!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (selectedExpiryDate != null)
                IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.redAccent, size: 20),
                  onPressed: () {
                    setState(() {
                      selectedExpiryDate = null;
                      hasChanges = true;
                    });
                  },
                ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedExpiryDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(
                                0xFF14F1FF), // Bright Cyan for OK button and highlights
                            onPrimary: Colors.black,
                            surface: Color(0xFF061A44),
                            onSurface: Colors.white,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(
                                  0xFF14F1FF), // Ensure buttons are bright
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          dialogTheme: DialogThemeData(
                              backgroundColor: const Color(0xFF061A44)),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      selectedExpiryDate = picked;
                      hasChanges = true;
                    });
                  }
                },
                child: Text(
                  selectedExpiryDate == null ? "SET" : "CHANGE",
                  style: const TextStyle(
                      color: Color(0xFF14F1FF), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: commonAppBar(
          context,
          widget.recordTypeName,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(
                  0xFF021F56,
                ),
                Color(
                  0xFF01153B,
                ),
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(
                22,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Mark as Favorite",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: isFavorite,
                        activeThumbColor: const Color(0xFF14F1FF),
                        onChanged: (val) {
                          setState(() {
                            isFavorite = val;
                            hasChanges = true;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExpiryDatePicker(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: labelControllers.length,
                      itemBuilder: (
                        context,
                        index,
                      ) =>
                          buildGlassCard(
                        index,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: addField,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            side: const BorderSide(
                              color: Color(0xFF14F1FF),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "+ Add Field",
                            style: TextStyle(
                              color: Color(0xFF14F1FF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : saveRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.existingRecord == null
                                      ? "SAVE"
                                      : "UPDATE",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
