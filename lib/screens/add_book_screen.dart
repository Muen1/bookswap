import 'package:bookswap/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../services/storage_service.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  final Book? book;

  const AddBookScreen({super.key, this.book});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _swapForController = TextEditingController();

  String _condition = 'Like New';
  String _category = 'Textbook';
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _conditions = [
    'Like New',
    'Very Good',
    'Good',
    'Fair',
    'Poor'
  ];

  final List<String> _categories = [
    'Textbook',
    'Fiction',
    'Non-Fiction',
    'Academic',
    'Children',
    'Other'
  ];
  

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _isbnController.text = widget.book!.isbn;
      _descriptionController.text = widget.book!.description ?? '';
      _swapForController.text = widget.book!.swapFor ?? '';
      _condition = widget.book!.condition;
      _category = widget.book!.category;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    final storageService = ref.read(storageServiceProvider);
    return await storageService.uploadBookImage(_imageFile!);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final authState = ref.read(authStateProvider).value;
      
      if (authState == null) {
        throw Exception('User not authenticated');
      }

      final imageUrl = await _uploadImage();

      final book = Book(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        isbn: _isbnController.text.trim(),
        condition: _condition,
        category: _category,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        imageUrl: imageUrl ?? widget.book?.imageUrl,
        ownerId: authState.uid,
        ownerEmail: authState.email!,
        createdAt: widget.book?.createdAt ?? DateTime.now(),
        swapFor: _swapForController.text.trim().isEmpty
            ? null
            : _swapForController.text.trim(),
        isAvailable: true,
      );

      if (widget.book != null) {
        // Update existing book
        await firestoreService.updateBook(book.copyWith(id: widget.book!.id));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully!')),
        );
      } else {
        // Add new book
        await firestoreService.addBook(book);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added successfully!')),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book != null ? 'Edit Book' : 'Add New Book'),
        actions: [
          if (widget.book != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteBook,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : widget.book?.imageUrl != null
                                ? Image.network(
                                    widget.book!.imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt, size: 50),
                                      SizedBox(height: 8),
                                      Text('Tap to add book image'),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Book Title *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter book title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Author
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: 'Author *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter author name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ISBN
                    TextFormField(
                      controller: _isbnController,
                      decoration: const InputDecoration(
                        labelText: 'ISBN',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Condition Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _condition,
                      decoration: const InputDecoration(
                        labelText: 'Condition *',
                        border: OutlineInputBorder(),
                      ),
                      items: _conditions
                          .map((condition) => DropdownMenuItem(
                                value: condition,
                                child: Text(condition),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _condition = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Swap For
                    TextFormField(
                      controller: _swapForController,
                      decoration: const InputDecoration(
                        labelText: 'Looking to swap for...',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Programming books, Fiction novels, etc.',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        widget.book != null ? 'Update Book' : 'Add Book',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _deleteBook() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.deleteBook(widget.book!.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _swapForController.dispose();
    super.dispose();
  }
}