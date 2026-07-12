import 'package:flutter/material.dart';
import '../screens/main_screen.dart';

PreferredSizeWidget commonAppBar(
  BuildContext context,
  String title, {
  bool isBlack = false,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 82,
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: Container(
      /// MATCH HOME SCREEN TOP EXACTLY
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isBlack
              ? [Colors.black, Colors.black]
              : [
                  const Color(0xFF082E69), // same blue as Home
                  const Color(0xFF08306E),
                ],
        ),
      ),

      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  else
                    const SizedBox(
                        width: 48), // Maintain spacing if no back button

                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainScreen(
                            initialIndex: 0,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            Text(
              "Encrypted Workspace",
              style: TextStyle(
                color: Colors.white.withValues(alpha: .65),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
