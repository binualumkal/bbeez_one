import 'package:flutter/material.dart';

class SwipeCard extends StatelessWidget {

  final String title;

  final VoidCallback onTap;

  final VoidCallback onDelete;

  const SwipeCard({
    super.key,
    required this.title,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      child: Dismissible(

        key: Key(title),

        direction: DismissDirection.endToStart,

        background: Container(

          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(18),
          ),

          alignment: Alignment.centerRight,

          padding: const EdgeInsets.only(right: 24),

          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 28,
          ),
        ),

        confirmDismiss: (direction) async {

          return await showDialog(

            context: context,

            builder: (context) {

              return AlertDialog(

                backgroundColor: const Color(0xFF1E1E1E),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                title: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),

                content: Text(
                  "Are you sure you want to delete \"$title\" ?",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                actions: [

                  TextButton(

                    onPressed: () {
                      Navigator.pop(context, false);
                    },

                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  TextButton(

                    onPressed: () {
                      Navigator.pop(context, true);
                    },

                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },

        onDismissed: (direction) {
          onDelete();
        },

        child: Material(

          color: const Color(0xFF17141F),

          borderRadius: BorderRadius.circular(18),

          child: InkWell(

            borderRadius: BorderRadius.circular(18),

            onTap: onTap,

            child: Container(

              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 20,
              ),

              child: Row(

                children: [

                  Expanded(

                    child: Text(

                      title,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}