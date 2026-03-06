import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import '../widgets/suit_icon.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen>
    with SingleTickerProviderStateMixin {
  final FolderRepository _folderRepo = FolderRepository();
  List<Folder> _folders = [];
  Map<int, int> _cardCounts = {};
  bool _isLoading = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadFolders();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadFolders() async {
    setState(() => _isLoading = true);
    try {
      final folders = await _folderRepo.getAllFolders();
      final Map<int, int> counts = {};
      for (var folder in folders) {
        counts[folder.id!] = await _folderRepo.getCardCount(folder.id!);
      }
      setState(() {
        _folders = folders;
        _cardCounts = counts;
        _isLoading = false;
      });
      _animController.forward(from: 0);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading folders: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteFolder(Folder folder) async {
    final cardCount = _cardCounts[folder.id] ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: colorScheme.error, size: 32),
        title: const Text('Delete Folder?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will permanently delete the ${folder.folderName} folder and all $cardCount cards inside it.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cascade deletion: all related cards will be removed.',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _folderRepo.deleteFolder(folder.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('${folder.folderName} and $cardCount cards deleted'),
                ],
              ),
            ),
          );
        }
        _loadFolders();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting folder: $e')),
          );
        }
      }
    }
  }

  /// Tonal background color per suit for M3 containers
  Color _suitContainerColor(String name) {
    final cs = Theme.of(context).colorScheme;
    switch (name.toLowerCase()) {
      case 'hearts':
        return const Color(0xFFFCE4EC);
      case 'diamonds':
        return const Color(0xFFFFF3E0);
      case 'clubs':
        return const Color(0xFFE8EAF6);
      case 'spades':
        return const Color(0xFFECEFF1);
      default:
        return cs.surfaceContainerLow;
    }
  }

  Color _suitOnContainerColor(String name) {
    switch (name.toLowerCase()) {
      case 'hearts':
        return const Color(0xFFB71C1C);
      case 'diamonds':
        return const Color(0xFFBF360C);
      case 'clubs':
        return const Color(0xFF1A237E);
      case 'spades':
        return const Color(0xFF263238);
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final totalCards =
        _cardCounts.values.fold<int>(0, (sum, c) => sum + c);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ---------- COLLAPSING APP BAR ----------
          SliverAppBar.large(
            title: const Text('Card Organizer'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                onPressed: _loadFolders,
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ---------- STATS CHIP ----------
          if (!_isLoading && _folders.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.folder_rounded,
                      label: '${_folders.length} Suits',
                      color: cs.primary,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.style_rounded,
                      label: '$totalCards Cards',
                      color: cs.tertiary,
                    ),
                  ],
                ),
              ),
            ),

          // ---------- BODY ----------
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_folders.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_off_rounded,
                        size: 64, color: cs.outline),
                    const SizedBox(height: 16),
                    Text('No folders', style: tt.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Reinstall app to repopulate',
                      style:
                          tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final folder = _folders[index];
                    final count = _cardCounts[folder.id] ?? 0;

                    // Staggered fade-in animation
                    final delay = index * 0.15;
                    final animation = CurvedAnimation(
                      parent: _animController,
                      curve: Interval(
                        delay.clamp(0, 0.6),
                        (delay + 0.4).clamp(0, 1),
                        curve: Curves.easeOutCubic,
                      ),
                    );

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: _FolderCard(
                          folder: folder,
                          cardCount: count,
                          containerColor: _suitContainerColor(folder.folderName),
                          onContainerColor:
                              _suitOnContainerColor(folder.folderName),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CardsScreen(folder: folder),
                              ),
                            );
                            _loadFolders();
                          },
                          onDelete: () => _confirmDeleteFolder(folder),
                        ),
                      ),
                    );
                  },
                  childCount: _folders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  STAT CHIP
// ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  FOLDER CARD
// ─────────────────────────────────────────────────────────────────

class _FolderCard extends StatelessWidget {
  final Folder folder;
  final int cardCount;
  final Color containerColor;
  final Color onContainerColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FolderCard({
    required this.folder,
    required this.cardCount,
    required this.containerColor,
    required this.onContainerColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final suit = suitFromString(folder.folderName);

    return Material(
      color: containerColor,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: onContainerColor.withOpacity(0.08),
        child: Stack(
          children: [
            // Large faded suit watermark in background
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.06,
                child: SuitIcon(
                  suit: suit,
                  size: 140,
                  colorOverride: onContainerColor,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Suit icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: SuitIcon(suit: suit, size: 30),
                  ),
                  const Spacer(),

                  // Folder name
                  Text(
                    folder.folderName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: onContainerColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Card count & delete row
                  Row(
                    children: [
                      Text(
                        '$cardCount cards',
                        style: TextStyle(
                          fontSize: 14,
                          color: onContainerColor.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: onContainerColor.withOpacity(0.4),
                          ),
                          padding: EdgeInsets.zero,
                          tooltip: 'Delete folder',
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
}
