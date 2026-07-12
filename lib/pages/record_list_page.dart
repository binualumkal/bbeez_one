import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/encryption_service.dart';
import '../models/record_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'add_record_page.dart';
import '../widgets/common_appbar.dart';

class RecordListPage extends StatefulWidget {
  final String domainName;
  final String institutionName;
  final String recordTypeName;

  const RecordListPage({
    super.key,
    required this.domainName,
    required this.institutionName,
    required this.recordTypeName,
  });

  @override
  State<RecordListPage> createState() =>
      _RecordListPageState();
}

class _RecordListPageState
    extends State<RecordListPage> {
  List<RecordModel> records = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final data =
    await DatabaseService
        .getRecords(
      domainName: widget.domainName,
      institutionName: widget.institutionName,
      recordTypeName: widget.recordTypeName,
    );

    if (!mounted) return;

    setState(() {
      records = data;
      isLoading = false;
    });
  }

  bool _isUrl(String text) {
    if (text.isEmpty) return false;
    final trimmed = text.trim().toLowerCase();
    if (trimmed.contains('http://') || trimmed.contains('https://')) return true;
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error launching URL: $e")),
        );
      }
    }
  }

  Widget infoCard() {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),

      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(26),

        gradient:
        const LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,

          colors: [
            Color(0xff16366D),
            Color(0xff102A57),
          ],
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            widget.domainName.toUpperCase(),

            style:
            const TextStyle(
              color:
              Colors.white,

              fontSize: 18,

              fontWeight:
              FontWeight.bold,

              letterSpacing:
              1.2,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            widget.institutionName,

            style:
            TextStyle(
              color:
              Colors.white
                  .withValues(
                alpha: .85,
              ),

              fontSize: 20,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            widget.recordTypeName,

            style:
            TextStyle(
              color:
              Colors.white
                  .withValues(
                alpha: 0.6,
              ),

              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }


  Map<String, dynamic> _getDomainInfo(String domain) {
    switch (domain.toUpperCase()) {
      case 'FINANCE':
        return {
          "icon": Icons.account_balance_rounded,
          "color": Colors.yellowAccent,
        };
      case 'BUSINESS':
        return {
          "icon": Icons.business_center_rounded,
          "color": Colors.purpleAccent,
        };
      case 'DIGITAL':
        return {
          "icon": Icons.language_rounded,
          "color": Colors.cyanAccent,
        };
      case 'PERSONAL':
        return {
          "icon": Icons.person,
          "color": Colors.orangeAccent,
        };
      default:
        return {
          "icon": Icons.folder_rounded,
          "color": Colors.white,
        };
    }
  }

  Widget recordCard(
      RecordModel record,
      int index,
      ) {
    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(
            24),
        gradient:
        const LinearGradient(
          colors: [
            Color(0xff16366D),
            Color(0xff102A57),
          ],
        ),
      ),
      child: ExpansionTile(
        iconColor:
        Colors.white,
        collapsedIconColor:
        Colors.white,

        title: Text(
          record.fields.isNotEmpty ? record.fields.first.label : "Record ${index + 1}",
          style:
          const TextStyle(
            color:
            Colors.white,
            fontSize: 18,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        children: [
          ...record.fields.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final field = entry.value;

                  final v1 = EncryptionService.decrypt(field.value);
                  final v2 = EncryptionService.decrypt(field.value2);

                  return ListTile(
                    title: index == 0
                        ? null
                        : Text(
                            field.label,
                            style: TextStyle(
                              color: _getDomainInfo(widget.domainName)["color"],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          v1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (v2.isNotEmpty)
                          Text(
                            v2,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isUrl(v1) || _isUrl(v2))
                          IconButton(
                            icon: Icon(
                              Icons.open_in_new,
                              color: _getDomainInfo(widget.domainName)["color"],
                              size: 20,
                            ),
                            onPressed: () {
                              if (_isUrl(v1)) {
                                _launchURL(v1);
                              } else if (_isUrl(v2)) {
                                _launchURL(v2);
                              }
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.copy_all,
                            color: _getDomainInfo(widget.domainName)["color"],
                            size: 20,
                          ),
                          onPressed: () {
                            String combinedText = v1;
                            if (v1.isNotEmpty && v2.isNotEmpty) {
                              combinedText += " | $v2";
                            } else if (v1.isEmpty) {
                              combinedText = v2;
                            }

                            Clipboard.setData(ClipboardData(text: combinedText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Copied values of ${field.label}"),
                                duration: const Duration(seconds: 2),
                                backgroundColor: const Color(0xff16366D),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
          ),

          Padding(
            padding:
            const EdgeInsets.only(
                right: 14,
                bottom: 12),

            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .end,

              children: [

                IconButton(
                  icon:
                  Icon(
                    Icons.edit,
                    color: _getDomainInfo(widget.domainName)["color"],
                  ),
                  onPressed:
                      () async {

                    await Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            AddRecordPage(

                              domainName:
                              record.domainName,

                              institutionName:
                              record.institutionName,

                              recordTypeName:
                              record.recordTypeName,

                              existingRecord:
                              record,
                            ),
                      ),
                    );

                    loadRecords();
                  },
                ),

                IconButton(
                  icon:
                  const Icon(
                    Icons.delete,
                    color:
                    Colors.red,
                  ),
                  onPressed:
                      () async {

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF061A44),
                        title: const Text(
                          "Delete Record",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          "Are you sure you want to delete this record?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await NotificationService.cancelNotification(record.key);
                      await DatabaseService
                          .deleteRecord(
                        record.key,
                      );

                      loadRecords();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: commonAppBar(
        context,
        "BBeez One",
      ),

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        _getDomainInfo(widget.domainName)["color"],
        foregroundColor:
        Colors.black,

        child:
        const Icon(Icons.add),

        onPressed: () async {

          await Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  AddRecordPage(
                    domainName:
                    widget.domainName,

                    institutionName:
                    widget.institutionName,

                    recordTypeName:
                    widget.recordTypeName,
                  ),
            ),
          );

          loadRecords();
        },
      ),

      body: Container(

        decoration:
        const BoxDecoration(
          gradient:
          LinearGradient(
            begin:
            Alignment.topCenter,
            end:
            Alignment.bottomCenter,
            colors: [
              Color(0xff08295C),
              Color(0xff001534),
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(
                height: 24,
              ),

              infoCard(),

              Expanded(

                child:
                isLoading

                    ? Center(
                  child:
                  CircularProgressIndicator(
                    color: _getDomainInfo(widget.domainName)["color"],
                  ),
                )

                    : records
                    .isEmpty

                    ? const Center(
                  child:
                  Text(
                    "No Records",
                    style:
                    TextStyle(
                      color:
                      Colors.white,
                    ),
                  ),
                )

                    : ListView.builder(
                  padding:
                  const EdgeInsets.only(
                    bottom:
                    100,
                  ),

                  itemCount:
                  records
                      .length,

                  itemBuilder:
                      (
                      context,
                      index,
                      ) {
                        return recordCard(
                          records[index],
                          index,
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}