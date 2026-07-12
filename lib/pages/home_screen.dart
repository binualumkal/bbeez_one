import 'package:flutter/material.dart';
import '../widgets/menu_drawer.dart';

import '../services/profile_service.dart';
import '../services/database_service.dart';

import '../models/record_model.dart';

import '../theme/app_theme.dart';
import '../services/app_lock_service.dart';
import 'login_screen.dart';

import 'notifications_page.dart';

import 'global_search_page.dart';
import 'institution_page.dart';

import 'record_list_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  String profileName = 'User';

  List<RecordModel>
  favoriteRecords = [];

  Map<String, int>
  domainCounts = {};

  int unreadNotifications = 0;
  Color bellColor = Colors.white;
  String backupStatusText = "Backup healthy";

  @override
  @override
  void initState() {
    super.initState();

    AppLockService.instance.onLock =
        _redirectToLogin;

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      loadInitialData();
    });
  }

  Future<void>
  loadInitialData() async {

    await Future.wait([

      loadProfile(),

      loadFavoriteRecords(),

      loadDomainCounts(),

      loadNotifications(),
    ]);
  }

  void _redirectToLogin() {

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder:
            (_) =>
        const LoginScreen(),
      ),

          (route) => false,
    );
  }

  Future<void>
  loadNotifications() async {

    final status = await DatabaseService.getBackupStatus();
    final expiring = await DatabaseService.getExpiringRecords();
    
    int unread = expiring.length;
    Color color = Colors.greenAccent;
    String text = "Backup healthy";

    final hasExpired = expiring.any((r) => r.expiryDate!.isBefore(DateTime.now()));
    final hasExpiringSoon = expiring.any((r) => r.expiryDate!.isAfter(DateTime.now()));

    if (status['daysSince'] >= 7 || hasExpired) {
      unread += (status['daysSince'] >= 7 ? 1 : 0);
      color = Colors.redAccent;
      text = hasExpired ? "Expired records found" : (status['daysSince'] >= 999 
        ? "No backup yet" 
        : "Overdue: ${status['daysSince']} days");
    } else if (status['newRecords'] >= 5 || status['sensitiveModified'] == true || hasExpiringSoon) {
      unread += (status['newRecords'] >= 5 ? 1 : 0);
      color = Colors.orangeAccent; // Second priority color
      text = hasExpiringSoon 
          ? "Records expiring soon"
          : (status['newRecords'] >= 5 
              ? "${status['newRecords']} records unsaved"
              : "Sensitive data changed");
    }

    if (!mounted) return;

    setState(() {
      unreadNotifications = unread;
      bellColor = color;
      backupStatusText = text;
    });
  }

  Future<void> loadProfile() async {
    final data =
    await ProfileService.getProfile();

    if (!mounted) return;

    setState(() {
      final name =
      (data['name'] ?? '')
          .toString()
          .trim();

      profileName =
      name.isEmpty
          ? 'User'
          : name;
    });
  }

  Future<void>
  loadFavoriteRecords() async {

    final favorites =
    await DatabaseService
        .getFavoriteRecords();

    if (!mounted) return;

    setState(() {
      favoriteRecords = favorites.take(5).toList();
    });
  }

  Future<void>
  loadDomainCounts() async {

    final names = [

      'FINANCE',
      'BUSINESS',
      'DIGITAL',
      'PERSONAL',
    ];

    final values =
    await Future.wait(

      names.map(
        DatabaseService
            .getRecordCountByDomain,
      ),
    );

    final counts =
    Map.fromIterables(
      names,
      values,
    );

    if (!mounted) return;

    setState(() {

      domainCounts =
          counts;
    });
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

  @override
  Widget build(BuildContext context) {
    final domainNames = ['FINANCE', 'BUSINESS', 'DIGITAL', 'PERSONAL'];
    final domains = domainNames.map((name) {
      final info = _getDomainInfo(name);
      return {
        "title": name,
        "icon": info["icon"],
        "color": info["color"],
      };
    }).toList();

    return Scaffold(
      drawer: const MenuDrawer(),

      backgroundColor:
      Theme
          .of(context)
          .scaffoldBackgroundColor,

      body: Stack(

        children: [

          Container(
            decoration:
            AppTheme.pageBackground,
          ),

          SafeArea(

            child:
            SingleChildScrollView(

              padding:
              const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20,
              ),

              child:
              Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  /// HEADER
                  Row(

                    children: [

                      Builder(
                        builder: (context) {
                          return IconButton(

                            onPressed: () {

                              Scaffold.of(
                                context,
                              ).openDrawer();
                            },

                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),

                      const Spacer(),

                      Column(

                        children: [

                          const Text(

                            "BBeez One",

                            style:
                            TextStyle(
                              color:
                              Colors.white,

                              fontSize:
                              26,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(

                            backupStatusText,

                            style:
                            TextStyle(
                              color:
                              bellColor.withValues(alpha: .7),

                              fontSize:
                              13,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: () async {
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsPage(),
                            ),
                          ).then((_) => loadNotifications());
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                unreadNotifications > 0
                                    ? Icons.notifications
                                    : Icons.notifications_none,
                                color: bellColor,
                                size: 28,
                              ),
                            ),
                            if (unreadNotifications > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: IgnorePointer(
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unreadNotifications.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  /// SEARCH
                  GestureDetector(

                    onTap: () {
                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:
                              (_) =>
                          const GlobalSearchPage(),
                        ),
                      );
                    },

                    child:
                    Container(

                      height: 62,

                      decoration:
                      BoxDecoration(

                        color:
                        Colors.white
                            .withValues(
                          alpha: .08,
                        ),

                        borderRadius:
                        BorderRadius.circular(
                          22,
                        ),
                      ),

                      child:
                      Row(

                        children: [

                          const SizedBox(
                            width: 18,
                          ),

                          const Icon(
                            Icons.search,
                            color:
                            Colors.white70,
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          Expanded(

                            child:
                            Text(

                              "Search records...",

                              style:
                              TextStyle(
                                color:
                                Colors.white
                                    .withValues(
                                  alpha: .6,
                                ),
                              ),
                            ),
                          ),

                          Icon(

                            Icons.tune,

                            color:
                            Colors.white
                                .withValues(
                              alpha: .6,
                            ),
                          ),

                          const SizedBox(
                            width: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  Text(

                    "Hi $profileName",

                    style:
                    const TextStyle(

                      color:
                      Colors.white,

                      fontSize:
                      18,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(

                    "Welcome back",

                    style:
                    TextStyle(
                      color:
                      Colors.white
                          .withValues(alpha: .6),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  GridView.builder(

                    shrinkWrap: true,

                    physics:
                    const NeverScrollableScrollPhysics(),

                    itemCount:
                    domains.length,

                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(

                      crossAxisCount: 2,

                      crossAxisSpacing: 12,

                      mainAxisSpacing: 12,

                      childAspectRatio: 1.08,
                    ),

                    itemBuilder:
                        (context,
                        index,) {
                      final domain =
                      domains[index];

                      return GestureDetector(

                        onTap: () {
                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder:
                                  (_) =>
                                  InstitutionPage(

                                    domainName:
                                    domain["title"]
                                    as String,
                                  ),
                            ),
                          );
                        },

                        child:
                        Container(

                          decoration:
                          BoxDecoration(

                            color:
                            Colors.white
                                .withValues(alpha: .05),

                            borderRadius:
                            BorderRadius.circular(
                              22,
                            ),
                          ),

                          child:
                          Column(

                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              Icon(

                                domain["icon"]
                                as IconData,

                                size: 45,

                                color:
                                domain["color"]
                                as Color,
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              Text(

                                domain["title"]
                                as String,

                                style:
                                const TextStyle(

                                  color:
                                  Colors.white,

                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(

                                "${domainCounts[
                                domain["title"]
                                ] ?? 0} records",

                                style:
                                TextStyle(

                                  color:
                                  Colors.white
                                      .withValues(
                                    alpha: .55,
                                  ),

                                  fontSize:
                                  12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  const Text(

                    "Favorites",

                    style:
                    TextStyle(

                      color:
                      Colors.cyanAccent,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (favoriteRecords.isEmpty)

                    const Center(

                      child:
                      Padding(

                        padding:
                        EdgeInsets.all(24),

                        child:
                        Text(

                          "No favorites marked",

                          style:
                          TextStyle(
                            color:
                            Colors.white54,
                          ),
                        ),
                      ),
                    )

                  else
                    ...favoriteRecords.map(

                          (record) {
                        return Card(

                          color:
                          Colors.white
                              .withValues(alpha: .05),

                          child:
                          ListTile(

                            onTap: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder:
                                      (_) =>
                                      RecordListPage(

                                        domainName:
                                        record.domainName,

                                        institutionName:
                                        record.institutionName,

                                        recordTypeName:
                                        record.recordTypeName,
                                      ),
                                ),
                              );
                            },

                            leading: Icon(
                              _getDomainInfo(record.domainName)["icon"],
                              color: _getDomainInfo(record.domainName)["color"],
                            ),

                            title:
                            Text(

                              record.institutionName,

                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle:
                            Text(

                              record.recordTypeName,

                              style:
                              const TextStyle(
                                color:
                                Colors.white54,
                                fontSize: 12,
                              ),
                            ),

                            trailing:
                            const Icon(

                              Icons.chevron_right,

                              color:
                              Colors.white38,
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}