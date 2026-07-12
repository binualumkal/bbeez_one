import 'package:flutter/material.dart';
import 'package:bbeez_one/platform/services/version_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bbeez_one/apps/one/widgets/common_appbar.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
      backgroundColor: Colors.black,
      appBar: commonAppBar(
        context,
        "About",
        isBlack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// Logo
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/bbeez_logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'BBeez One',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Version $_version',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: Color(0xFF14F1FF),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Secure Record Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BBeez One helps organize and protect important records with a clean, secure, and efficient experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _infoTile(
              icon: Icons.security,
              title: 'Security',
              subtitle: 'Password and biometric protection supported.',
            ),

            const SizedBox(height: 12),

            _infoTile(
              icon: Icons.storage,
              title: 'Storage',
              subtitle:
                  'Records are stored locally for fast and secure access.',
            ),

            const SizedBox(height: 12),

            _infoTile(
              icon: Icons.phone_android,
              title: 'Platform',
              subtitle: 'Built using Flutter framework.',
            ),

            const SizedBox(height: 12),

            _infoTile(
              icon: Icons.language,
              title: 'Website',
              subtitle: 'https://bbeezdigital.com',
              onTap: () async {
                final url = Uri.parse('https://bbeezdigital.com');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),

            const SizedBox(height: 40),

            const Divider(color: Colors.white10),

            const SizedBox(height: 16),

            const Text(
              '© 2025 BBeez Digital Secure',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: onTap != null ? const Color(0xFF14F1FF) : Colors.white54,
            decoration: onTap != null ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }
}
