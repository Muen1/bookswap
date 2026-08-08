import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../providers/auth_provider.dart';
import 'make_offer_screen.dart';

class BookDetailScreen extends ConsumerWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book Image
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: book.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(book.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: AssetImage('assets/images/book_placeholder.png'),
                        fit: BoxFit.cover,
                      ),
              ),
              child: book.imageUrl == null
                  ? const Center(
                      child: Icon(Icons.book, size: 100, color: Colors.grey),
                    )
                  : null,
            ),

            // Book Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${book.author}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Condition and Category
                  Row(
                    children: [
                      _buildDetailChip(
                        'Condition',
                        book.condition,
                        _getConditionColor(book.condition),
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        'Category',
                        book.category,
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ISBN if available
                  if (book.isbn.isNotEmpty) ...[
                    _buildDetailRow('ISBN', book.isbn),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (book.description != null && book.description!.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.description!,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Swap Preference
                  if (book.swapFor != null && book.swapFor!.isNotEmpty) ...[
                    const Text(
                      'Looking to swap for:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.swapFor!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Owner Info
                  const Divider(),
                  const Text(
                    'Listed by:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.ownerEmail,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Listed on ${_formatDate(book.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: currentUser?.uid != book.ownerId
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MakeOfferScreen(book: book),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Make Swap Offer'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDetailChip(String label, String value, Color color) {
    return Chip(
      // ignore: deprecated_member_use
      backgroundColor: color.withOpacity(0.2),
      label: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Like New':
        return Colors.green;
      case 'Very Good':
        return Colors.lightGreen;
      case 'Good':
        return Colors.orange;
      case 'Fair':
        return Colors.orangeAccent;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
