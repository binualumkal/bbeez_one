import 'package:flutter/material.dart';
import 'package:bbeez_one/platform/services/version_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bbeez_one/platform/themes/app_theme.dart';
import 'package:bbeez_one/apps/one/widgets/common_appbar.dart';
import 'faq_page.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final version = await VersionService.getAppVersion();
    if (mounted) {
      setState(() {
        _version = version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: commonAppBar(
        context,
        "BBeez One",
      ),
      body: Container(
        decoration: AppTheme.pageBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 28,
                ),

                // PAGE TITLE

                //===========================
                // PAGE TITLE
                //===========================

                const Text(
                  "Support",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "We're here to help you.",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 40),

                //===========================
                // SUPPORT ITEMS
                //===========================

                supportCard(
                  icon: Icons.help_outline,
                  title: "FAQ",
                  subtitle: "Find answers to common questions",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FAQPage()),
                    );
                  },
                ),

                const SizedBox(height: 35),

                //===========================
                // SUPPORT INFO
                //===========================

                const Text(
                  "Support Information",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                infoTile(
                  Icons.mail_outline,
                  "Email",
                  "support@bbeezdigital.com",
                ),

                infoTile(
                  Icons.language_outlined,
                  "Website",
                  "https://bbeezdigital.com",
                  onTap: () async {
                    final url = Uri.parse('https://bbeezdigital.com');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),

                infoTile(
                  Icons.access_time,
                  "Response Time",
                  "Within 24 hours",
                ),

                infoTile(
                  Icons.shield_outlined,
                  "Security",
                  "Your data is always protected",
                ),

                const SizedBox(height: 50),

                Center(
                  child: Text(
                    "Version $_version",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //================================
  // SUPPORT CARD
  //================================

  Widget supportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: .08,
        ),
        borderRadius: BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: .12),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(
          18,
        ),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(
              16,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white70,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 5,
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
      ),
    );
  }

  //================================
  // INFO ROW
  //================================

  Widget infoTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white54,
              size: 34,
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: onTap != null
                        ? const Color(0xFF14F1FF)
                        : Colors.white60,
                    fontSize: 15,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
