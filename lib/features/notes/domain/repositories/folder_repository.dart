import '../entities/folder.dart';

/// Klasör repository arayüzü (Domain Layer)
///
/// Data layer'dan bağımsız soyut tanım.
/// CRUD işlemlerini tanımlar.
abstract class FolderRepository {
  /// Tüm klasörleri getir
  Future<List<Folder>> getAllFolders();

  /// ID'ye göre klasör getir
  Future<Folder?> getFolderById(String id);

  /// Yeni klasör ekle
  Future<void> insertFolder(Folder folder);

  /// Klasör güncelle
  Future<void> updateFolder(Folder folder);

  /// Klasör sil (içindeki notların folderId'si null yapılır)
  Future<void> deleteFolder(String id);

  /// Klasör ara
  Future<List<Folder>> searchFolders(String query);

  /// Klasördeki not sayısını getir
  Future<int> getNoteCountInFolder(String folderId);
}
