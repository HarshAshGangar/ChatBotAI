import 'package:flutter/material.dart';
import 'package:seventhapp/Models/message.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final bool isOutgoing;

  const MessageTile({
    super.key,
    required this.message,
    required this.isOutgoing,
  });

  @override
  Widget build(BuildContext context) {
    // Clean up unwanted characters
    final cleanedMessage = message.message
        .replaceAll('*', '')
        .replaceAll(',', '')
        .replaceAll("'", '')
        .replaceAll("`", '')
        .replaceAll('"', ''); // Add more characters if needed

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isOutgoing ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cleanedMessage, // Use the cleaned message here
              style: TextStyle(
                color: isOutgoing ? Colors.white : Colors.black,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10),
            message.imageURL != null
                ? Image.network(
              message.imageURL!,
              errorBuilder: (context, error, stackTrace) {
                return const Text('Image failed to load'); // Placeholder text
              },
            )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
