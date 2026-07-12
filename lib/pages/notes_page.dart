import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_lock_service.dart';

import '../theme/app_theme.dart';
import '../widgets/common_appbar.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final noteController =
  TextEditingController();

  List<Map<String, dynamic>> notes =
  [];

  int? selectedIndex;

  Timer? autoSaveTimer;

  @override
  void initState() {
    super.initState();
    loadNotes();
    // Register listener to save data before app locks or goes to background
    AppLockService.instance.addLockListener(_saveCurrentNote);
  }

  @override
  void dispose() {
    // Save one last time before disposing
    _saveCurrentNote();
    AppLockService.instance.removeLockListener(_saveCurrentNote);

    autoSaveTimer?.cancel();
    noteController.dispose();
    super.dispose();
  }

  Future<void> loadNotes() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    final data =
        prefs.getStringList(
          "notes",
        ) ??
            [];

    notes =
        data
            .map(
              (e) => Map<String,
              dynamic>.from(
            jsonDecode(e),
          ),
        )
            .toList();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> saveStorage() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setStringList(
      "notes",
      notes
          .map(
            (e) =>
            jsonEncode(e),
      )
          .toList(),
    );
  }

  void scheduleSave() {
    // Reset app lock timer when user types
    AppLockService.instance.resetTimer();

    autoSaveTimer?.cancel();

    autoSaveTimer = Timer(
      const Duration(milliseconds: 600),
      _saveCurrentNote,
    );
  }

  Future<void> _saveCurrentNote() async {
    final text = noteController.text.trim();

    if (text.isEmpty) {
      return;
    }

    final note = {
      "text": text,
      "date": DateTime.now().toIso8601String(),
    };

    if (selectedIndex == null) {
      notes.insert(0, note);
      selectedIndex = 0;
    } else {
      notes[selectedIndex!] = note;
    }

    await saveStorage();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> deleteNote(
      int index) async {
    notes.removeAt(index);

    await saveStorage();

    if (selectedIndex ==
        index) {
      selectedIndex = null;

      noteController.clear();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void openNote(
      int index) {
    selectedIndex =
        index;

    noteController.text =
    notes[index]["text"];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      // CLOSE KEYBOARD WHEN TAPPING OUTSIDE
      onTap: () {

        FocusScope.of(context)
            .unfocus();
      },

      child: Container(

        decoration:
        AppTheme.pageBackground,

        child: Scaffold(

          resizeToAvoidBottomInset:
          true,

          backgroundColor:
          Colors.transparent,

          appBar:
          commonAppBar(
            context,
            "BBeez One",
          ),

          body:

          AnimatedPadding(

            duration:
            const Duration(
              milliseconds: 180,
            ),

            padding:

            EdgeInsets.only(

              bottom:

              MediaQuery.of(
                  context)
                  .viewInsets
                  .bottom,
            ),

            child:

            SafeArea(

              child:

              Padding(

                padding:
                const EdgeInsets.all(
                    22),

                child:

                Column(

                  children: [

                    const SizedBox(
                        height: 8),

                    const Text(

                      "Quick Notes",

                      style:
                      TextStyle(
                        color:
                        Colors.white60,
                      ),
                    ),

                    const SizedBox(
                        height: 16),

                    Expanded(

                      child:

                      Column(

                        children: [

                          // SMALLER NOTE BOX

                          Expanded(

                            flex: 4,

                            child:

                            Container(

                              padding:
                              const EdgeInsets
                                  .all(
                                  20),

                              decoration:
                              BoxDecoration(

                                color:
                                Colors.white,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                    30),

                                boxShadow: [

                                  BoxShadow(

                                    color:
                                    Colors
                                        .black26,

                                    blurRadius:
                                    18,
                                  ),
                                ],
                              ),

                              child:

                              TextField(

                                controller:
                                noteController,

                                expands:
                                true,

                                maxLines:
                                null,

                                keyboardType:
                                TextInputType
                                    .multiline,

                                textAlignVertical:
                                TextAlignVertical
                                    .top,

                                scrollPadding:
                                const EdgeInsets
                                    .only(
                                    bottom:
                                    40),

                                onChanged:
                                    (_) {

                                  scheduleSave();
                                },

                                cursorColor:
                                AppTheme
                                    .bgTop,

                                style:
                                const TextStyle(

                                  color:
                                  Colors.black,

                                  fontSize:
                                  18,

                                  height:
                                  1.5,
                                ),

                                decoration:
                                const InputDecoration(

                                  border:
                                  InputBorder
                                      .none,

                                  hintText:

                                  "Write quick notes",

                                  hintStyle:

                                  TextStyle(
                                    color:
                                    Colors
                                        .black45,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                              height:
                              6),

                          Align(

                            alignment:
                            Alignment
                                .centerRight,

                            child:

                            TextButton.icon(

                              onPressed:
                                  () {

                                selectedIndex =
                                null;

                                noteController
                                    .clear();

                                FocusScope.of(
                                    context)
                                    .unfocus();

                                setState(
                                        () {});
                              },

                              icon:
                              const Icon(
                                  Icons.add),

                              label:
                              const Text(
                                  "New Note"),
                            ),
                          ),

                          const SizedBox(
                              height:
                              6),

                          Align(

                            alignment:
                            Alignment
                                .centerLeft,

                            child:

                            Text(

                              "Recent Notes",

                              style:
                              TextStyle(

                                color:
                                AppTheme
                                    .primaryAccent,

                                fontSize:
                                20,
                              ),
                            ),
                          ),

                          const SizedBox(
                              height:
                              6),

                          // MORE SPACE FOR CARDS

                          Expanded(
                            flex: 3,
                            child: ListView.builder(
                              keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,

                              itemCount: notes.length,

                              itemBuilder: (context, index) {
                                final item = notes[index];

                                return Dismissible(
                                  key: Key(
                                    "${item["date"]}_$index",
                                  ),

                                  direction:
                                  DismissDirection.endToStart,

                                  background: Container(
                                    margin:
                                    const EdgeInsets.only(
                                      bottom: 10,
                                    ),

                                    alignment:
                                    Alignment.centerRight,

                                    padding:
                                    const EdgeInsets.only(
                                      right: 28,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                      BorderRadius.circular(
                                        18,
                                      ),
                                    ),

                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),

                                  confirmDismiss: (_) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (_) =>
                                          AlertDialog(
                                            title:
                                            const Text(
                                              "Delete Note?",
                                            ),

                                            content:
                                            const Text(
                                              "This note will be deleted permanently.",
                                            ),

                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child:
                                                const Text(
                                                  "Cancel",
                                                ),
                                              ),

                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child:
                                                const Text(
                                                  "Delete",
                                                ),
                                              ),
                                            ],
                                          ),
                                    );
                                  },

                                  onDismissed: (_) {
                                    deleteNote(index);

                                    ScaffoldMessenger.of(
                                        context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content:
                                        Text(
                                          "Note deleted",
                                        ),
                                      ),
                                    );
                                  },

                                  child: Card(
                                    color: Colors.white
                                        .withValues(alpha: .06),

                                    child: ListTile(
                                      leading:
                                      const Icon(
                                        Icons.note_alt,
                                      ),

                                      title: Text(
                                        item["text"],
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow
                                            .ellipsis,
                                      ),

                                      subtitle: Text(
                                        item["date"]
                                            .substring(
                                          0,
                                          10,
                                        ),
                                      ),

                                      onTap: () {
                                        openNote(index);

                                        FocusScope.of(
                                            context)
                                            .unfocus();
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}