import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';
import '../widgets/suit_icon.dart';
import 'add_edit_card_screen.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;
  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen>
    with SingleTickerProviderStateMixin {
  final CardRepository _cardRepo = CardRepository();
  List<PlayingCard> _cards = [];
  bool _isLoading = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      final cards = await _cardRepo.getCardsByFolderId(widget.folder.id!);
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
      _animController.forward(from: 0);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cards: $e')),
        );
      }
    }
  }

  Future<void> _addCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCardScreen(folder: widget.folder),
      ),
    );
    if (result == true) _loadCards();
  }

  Future<void> _editCard(PlayingCard card) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCardScreen(folder: widget.folder, card: card),
      ),
    );
    if (result == true) _loadCards();
  }

  Future<void> _confirmDeleteCard(PlayingCard card) async {
    final cs = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: cs.error, size: 28),
        title: const Text('Delete Card?'),
        content: Text(
          'Permanently delete ${card.cardName} of ${card.suit}?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _cardRepo.deleteCard(card.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('${card.cardName} of ${card.suit} deleted'),
                ],
              ),
            ),
          );
        }
        _loadCards();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final suit = suitFromString(widget.folder.folderName);
    final sColor = suitColor(widget.folder.folderName);
    final isRed = isSuitRed(widget.folder.folderName);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ---------- APP BAR ----------
          SliverAppBar.medium(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SuitIcon(suit: suit, size: 22),
                const SizedBox(width: 10),
                Text(widget.folder.folderName),
              ],
            ),
          ),

          // ---------- CARDS COUNT ----------
          if (!_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  '${_cards.length} card${_cards.length != 1 ? 's' : ''}',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ),

          // ---------- BODY ----------
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_cards.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SuitIcon(
                      suit: suit,
                      size: 64,
                      colorOverride: cs.outline.withOpacity(0.3),
                    ),
                    const SizedBox(height: 20),
                    Text('No cards yet', style: tt.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + to add a card',
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final card = _cards[index];
                    final delay = (index * 0.06).clamp(0.0, 0.6);
                    final animation = CurvedAnimation(
                      parent: _animController,
                      curve: Interval(
                        delay,
                        (delay + 0.35).clamp(0, 1),
                        curve: Curves.easeOutCubic,
                      ),
                    );

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.12),
                          end: Offset.zero,
                        ).animate(animation),
                        child: _PlayingCardTile(
                          card: card,
                          suitColor: sColor,
                          isRed: isRed,
                          onEdit: () => _editCard(card),
                          onDelete: () => _confirmDeleteCard(card),
                        ),
                      ),
                    );
                  },
                  childCount: _cards.length,
                ),
              ),
            ),
        ],
      ),

      // ---------- FAB ----------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCard,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Card'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  PLAYING CARD TILE
// ─────────────────────────────────────────────────────────────────

class _PlayingCardTile extends StatelessWidget {
  final PlayingCard card;
  final Color suitColor;
  final bool isRed;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlayingCardTile({
    required this.card,
    required this.suitColor,
    required this.isRed,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = suitSymbol(card.suit);
    final suit = suitFromString(card.suit);

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // ---- Card image area ----
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    // Corner suit indicator (top-left, like a real card)
                    Positioned(
                      top: 6,
                      left: 8,
                      child: Column(
                        children: [
                          Text(
                            _shortName(card.cardName),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: suitColor,
                              height: 1,
                            ),
                          ),
                          SuitIcon(suit: suit, size: 12),
                        ],
                      ),
                    ),

                    // Card image
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.network(
                          card.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.primary.withOpacity(0.3),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SuitIcon(suit: suit, size: 36),
                                const SizedBox(height: 4),
                                Text(
                                  card.cardName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: suitColor,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // Bottom-right corner (upside-down on real cards)
                    Positioned(
                      bottom: 6,
                      right: 8,
                      child: Transform.rotate(
                        angle: 3.14159,
                        child: Column(
                          children: [
                            Text(
                              _shortName(card.cardName),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: suitColor,
                                height: 1,
                              ),
                            ),
                            SuitIcon(suit: suit, size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- Bottom info bar ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${card.cardName} $symbol',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: suitColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Popup menu for edit / delete
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.red.shade400),
                              const SizedBox(width: 8),
                              Text('Delete',
                                  style:
                                      TextStyle(color: Colors.red.shade400)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Abbreviate card name like real cards: A, 2-10, J, Q, K
  String _shortName(String name) {
    switch (name.toLowerCase()) {
      case 'ace':
        return 'A';
      case 'jack':
        return 'J';
      case 'queen':
        return 'Q';
      case 'king':
        return 'K';
      default:
        return name;
    }
  }
}
