import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdventurerSheetRedirectItem extends StatelessWidget {
  final String name;
  final String description;
  final String route;

  const AdventurerSheetRedirectItem({
    super.key,
    required this.name,
    required this.description,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            context.push(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: '$name ', 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: description, 
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}