import 'package:equatable/equatable.dart';

/// Klasör modeli
///
/// Her klasör benzersiz bir ID'ye sahiptir ve notları gruplamak için kullanılır.
class Folder extends Equatable {
  final String id;
  final String name;
  final int color; // Renk int olarak saklanır (Flutter Color value)
  final DateTime createdAt;
  final DateTime updatedAt;

  const Folder({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Boş klasör oluştur
  factory Folder.empty(String id) {
    final now = DateTime.now();
    return Folder(
      id: id,
      name: '',
      color: 0xFF6C63FF, // Varsayılan renk (primary)
      createdAt: now,
      updatedAt: now,
    );
  }

  /// JSON'dan Folder oluştur
  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      color: json['color'] as int? ?? 0xFF6C63FF,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Folder'u JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Veritabanı için Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Veritabanından Folder oluştur
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      color: map['color'] as int? ?? 0xFF6C63FF,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Klasör kopyası oluştur (güncellemeler için)
  Folder copyWith({
    String? id,
    String? name,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Klasör boş mu?
  bool get isEmpty => name.isEmpty;

  /// Klasör dolu mu?
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [id, name, color, createdAt, updatedAt];
}
