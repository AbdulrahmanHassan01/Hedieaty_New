import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gift_list_page.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift? gift; // If null, we're creating a new gift
  final String eventName;

  const GiftDetailsPage({
    super.key,
    this.gift,
    required this.eventName,
  });

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  String _selectedCategory = 'Electronics'; // Default category
  String? _imageUrl;

  final List<String> _categories = [
    'Electronics',
    'Books',
    'Clothing',
    'Kitchen',
    'Home',
    'Sports',
    'Toys',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing gift data if editing
    _nameController = TextEditingController(text: widget.gift?.name);
    _descriptionController = TextEditingController(text: widget.gift?.description);
    _priceController = TextEditingController(
      text: widget.gift?.price.toStringAsFixed(2),
    );

    if (widget.gift != null) {
      _selectedCategory = widget.gift!.category;
      _imageUrl = widget.gift?.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.gift != null;
    final isPledged = isEditing && widget.gift!.status == GiftStatus.pledged;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Gift' : 'New Gift'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isPledged)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This gift has been pledged and cannot be modified.',
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),

            // Image Section
            GestureDetector(
              onTap: isPledged ? null : () {
                // TODO: Implement image picking
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _imageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(_imageUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: _imageUrl == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Photo',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Gift Name',
                prefixIcon: Icon(Icons.card_giftcard),
              ),
              enabled: !isPledged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              enabled: !isPledged,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: isPledged ? null : (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price Field
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixIcon: Icon(Icons.attach_money),
              ),
              enabled: !isPledged,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Save Button
            if (!isPledged)
              ElevatedButton(
                onPressed: _saveGift,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(isEditing ? 'Update Gift' : 'Add Gift'),
              ),
          ],
        ),
      ),
    );
  }

  void _saveGift() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save gift data
      // For now, just pop back
      Navigator.pop(context);
    }
  }
}