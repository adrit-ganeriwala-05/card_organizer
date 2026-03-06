class Folder {
  final int? id;
  final String folderName;
  final String timestamp;

  Folder({
    this.id,
    required this.folderName,
    required this.timestamp,
  });

  // Convert a Folder object to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folder_name': folderName,
      'timestamp': timestamp,
    };
  }

  // Create a Folder object from a database Map
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as int?,
      folderName: map['folder_name'] as String,
      timestamp: map['timestamp'] as String,
    );
  }

  // Create a copy of this Folder with optional field overrides
  Folder copyWith({
    int? id,
    String? folderName,
    String? timestamp,
  }) {
    return Folder(
      id: id ?? this.id,
      folderName: folderName ?? this.folderName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'Folder{id: $id, folderName: $folderName, timestamp: $timestamp}';
  }
}
