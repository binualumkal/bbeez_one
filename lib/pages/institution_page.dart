import 'package:flutter/material.dart';

import '../models/institution_model.dart';
import '../services/database_service.dart';
import 'record_type_page.dart';
import '../widgets/common_appbar.dart';
import '../theme/app_theme.dart';

class InstitutionPage extends StatefulWidget {
  final String domainName;

  const InstitutionPage({
    super.key,
    required this.domainName,
  });

  @override
  State<InstitutionPage> createState() =>
      _InstitutionPageState();
}

class _InstitutionPageState
    extends State<InstitutionPage> {
  List<InstitutionModel> institutions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInstitutions();
  }

  Future<void> loadInstitutions() async {
    final data =
    await DatabaseService
        .getInstitutionsByDomain(
      widget.domainName,
    );

    final unique =
    <String, InstitutionModel>{};

    for (final item in data) {
      unique[item.name.toLowerCase()] =
          item;
    }

    if (!mounted) return;

    setState(() {
      institutions =
          unique.values.toList();

      isLoading = false;
    });
  }

  Future<void> addInstitutionDialog()
  async {
    final controller =
    TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor:
          AppTheme.surface,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
                24),
          ),

          title: const Text(
            "Add Institution",
          ),

          content: TextField(
            controller:
            controller,

            style:
            const TextStyle(
              color:
              Colors.white,
            ),

            decoration:
            InputDecoration(
              hintText:
              "Institution Name",

              hintStyle:
              TextStyle(
                color:
                Colors.white
                    .withValues(
                    alpha: .5),
              ),

              filled: true,

              fillColor:
              Colors.white
                  .withValues(
                  alpha: .06),

              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(
                    18),

                borderSide:
                BorderSide
                    .none,
              ),
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                    context);
              },

              child: const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(
              onPressed:
                  () async {

                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  return;
                }

                await DatabaseService
                    .addInstitution(
                  name: newName,
                  domainName:
                  widget
                      .domainName,
                );

                if (!mounted) {
                  return;
                }

                Navigator.pop(
                    context);

                // Navigate to RecordTypePage automatically
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordTypePage(
                      domainName: widget.domainName,
                      institutionName: newName,
                    ),
                  ),
                );

                loadInstitutions();
              },

              child:
              const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> _getDomainInfo(String domain) {
    switch (domain.toUpperCase()) {
      case 'FINANCE':
        return {
          "icon": Icons.account_balance_rounded,
          "color": Colors.yellowAccent,
          "guideline": "Enter your bank, finance company, or investment provider.",
        };
      case 'BUSINESS':
        return {
          "icon": Icons.business_center_rounded,
          "color": Colors.purpleAccent,
          "guideline": "Enter your company, vendor, or business service provider.",
        };
      case 'DIGITAL':
        return {
          "icon": Icons.language_rounded,
          "color": Colors.cyanAccent,
          "guideline": "Enter a website, email account, or online Services.",
        };
      case 'PERSONAL':
        return {
          "icon": Icons.person,
          "color": Colors.orangeAccent,
          "guideline": "Enter personal records, memberships, IDs, utilities, healthcare providers, or important contacts.",
        };
      default:
        return {
          "icon": Icons.folder_rounded,
          "color": Colors.white,
          "guideline": "Enter your institutions or providers.",
        };
    }
  }

  Widget buildCard(InstitutionModel item) {
    return Dismissible(
      key: Key(item.key.toString()),

      direction: DismissDirection.endToStart,

      background: Container(
        margin: const EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: 16,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Institution?"),
            content: const Text(
              "All Record Types and Records inside this Institution will be deleted permanently.",
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
      },

      onDismissed: (_) async {
        await DatabaseService
            .deleteInstitution(item.key);

        loadInstitutions();

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              "${item.name} deleted",
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: 16,
        ),

        decoration:
        AppTheme.glassCard.copyWith(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 18,
            ),
          ],
        ),

        child: ListTile(
          leading: Icon(
            _getDomainInfo(widget.domainName)["icon"],
            color: _getDomainInfo(widget.domainName)["color"],
          ),

          title: Text(
            item.name,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),

          trailing: const Icon(
            Icons.swipe_left,
            color: Colors.white54,
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    RecordTypePage(
                      domainName:
                      widget.domainName,
                      institutionName:
                      item.name,
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar:
      commonAppBar(
        context,
        "BBeez One",
      ),

      floatingActionButton:
      FloatingActionButton(

        onPressed:
        addInstitutionDialog,

        child:
        const Icon(
          Icons.add,
          color:
          Colors.black,
        ),
      ),

      body:
      Container(

        decoration:
        AppTheme
            .pageBackground,

        child:
        SafeArea(

          child:
          Column(

            children: [

              const SizedBox(
                height: 18,
              ),

              Padding(

                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal:
                  20,
                ),

                child:
                Text(

                  widget
                      .domainName,

                  textAlign:
                  TextAlign
                      .center,

                  style:
                  Theme.of(
                    context,
                  )
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontSize:
                    26,

                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                child: Text(
                  _getDomainInfo(widget.domainName)["guideline"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              Expanded(

                child:
                isLoading

                    ? Center(
                  child:
                  CircularProgressIndicator(
                    color: _getDomainInfo(widget.domainName)["color"],
                  ),
                )

                    : institutions.isEmpty
                        ? const Center(
                            child: Text(
                              "No institutions added yet",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(

                  padding:
                  const EdgeInsets
                      .only(
                    top:
                    12,

                    bottom:
                    100,
                  ),

                  itemCount:
                  institutions
                      .length,

                  itemBuilder:
                      (
                      context,
                      index,
                      ) {

                    return buildCard(
                      institutions[
                      index],
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