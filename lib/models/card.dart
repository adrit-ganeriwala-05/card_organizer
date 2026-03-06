class PlayingCard {
  final int? id;
  final String cardName;
  final String suit;
  final String imageUrl;
  final int folderId;

  PlayingCard({
    this.id,
    required this.cardName,
    required this.suit,
    required this.imageUrl,
    required this.folderId,
  });

  // Convert a PlayingCard object to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_name': cardName,
      'suit': suit,
      'image_url': imageUrl,
      'folder_id': folderId,
    };
  }

  // Create a PlayingCard object from a database Map
  factory PlayingCard.fromMap(Map<String, dynamic> map) {
    return PlayingCard(
      id: map['id'] as int?,
      cardName: map['card_name'] as String,
      suit: map['suit'] as String,
      imageUrl: map['image_url'] as String,
      folderId: map['folder_id'] as int,
    );
  }

  // Create a copy of this PlayingCard with optional field overrides
  PlayingCard copyWith({
    int? id,
    String? cardName,
    String? suit,
    String? imageUrl,
    int? folderId,
  }) {
    return PlayingCard(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      suit: suit ?? this.suit,
      imageUrl: imageUrl ?? this.imageUrl,
      folderId: folderId ?? this.folderId,
    );
  }

  @override
  String toString() {
    return 'PlayingCard{id: $id, cardName: $cardName, suit: $suit, folderId: $folderId}';
  }
}
