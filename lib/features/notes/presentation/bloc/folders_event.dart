part of 'folders_bloc.dart';

/// Klasör eventleri
abstract class FoldersEvent extends Equatable {
  const FoldersEvent();

  @override
  List<Object?> get props => [];
}

/// Klasörleri yükle
class LoadFolders extends FoldersEvent {
  const LoadFolders();
}

/// Yeni klasör ekle
class AddFolder extends FoldersEvent {
  final String name;
  final int color;

  const AddFolder(this.name, this.color);

  @override
  List<Object?> get props => [name, color];
}

/// Klasör güncelle
class UpdateFolder extends FoldersEvent {
  final Folder folder;

  const UpdateFolder(this.folder);

  @override
  List<Object?> get props => [folder];
}

/// Klasör sil
class DeleteFolder extends FoldersEvent {
  final String id;

  const DeleteFolder(this.id);

  @override
  List<Object?> get props => [id];
}

/// Klasörlerde ara
class SearchFolders extends FoldersEvent {
  final String query;

  const SearchFolders(this.query);

  @override
  List<Object?> get props => [query];
}

/// Klasörleri yenile
class RefreshFolders extends FoldersEvent {
  const RefreshFolders();
}
