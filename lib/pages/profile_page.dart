import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bbeez_one/photo_picker.dart';

import '../services/profile_service.dart';
import '../widgets/common_appbar.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {
  final _name =
  TextEditingController();

  final _email =
  TextEditingController();

  final _phone =
  TextEditingController();

  String imagePath = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data =
    await ProfileService.getProfile();

    if (!mounted) return;

    setState(() {
      _name.text =
          data['name'] ?? '';

      _email.text =
          data['email'] ?? '';

      _phone.text =
          data['phone'] ?? '';

      imagePath =
          data['image'] ?? '';
    });
  }

  Future<void> pickImage() async {
    // Use the system file picker (no broad storage permissions required)
    final file = await PhotoPicker.pickImage();
    if (file == null) return;

    setState(() {
      imagePath = file.path;
    });
  }

  Future<void> save() async {
    await ProfileService.saveProfile(
      name:
      _name.text.trim(),
      email:
      _email.text.trim(),
      phone:
      _phone.text.trim(),
      image:
      imagePath,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
        Text(
          'Profile Updated',
        ),
      ),
    );

    Navigator.pop(
      context,
      true,
    );
  }

  Widget field(
      String label,
      TextEditingController c,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 18,
      ),
      child:
      TextField(
        controller:
        c,
        style:
        const TextStyle(
          color:
          Colors.white,
        ),
        decoration:
        InputDecoration(
          labelText:
          label,
          labelStyle:
          const TextStyle(
            color:
            Colors.white70,
          ),
          filled:
          true,
          fillColor:
          Colors.white
              .withValues(alpha: .05),
          contentPadding:
          const EdgeInsets
              .symmetric(
            horizontal:
            20,
            vertical:
            18,
          ),
          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius
                .circular(
                18),
            borderSide:
            BorderSide.none,
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius
                .circular(
                18),
            borderSide:
            BorderSide(
              color:
              Colors.white
                  .withValues(alpha: .08),
            ),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius
                .circular(
                18),
            borderSide:
            const BorderSide(
              color:
              Color(
                0xFF14F1FF,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
      true,

      appBar:
      commonAppBar(
        context,
        'Profile',
      ),

      body:
      Container(
        width:
        double.infinity,

        height:
        double.infinity,

        decoration: AppTheme.pageBackground,

        child:
        SafeArea(
          child:
          SingleChildScrollView(
            physics:
            const BouncingScrollPhysics(),

            padding:
            const EdgeInsets
                .fromLTRB(
              22,
              18,
              22,
              40,
            ),

            child:
            Column(
              children: [

                GestureDetector(
                  onTap:
                  pickImage,

                  child:
                  Stack(
                    children: [

                      CircleAvatar(
                        radius:
                        65,

                        backgroundColor:
                        Colors
                            .white
                            .withValues(alpha: .08),

                        backgroundImage:
                        imagePath
                            .isNotEmpty
                            ? FileImage(
                          File(
                            imagePath,
                          ),
                        )
                            : null,

                        child:
                        imagePath
                            .isEmpty
                            ? const Icon(
                          Icons
                              .person,

                          size:
                          60,

                          color:
                          Colors
                              .white,
                        )
                            : null,
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,

                        child:
                        Container(
                          padding:
                          const EdgeInsets
                              .all(
                              10),

                          decoration:
                          const BoxDecoration(
                            shape:
                            BoxShape
                                .circle,

                            gradient:
                            LinearGradient(
                              colors: [
                                Color(
                                    0xFF14F1FF),
                                Color(
                                    0xFFD93CFF),
                              ],
                            ),
                          ),

                          child:
                          const Icon(
                            Icons.edit,
                            color:
                            Colors
                                .white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height:
                    35),

                field(
                  'Name',
                  _name,
                ),

                field(
                  'Email',
                  _email,
                ),

                field(
                  'Phone',
                  _phone,
                ),

                const SizedBox(
                    height:
                    24),

                SizedBox(
                  width:
                  double.infinity,

                  height:
                  58,

                  child:
                  ElevatedButton(
                    onPressed:
                    save,

                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      const Color(
                        0xFF14F1FF,
                      ),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                            18),
                      ),
                    ),

                    child:
                    const Text(
                      "Save Profile",

                      style:
                      TextStyle(
                        color:
                        Colors
                            .black,

                        fontSize:
                        18,

                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}