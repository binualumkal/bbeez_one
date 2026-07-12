import 'package:flutter/material.dart';
import '../models/record_model.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_appbar.dart';
import 'add_record_page.dart';
import 'data_management_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Map<String, dynamic> status = {};
  List<RecordModel> expiringRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final statusData = await DatabaseService.getBackupStatus();
    final records = await DatabaseService.getExpiringRecords();
    
    if (!mounted) return;
    setState(() {
      status = statusData;
      expiringRecords = records;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.pageBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: commonAppBar(
          context,
          "Notifications",
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final List<Widget> alerts = [];

    // Expiry Alerts
    for (final record in expiringRecords) {
      final daysLeft = record.expiryDate!.difference(DateTime.now()).inDays;
      final isExpired = record.expiryDate!.isBefore(DateTime.now());

      alerts.add(_alertCard(
        icon: Icons.event_busy,
        color: isExpired ? Colors.redAccent : Colors.orangeAccent,
        title: isExpired ? "Record Expired" : "Record Expiring Soon",
        message: isExpired 
            ? "${record.institutionName} - ${record.recordTypeName} has expired."
            : "${record.institutionName} - ${record.recordTypeName} will expire in $daysLeft days.",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddRecordPage(
                domainName: record.domainName,
                institutionName: record.institutionName,
                recordTypeName: record.recordTypeName,
                existingRecord: record,
              ),
            ),
          ).then((_) => _loadData()); // Refresh if changed
        },
      ));
    }

    // Check conditions
    if (status['daysSince'] >= 7) {
      alerts.add(_alertCard(
        icon: Icons.history,
        color: Colors.redAccent,
        title: "Backup Overdue",
        message: status['daysSince'] >= 999 
          ? "You haven't created a backup yet. Please secure your data now."
          : "Your last backup was ${status['daysSince']} days ago. Please secure your data now.",
      ));
    }

    if (status['newRecords'] >= 5) {
      alerts.add(_alertCard(
        icon: Icons.fiber_new,
        color: Colors.yellowAccent,
        title: "New Data Found",
        message: "You have ${status['newRecords']} new records that are not yet backed up.",
      ));
    }

    if (status['sensitiveModified'] == true) {
      alerts.add(_alertCard(
        icon: Icons.security,
        color: Colors.yellowAccent,
        title: "Sensitive Changes",
        message: "Modifications to Finance/Personal records detected. Backup is suggested.",
      ));
    }

    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.greenAccent.withValues(alpha: .5), size: 60),
            const SizedBox(height: 16),
            const Text(
              "No new notifications",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Last backup: ${status['daysSince'] == 0 ? 'Today' : '${status['daysSince']} days ago'}",
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 32),
            _buildManageButton(),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const Text(
          "Security Alerts",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...alerts,
        const SizedBox(height: 24),
        _buildManageButton(),
      ],
    );
  }

  Widget _buildManageButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DataManagementPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.surface,
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.settings_applications),
        label: const Text(
          "GO TO DATA MANAGEMENT",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
    );
  }

  Widget _alertCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
