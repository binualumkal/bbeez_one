import 'package:flutter/material.dart';

import '../models/record_type_model.dart';
import '../services/database_service.dart';
import 'record_list_page.dart';

class RecordTypePage extends StatefulWidget {
  final String domainName;
  final String institutionName;

  const RecordTypePage({
    super.key,
    required this.domainName,
    required this.institutionName,
  });

  @override
  State<RecordTypePage> createState() =>
      _RecordTypePageState();
}

class _RecordTypePageState
    extends State<RecordTypePage> {
  List<RecordTypeModel> recordTypes =
  [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecordTypes();
  }

  Future<void> loadRecordTypes()
  async {
    final data =
    await DatabaseService
        .getRecordTypes(
      domainName:
      widget.domainName,

      institutionName:
      widget
          .institutionName,
    );

    final unique =
    <String,
        RecordTypeModel>{};

    for (final item in data) {
      unique[item.name
          .toLowerCase()] = item;
    }

    if (!mounted) return;

    setState(() {
      recordTypes =
          unique.values.toList();

      isLoading = false;
    });
  }

  Future<void>
  addRecordTypeDialog()
  async {
    final controller =
    TextEditingController();

    await showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          backgroundColor:
          const Color(
              0xff102B5C),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius
                .circular(
                24),
          ),

          title:
          const Text(
            "Add Record Type",

            style: TextStyle(
              color:
              Colors
                  .white,
            ),
          ),

          content:
          TextField(
            controller:
            controller,

            style:
            const TextStyle(
              color:
              Colors
                  .white,
            ),

            decoration:
            InputDecoration(
              hintText:
              "Record Type Name",

              hintStyle:
              TextStyle(
                color: Colors
                    .white
                    .withValues(
                    alpha: .5),
              ),

              filled:
              true,

              fillColor:
              const Color(
                  0xff18386B),

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

              child:
              const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(

              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                Colors
                    .cyanAccent,

                foregroundColor:
                Colors
                    .black,
              ),

              onPressed:
                  () async {

                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  return;
                }

                await DatabaseService
                    .addRecordType(
                  name: newName,

                  domainName:
                  widget
                      .domainName,

                  institutionName:
                  widget
                      .institutionName,
                );

                if (!mounted) {
                  return;
                }

                Navigator.pop(
                    context);

                // Navigate to RecordListPage automatically
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordListPage(
                      domainName: widget.domainName,
                      institutionName: widget.institutionName,
                      recordTypeName: newName,
                    ),
                  ),
                );

                loadRecordTypes();
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
          "guideline": "Enter your account or record type.",
        };
      case 'BUSINESS':
        return {
          "icon": Icons.business_center_rounded,
          "color": Colors.purpleAccent,
          "guideline": "Enter your business record type.",
        };
      case 'DIGITAL':
        return {
          "icon": Icons.language_rounded,
          "color": Colors.cyanAccent,
          "guideline": "Enter your digital account or service type.",
        };
      case 'PERSONAL':
        return {
          "icon": Icons.person,
          "color": Colors.orangeAccent,
          "guideline": "Enter your personal record type.",
        };
      default:
        return {
          "icon": Icons.folder_rounded,
          "color": Colors.white,
          "guideline": "Enter your record type.",
        };
    }
  }

  Widget buildCard(
      RecordTypeModel item) {
    return Dismissible(

      key:
      Key(
        "rt_${item.key}",
      ),

      direction:
      DismissDirection
          .endToStart,

      background:
      Container(

        margin:
        const EdgeInsets
            .only(
          left: 20,
          right: 20,
          bottom: 18,
        ),

        alignment:
        Alignment
            .centerRight,

        padding:
        const EdgeInsets
            .only(
          right: 30,
        ),

        decoration:
        BoxDecoration(
          color:
          Colors.red,

          borderRadius:
          BorderRadius
              .circular(
              24),
        ),

        child:
        const Icon(
          Icons
              .delete_forever,

          color:
          Colors
              .white,

          size:
          30,
        ),
      ),

      confirmDismiss:
          (_) async {

        final result =
        await showDialog<
            bool>(
          context:
          context,

          builder:
              (_) =>
              AlertDialog(
                title:
                const Text(
                  "Delete Record Type",
                ),

                content:
                Text(
                  "Delete '${item.name}'?\n\nAll records inside it will also be deleted.",
                ),

                actions: [

                  TextButton(
                    onPressed:
                        () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },

                    child:
                    const Text(
                      "Cancel",
                    ),
                  ),

                  ElevatedButton(
                    onPressed:
                        () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },

                    child:
                    const Text(
                      "Delete",
                    ),
                  ),
                ],
              ),
        );

        return result ??
            false;
      },

      onDismissed:
          (_) async {

        await DatabaseService
            .deleteRecordType(
          item.key,
        );

        await loadRecordTypes();

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
            context)
            .showSnackBar(

          SnackBar(
            content:
            Text(
              "${item.name} deleted",
            ),
          ),
        );
      },

      child:
      Container(

        margin:
        const EdgeInsets
            .only(
          left: 20,
          right: 20,
          bottom: 18,
        ),

        decoration:
        BoxDecoration(

          borderRadius:
          BorderRadius
              .circular(
              24),

          gradient:
          const LinearGradient(
            colors: [

              Color(
                  0xff16366D),

              Color(
                  0xff102A57),
            ],
          ),
        ),

        child:
        ListTile(

          contentPadding:
          const EdgeInsets
              .symmetric(
            horizontal:
            22,

            vertical:
            18,
          ),

          leading:
          Container(

            height:
            55,

            width:
            55,

            decoration:
            BoxDecoration(

              color: (_getDomainInfo(widget.domainName)["color"] as Color).withValues(alpha: .15),

              borderRadius:
              BorderRadius
                  .circular(
                  16),
            ),

            child:
            Icon(
              _getDomainInfo(widget.domainName)["icon"],

              color: _getDomainInfo(widget.domainName)["color"],
            ),
          ),

          title:
          Text(
            item.name,

            style:
            const TextStyle(
              color:
              Colors
                  .white,

              fontSize:
              18,

              fontWeight:
              FontWeight
                  .w600,
            ),
          ),

          trailing:
          const Icon(
            Icons
                .swipe_left,

            color:
            Colors
                .white54,
          ),

          onTap:
              () {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder:
                    (_) =>
                    RecordListPage(

                      domainName:
                      widget
                          .domainName,

                      institutionName:
                      widget
                          .institutionName,

                      recordTypeName:
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

      floatingActionButton:
      FloatingActionButton(

        backgroundColor:
        Colors
            .cyanAccent,

        foregroundColor:
        Colors.black,

        onPressed:
        addRecordTypeDialog,

        child:
        const Icon(
          Icons.add,
        ),
      ),

      body:
      Container(

        decoration:
        const BoxDecoration(

          gradient:
          LinearGradient(

            begin:
            Alignment
                .topCenter,

            end:
            Alignment
                .bottomCenter,

            colors: [

              Color(
                  0xff08295C),

              Color(
                  0xff001534),
            ],
          ),
        ),

        child:
        SafeArea(

          child:
          Column(

            children: [

              const SizedBox(
                  height:
                  12),

              Row(

                children: [

                  IconButton(

                    color:
                    Colors
                        .white,

                    icon:
                    const Icon(
                      Icons
                          .arrow_back,
                    ),

                    onPressed:
                        () {
                      Navigator.pop(
                          context);
                    },
                  ),

                  Expanded(

                    child:
                    Column(

                      children: [

                        Text(

                          widget
                              .institutionName,

                          style:
                          const TextStyle(

                            color:
                            Colors
                                .white,

                            fontSize:
                            18,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        const SizedBox(
                            height:
                            4),

                        Text(

                          widget
                              .domainName,

                          style:
                          TextStyle(

                            color:
                            Colors
                                .white
                                .withValues(
                                alpha: .55),

                            fontSize:
                            12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(

                    color:
                    Colors
                        .white,

                    icon:
                    const Icon(
                      Icons.home,
                    ),

                    onPressed:
                        () {
                      Navigator.popUntil(
                        context,
                            (route) =>
                        route
                            .isFirst,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _getDomainInfo(widget.domainName)["guideline"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(
                  height:
                  22),

              Expanded(

                child:
                isLoading

                    ? Center(
                  child:
                  CircularProgressIndicator(
                    color: _getDomainInfo(widget.domainName)["color"],
                  ),
                )

                    : recordTypes
                    .isEmpty

                    ? const Center(
                  child:
                  Text(
                    "No Record Types",

                    style:
                    TextStyle(
                      color:
                      Colors.white,
                    ),
                  ),
                )

                    : ListView
                    .builder(

                  padding:
                  const EdgeInsets.only(
                    top:
                    8,

                    bottom:
                    120,
                  ),

                  itemCount:
                  recordTypes
                      .length,

                  itemBuilder:
                      (
                      _,
                      i,
                      ) {

                    return buildCard(
                      recordTypes[
                      i],
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