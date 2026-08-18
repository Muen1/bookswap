import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  String _selectedCategory = 'All';
  String _selectedCondition = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Textbook',
    'Fiction',
    'Non-Fiction',
    'Academic',
    'Children',
    'Other'
  ];

  final List<String> _conditions = [
    'All',
    'Like New',
    'Very Good',
    'Good',
    'Fair',
    'Poor'
  ];

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddBookScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Category Filter
                _buildFilterDropdown(
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                  hint: 'Category',
                ),
                const SizedBox(width: 8),

                // Condition Filter
                _buildFilterDropdown(
                  value: _selectedCondition,
                  items: _conditions,
                  onChanged: (value) => setState(() => _selectedCondition = value!),
                  hint: 'Condition',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Books List
          Expanded(
            child: booksAsync.when(
              data: (books) {
                if (books.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No books available yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Be the first to add a book!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Filter books
                List<Book> filteredBooks = books.where((book) {
                  // Filter out current user's books
                  if (book.ownerId == currentUser?.uid) return false;

                  // Filter by search
                  if (_searchController.text.isNotEmpty) {
                    final searchLower = _searchController.text.toLowerCase();
                    if (!book.title.toLowerCase().contains(searchLower) &&
                        !book.author.toLowerCase().contains(searchLower) &&
                        !book.category.toLowerCase().contains(searchLower)) {
                      return false;
                    }
                  }

                  // Filter by category
                  if (_selectedCategory != 'All' && book.category != _selectedCategory) {
                    return false;
                  }

                  // Filter by condition
                  if (_selectedCondition != 'All' && book.condition != _selectedCondition) {
                    return false;
                  }

                  // Only show available books
                  return book.isAvailable;
                }).toList();

                if (filteredBooks.isEmpty) {
                  return const Center(
                    child: Text('No books match your filters'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return _BookCard(book: book);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(booksProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: book),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book Image
            Expanded(
              child: book.imageUrl != null
              ? Image.network(
          book.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                'Image error:\n$error',
                style: const TextStyle(fontSize: 10, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        )
      : Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/book_placeholder.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: Icon(Icons.book, size: 40, color: Colors.grey),
          ),
        ),
),

            // Book Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getConditionColor(book.condition),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.condition,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        book.category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
}
