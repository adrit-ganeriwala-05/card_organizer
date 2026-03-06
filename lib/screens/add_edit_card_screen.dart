import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';
import '../repositories/folder_repository.dart';
import '../widgets/suit_icon.dart';

class AddEditCardScreen extends StatefulWidget {
  final Folder folder;
  final PlayingCard? card;

  const AddEditCardScreen({
    super.key,
    required this.folder,
    this.card,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final CardRepository _cardRepo = CardRepository();
  final FolderRepository _folderRepo = FolderRepository();

  late TextEditingController _cardNameController;
  late TextEditingController _imageUrlController;
  String _selectedSuit = 'Hearts';
  int? _selectedFolderId;
  List<Folder> _allFolders = [];
  bool _isSaving = false;
  bool _showPreview = false;

  bool get isEditing => widget.card != null;

  final List<String> _suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];

  @override
  void initState() {
    super.initState();
    _cardNameController =
        TextEditingController(text: widget.card?.cardName ?? '');
    _imageUrlController =
        TextEditingController(text: widget.card?.imageUrl ?? '');
    _selectedSuit = widget.card?.suit ?? widget.folder.folderName;
    _selectedFolderId = widget.card?.folderId ?? widget.folder.id;
    _showPreview = widget.card != null && widget.card!.imageUrl.isNotEmpty;
    _loadFolders();

    // Listen for URL changes to toggle preview
    _imageUrlController.addListener(() {
      final hasUrl = _imageUrlController.text.trim().isNotEmpty;
      if (hasUrl != _showPreview) {
        setState(() => _showPreview = hasUrl);
      }
    });
  }

  Future<void> _loadFolders() async {
    final folders = await _folderRepo.getAllFolders();
    setState(() => _allFolders = folders);
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final cardName = _cardNameController.text.trim();
      final imageUrl = _imageUrlController.text.trim();

      if (isEditing) {
        final updated = widget.card!.copyWith(
          cardName: cardName,
          suit: _selectedSuit,
          imageUrl: imageUrl,
          folderId: _selectedFolderId,
        );
        await _cardRepo.updateCard(updated);
      } else {
        final newCard = PlayingCard(
          cardName: cardName,
          suit: _selectedSuit,
          imageUrl: imageUrl,
          folderId: _selectedFolderId!,
        );
        await _cardRepo.insertCard(newCard);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(isEditing ? 'Card updated' : 'Card added'),
              ],
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving card: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isEditing ? 'Edit Card' : 'New Card'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveCard,
              icon: _isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(isEditing ? 'Update' : 'Save'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------- IMAGE PREVIEW ----------
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: _showPreview ? 200 : 0,
              width: double.infinity,
              color: cs.surfaceContainerHighest.withOpacity(0.3),
              child: _showPreview
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.network(
                          _imageUrlController.text,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_rounded,
                                  size: 48, color: cs.outline),
                              const SizedBox(height: 8),
                              Text(
                                'Could not load image',
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.primary.withOpacity(0.5),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // ---------- FORM ----------
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section label
                    Text(
                      'Card Details',
                      style: tt.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card Name
                    TextFormField(
                      controller: _cardNameController,
                      decoration: const InputDecoration(
                        labelText: 'Card Name',
                        hintText: 'Ace, King, Queen, 2...',
                        prefixIcon:
                            Icon(Icons.text_fields_rounded),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter a card name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Suit dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedSuit,
                      decoration: const InputDecoration(
                        labelText: 'Suit',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      items: _suits.map((s) {
                        final suit = suitFromString(s);
                        return DropdownMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              SuitIcon(suit: suit, size: 18),
                              const SizedBox(width: 12),
                              Text(s),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedSuit = v!),
                    ),
                    const SizedBox(height: 16),

                    // Image URL
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        hintText: 'https://deckofcardsapi.com/...',
                        prefixIcon:
                            const Icon(Icons.image_rounded),
                        suffixIcon: _imageUrlController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _imageUrlController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.url,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter an image URL'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Folder assignment
                    DropdownButtonFormField<int>(
                      value: _selectedFolderId,
                      decoration: const InputDecoration(
                        labelText: 'Assign to Folder',
                        prefixIcon: Icon(Icons.folder_rounded),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      items: _allFolders.map((f) {
                        final suit = suitFromString(f.folderName);
                        return DropdownMenuItem(
                          value: f.id,
                          child: Row(
                            children: [
                              SuitIcon(suit: suit, size: 18),
                              const SizedBox(width: 12),
                              Text(f.folderName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => _selectedFolderId = v),
                      validator: (v) =>
                          v == null ? 'Select a folder' : null,
                    ),

                    const SizedBox(height: 32),

                    // Tip card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded,
                              size: 20, color: cs.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Use deckofcardsapi.com URLs for card images.\n'
                              'Pattern: /static/img/{VALUE}{SUIT}.png\n'
                              'Example: AS.png = Ace of Spades',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
