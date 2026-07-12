import 'package:flutter/material.dart';

import '../models/record_model.dart';
import '../services/database_service.dart';

import '../pages/record_list_page.dart';
import '../services/encryption_service.dart';

import '../widgets/common_appbar.dart';

class SearchResultItem {
  final String domainName;
  final String institutionName;
  final String recordTypeName;
  final int count;

  SearchResultItem({
    required this.domainName,
    required this.institutionName,
    required this.recordTypeName,
    required this.count,
  });
}

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() =>
      _GlobalSearchPageState();
}

class _GlobalSearchPageState
    extends State<GlobalSearchPage> {
  final controller =
  TextEditingController();

  List<RecordModel> allRecords =
  [];

  List<SearchResultItem>
  results = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    loadRecords();

    controller.addListener(() {
      filter(
        controller.text,
      );
    });
  }

  Future<void>
  loadRecords() async {
    setState(() {
      isLoading = true;
    });

    allRecords =
    await DatabaseService
        .getAllRecords();

    setState(() {
      isLoading = false;
    });
  }

  void filter(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() => results = []);
      return;
    }

    final grouped =
    <String, SearchResultItem>{};

    for (final record in allRecords) {

      bool matched = false;

      // Search visible fields first
      final normalSearch = [
        record.domainName,
        record.institutionName,
        record.recordTypeName,
      ]
          .join(" ")
          .toLowerCase();

      if (normalSearch.contains(q)) {
        matched = true;
      }

      // Search encrypted fields
      if (!matched) {
        for (final field
        in record.fields) {

          try {

            final label =
            field.label
                .toLowerCase();

            final value =
            EncryptionService
                .decrypt(
              field.value
                  .toString(),
            )
                .toLowerCase();

            if (label.contains(q) ||
                value.contains(q)) {
              matched = true;
              break;
            }

          } catch (_) {}
        }
      }

      if (!matched) continue;

      final key =
          "${record.domainName}|"
          "${record.institutionName}|"
          "${record.recordTypeName}";

      grouped.update(
        key,
            (existing) =>
            SearchResultItem(
              domainName:
              existing.domainName,
              institutionName:
              existing
                  .institutionName,
              recordTypeName:
              existing
                  .recordTypeName,
              count:
              existing.count + 1,
            ),

        ifAbsent: () =>
            SearchResultItem(
              domainName:
              record.domainName,
              institutionName:
              record.institutionName,
              recordTypeName:
              record.recordTypeName,
              count: 1,
            ),
      );
    }

    setState(() {
      results =
          grouped.values.toList();
    });
  }

  Widget buildCard(
      SearchResultItem item) {
    return Container(
      margin:
      const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 16,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white
            .withValues(
          alpha: .05,
        ),

        borderRadius:
        BorderRadius.circular(
          24,
        ),
      ),

      child: ListTile(
        contentPadding:
        const EdgeInsets.all(
          18,
        ),

        onTap: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder:
                  (_) =>
                  RecordListPage(
                    domainName:
                    item.domainName,

                    institutionName:
                    item
                        .institutionName,

                    recordTypeName:
                    item
                        .recordTypeName,
                  ),
            ),
          );
        },

        leading:
        const Icon(
          Icons.lock,

          color:
          Colors.cyanAccent,
        ),

        title:
        Text(
          item.recordTypeName,

          style:
          const TextStyle(
            color:
            Colors.white,

            fontWeight:
            FontWeight.bold,

            fontSize:
            18,
          ),
        ),

        subtitle:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [

            const SizedBox(
              height: 6,
            ),

            Text(
              item
                  .institutionName,

              style:
              const TextStyle(
                color:
                Colors
                    .white70,
              ),
            ),

            Text(
              "${item.count} records",

              style:
              const TextStyle(
                color:
                Colors
                    .white54,
              ),
            ),
          ],
        ),

        trailing:
        const Icon(
          Icons.chevron_right,

          color:
          Colors.white54,
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

      body: Container(
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
                0xFF082F68,
              ),
              Color(
                0xFF011531,
              ),
            ],
          ),
        ),

        child:
        Column(
          children: [

            const SizedBox(
              height: 20,
            ),

            Padding(
              padding:
              const EdgeInsets
                  .all(
                20,
              ),

              child:
              TextField(
                controller:
                controller,

                autofocus:
                true,

                style:
                const TextStyle(
                  color:
                  Colors
                      .white,
                ),

                decoration:
                InputDecoration(

                  hintText:
                  "Search record type...",

                  hintStyle:
                  const TextStyle(
                    color:
                    Colors
                        .white60,
                  ),

                  prefixIcon:
                  const Icon(
                    Icons.search,

                    color:
                    Colors
                        .white70,
                  ),

                  filled:
                  true,

                  fillColor:
                  Colors
                      .white
                      .withValues(
                    alpha: .08,
                  ),

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      22,
                    ),

                    borderSide:
                    BorderSide
                        .none,
                  ),
                ),
              ),
            ),

            Expanded(

              child:
              isLoading

                  ? const Center(
                child:
                CircularProgressIndicator(),
              )

                  : controller
                  .text
                  .isEmpty

                  ? Center(
                child:
                Text(

                  "Start typing to search",

                  style:
                  TextStyle(
                    color:
                    Colors.white
                        .withValues(
                      alpha: .5,
                    ),

                    fontSize:
                    18,
                  ),
                ),
              )

                  : ListView.builder(

                itemCount:
                results.length,

                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  return buildCard(
                    results[
                    index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}