// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stitch Notes';

  @override
  String get notes => 'Notes';

  @override
  String get folders => 'Folders';

  @override
  String get graph => 'Graph';

  @override
  String get settings => 'Settings';

  @override
  String get myNotes => 'My Notes';

  @override
  String get searchNotes => 'Search notes...';

  @override
  String get searchFolders => 'Search folders...';

  @override
  String get searchInNote => 'Search in note...';

  @override
  String get noResults => 'No results found';

  @override
  String noResultsFor(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get tapToCreate => 'Tap + button to create your first note';

  @override
  String get noFoldersYet => 'No folders yet';

  @override
  String get tapToCreateFolder => 'Tap + button to create your first folder';

  @override
  String get untitledNote => 'Untitled note';

  @override
  String get untitledFolder => 'Untitled folder';

  @override
  String get title => 'Title';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get searchInNoteTooltip => 'Search in Note';

  @override
  String get closeSearch => 'Close Search';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get moveToFolder => 'Move to Folder';

  @override
  String get removeFromFolder => 'Remove from Folder';

  @override
  String get selectFolder => 'Select Folder';

  @override
  String get inFolder => 'In folder';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String deleteNoteConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?\n\nThe note will be moved to trash.';
  }

  @override
  String get deleteNoteConfirmUntitled =>
      'Are you sure you want to delete this note?\n\nThe note will be moved to trash.';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get useDarkTheme => 'Use dark theme';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change app language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Turkish';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get trash => 'Trash';

  @override
  String get viewDeletedNotes => 'View deleted notes';

  @override
  String get other => 'Other';

  @override
  String get about => 'About';

  @override
  String get appInfo => 'App information';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String versionWithBuild(String version, String buildNumber) {
    return 'Version $version ($buildNumber)';
  }

  @override
  String get loadingVersion => 'Loading version...';

  @override
  String get richTextNotesApp => 'Rich text notes application';

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String get deletedNotesAppear => 'Deleted notes will appear here';

  @override
  String get emptyTrash => 'Empty Trash';

  @override
  String get emptyTrashConfirm =>
      'Are you sure you want to permanently delete all notes in the trash?\n\nThis action cannot be undone.';

  @override
  String get restore => 'Restore';

  @override
  String get noteRestored => 'Note restored';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String deletePermanentlyConfirm(String title) {
    return 'Are you sure you want to permanently delete \"$title\"?\n\nThis action cannot be undone.';
  }

  @override
  String get deletePermanentlyConfirmUntitled =>
      'Are you sure you want to permanently delete this note?\n\nThis action cannot be undone.';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get deletedJustNow => 'Deleted just now';

  @override
  String deletedMinutesAgo(int minutes) {
    return 'Deleted $minutes minutes ago';
  }

  @override
  String deletedHoursAgo(int hours) {
    return 'Deleted $hours hours ago';
  }

  @override
  String deletedDaysAgo(int days) {
    return 'Deleted $days days ago';
  }

  @override
  String deletedOnDate(String date) {
    return 'Deleted on $date';
  }

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get listView => 'List View';

  @override
  String get gridView => 'Grid View';

  @override
  String get graphView => 'Graph View';

  @override
  String get reset => 'Reset';

  @override
  String get addNoteToUseGraph => 'Add notes to use graph view';

  @override
  String get emptyNote => 'Empty note';

  @override
  String get newFolder => 'New Folder';

  @override
  String get editFolder => 'Edit Folder';

  @override
  String get folderName => 'Folder Name';

  @override
  String get enterFolderName => 'Enter folder name';

  @override
  String get pleaseEnterFolderName => 'Please enter folder name';

  @override
  String get selectColor => 'Select Color';

  @override
  String get deleteFolder => 'Delete Folder';

  @override
  String deleteFolderConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?\n\nNotes in the folder will not be deleted, only the folder will be removed.';
  }

  @override
  String get deleteFolderConfirmUntitled =>
      'Are you sure you want to delete this folder?\n\nNotes in the folder will not be deleted, only the folder will be removed.';

  @override
  String noteCount(int count) {
    return '$count notes';
  }

  @override
  String get noNotesInFolder => 'No notes in this folder';

  @override
  String get longPressToAdd =>
      'Long press on a note card to add notes to this folder';

  @override
  String get noFoldersYetCreateInSettings => 'No folders yet';

  @override
  String get createFolderInSettings =>
      'You can create folders from the settings tab';

  @override
  String imageError(String error) {
    return 'Error adding image: $error';
  }
}
