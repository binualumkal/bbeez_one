import 'package:flutter/material.dart';

class LockedScreen extends StatelessWidget {
  const LockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.lock,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Authentication Failed',
            ),
          ],
        ),
      ),
    );
  }
}
