import 'package:flutter/material.dart';
import 'package:bbeez_one/platform/services/version_service.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
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
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _faq(
            '1. How do I securely organize my information in BBeez One?',
            'BBeez One helps you securely organize and access your important personal, financial, business, and digital information in one place.\n\n'
                'Step 1: Choose a Domain\n'
                'Select the category where your information belongs:\n'
                '🏦 Finance – Bank accounts, loans, cards, investments, insurance, etc.\n'
                '💼 Business – Company credentials, GST, MCA, licenses, vendors, software licenses, etc.\n'
                '🌐 Digital – Website logins, email accounts, social media, subscriptions, cloud services, etc.\n'
                '👤 Personal – Personal documents, memberships, healthcare records, IDs, and other personal information.\n\n'
                'Step 2: Add an Institution or Organization\n'
                'Tap the + button and enter the institution, organization, service, or provider name.\n'
                'Examples:\n'
                'SBI Cochin\n'
                'ICICI Bank Mumbai(Fort)\n'
                'Bajaj Finance\n'
                'GST Portal\n'
                'Gmail\n'
                'Passport\n'
                'Each institution becomes a separate record container.\n\n'
                'Step 3: Select a Record Type\n'
                'Choose the type of information you want to store.\n\n'
                'Finance Examples\n'
                'Savings Account\n'
                'Current Account\n'
                'Credit Card\n'
                'Fixed Deposit\n'
                'Loan Account\n\n'
                'Business Examples\n'
                'Company Credentials\n'
                'GST Account\n'
                'Software License\n'
                'Vendor Account\n\n'
                'Digital Examples\n'
                'Email Account\n'
                'Website Login\n'
                'Social Media Account\n'
                'Cloud Storage\n\n'
                'Personal Examples\n'
                'Passport\n'
                'Driving Licence\n'
                'Medical Record\n'
                'Membership Card\n\n'
                'Step 4: Add Your Information\n'
                'Create one or more information blocks.\n'
                'Each block can contain:\n'
                'A label\n'
                'Important values\n'
                'Login credentials\n'
                'Account details\n'
                'Notes\n'
                'Reference numbers\n\n'
                'Examples\n'
                'Account Details\n'
                'Account Number\n'
                'IFSC Code\n\n'
                'Login\n'
                'Username\n'
                'Password\n\n'
                'Insurance\n'
                'Policy Number\n'
                'Customer ID\n\n'
                'Use + Add Field whenever you need additional information blocks.\n\n'
                'Step 5: Save Securely\n'
                'Tap Save to securely store your information.\n'
                'Your records are organized automatically as:\n'
                'Domain → Institution → Record Type → Information Blocks\n\n'
                'Step 6: Access Your Records\n'
                'Navigate through:\n'
                'Home → Domain → Institution → Record Type\n\n'
                'You can view, edit, copy, or delete stored information whenever needed.\n\n'
                'Favorites\n'
                'Mark frequently used records as Favorites for quick access from the Home Screen.\n\n'
                'Search\n'
                'Use the search bar on the Home Screen to quickly find records, institutions, or account details.\n\n'
                'Example Structure\n'
                'Finance\n'
                '└─ SBI Cochin\n'
                '    └─ Savings Account\n'
                '        ├─ Account Details\n'
                '        │ ├─ Account Number\n'
                '        │ └─ IFSC Code\n'
                '        └─ Login\n'
                '           ├─ Username\n'
                '           └─ Password',
          ),
          _faq(
            '2. Is my data encrypted?',
            'Yes. Sensitive information is encrypted before storage to help protect your privacy.',
          ),
          _faq(
            '3. Can I search records?',
            'Yes. Use Global Search to quickly find categories and records.',
          ),
          _faq(
            '4. What is the Secret field?',
            'The Secret field is designed for sensitive information such as passwords, secure notes, private references, and confidential details.',
          ),
          _faq(
            '5. Will my secret data appear normally after reopening the app?',
            'Yes. Data is stored securely and automatically decrypted when viewed inside the app.',
          ),
          _faq(
            '6. How do I create a new record?',
            '1. Open the required category:\n\n'
                '• FINANCE\n'
                '• BUSINESS\n'
                '• DIGITAL\n'
                '• PERSONAL\n\n'
                '2. Tap + Add\n'
                '3. Enter details\n'
                '4. Tap Save\n\n'
                'Your record will be stored securely.',
          ),
          _faq(
            '7. How do I edit a record?',
            'Open the record → Tap Edit → Update → Save.',
          ),
          _faq(
            '8. Can I delete records?',
            'Yes. Open the record and choose Delete.\n\nDeleted records cannot be recovered.',
          ),
          _faq(
            '9. Does BBeez One support backup?',
            'Yes.\n\nRecommended:\n'
                '• Enable regular backup\n'
                '• Backup before app updates',
          ),
          _faq(
            '10. Is my data shared with anyone?',
            'No. Your information remains stored only within your system and is not shared with us.\n\nSensitive data is protected using encryption inside the app.',
          ),
          _faq(
            '11. I forgot my password. What should I do?',
            'If biometric unlock is enabled and access is available:\n\n'
                'Open Settings → Reset Password\n\n'
                'Authenticate using biometric verification\n'
                'Enter a new password\n\n'
                'If both password and biometric access are unavailable, recovery is currently not supported.',
          ),
          _faq(
            '12. App feels slow or search is not updating?',
            'Try:\n\n'
                '• Close and reopen app\n'
                '• Refresh records\n'
                '• Check available device storage',
          ),
          _faq(
            '13. How do I contact support?',
            'Email: support@bbeezdigital.com\n\n'
                'Response target: Usually within 24 hours',
          ),
          _faq(
            '14. What is the current version?',
            'Version $_version',
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'BBeez One',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _faq(
    String title,
    String content,
  ) {
    return Card(
      color: const Color(0xFF10253F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ExpansionTile(
        collapsedIconColor: Colors.white70,
        iconColor: Colors.cyanAccent,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              18,
            ),
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
