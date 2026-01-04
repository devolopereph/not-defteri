// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Stitch Notes';

  @override
  String get notes => 'Notlar';

  @override
  String get folders => 'Klasörler';

  @override
  String get graph => 'Graf';

  @override
  String get settings => 'Ayarlar';

  @override
  String get myNotes => 'Notlarım';

  @override
  String get searchNotes => 'Not ara...';

  @override
  String get searchFolders => 'Klasör ara...';

  @override
  String get searchInNote => 'Not içinde ara...';

  @override
  String get noResults => 'Sonuç bulunamadı';

  @override
  String noResultsFor(String query) {
    return '\"$query\" için sonuç bulunamadı';
  }

  @override
  String get noNotesYet => 'Henüz not yok';

  @override
  String get tapToCreate => 'İlk notunuzu oluşturmak için + butonuna tıklayın';

  @override
  String get noFoldersYet => 'Henüz klasör yok';

  @override
  String get tapToCreateFolder =>
      'İlk klasörünüzü oluşturmak için + butonuna tıklayın';

  @override
  String get untitledNote => 'Başlıksız not';

  @override
  String get untitledFolder => 'İsimsiz klasör';

  @override
  String get title => 'Başlık';

  @override
  String get done => 'Bitti';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get addPhoto => 'Fotoğraf Ekle';

  @override
  String get searchInNoteTooltip => 'Not İçinde Ara';

  @override
  String get closeSearch => 'Aramayı Kapat';

  @override
  String get pin => 'Sabitle';

  @override
  String get unpin => 'Sabitlemeyi Kaldır';

  @override
  String get moveToFolder => 'Klasöre Taşı';

  @override
  String get removeFromFolder => 'Klasörden Çıkar';

  @override
  String get selectFolder => 'Klasör Seçin';

  @override
  String get inFolder => 'Klasörde';

  @override
  String get deleteNote => 'Notu Sil';

  @override
  String deleteNoteConfirm(String title) {
    return '\"$title\" notunu silmek istediğinize emin misiniz?\n\nNot çöp kutusuna taşınacak.';
  }

  @override
  String get deleteNoteConfirmUntitled =>
      'Bu notu silmek istediğinize emin misiniz?\n\nNot çöp kutusuna taşınacak.';

  @override
  String get appearance => 'Görünüm';

  @override
  String get darkTheme => 'Karanlık Tema';

  @override
  String get useDarkTheme => 'Karanlık tema kullan';

  @override
  String get language => 'Dil';

  @override
  String get changeLanguage => 'Uygulama dilini değiştir';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get english => 'İngilizce';

  @override
  String get turkish => 'Türkçe';

  @override
  String get dataManagement => 'Veri Yönetimi';

  @override
  String get trash => 'Çöp Kutusu';

  @override
  String get viewDeletedNotes => 'Silinen notları görüntüle';

  @override
  String get other => 'Diğer';

  @override
  String get about => 'Hakkında';

  @override
  String get appInfo => 'Uygulama bilgileri';

  @override
  String version(String version) {
    return 'Sürüm $version';
  }

  @override
  String versionWithBuild(String version, String buildNumber) {
    return 'Sürüm $version ($buildNumber)';
  }

  @override
  String get loadingVersion => 'Sürüm yükleniyor...';

  @override
  String get richTextNotesApp => 'Zengin metin destekli not uygulaması';

  @override
  String get trashEmpty => 'Çöp kutusu boş';

  @override
  String get deletedNotesAppear => 'Silinen notlar burada görünecek';

  @override
  String get emptyTrash => 'Çöp Kutusunu Boşalt';

  @override
  String get emptyTrashConfirm =>
      'Çöp kutusundaki tüm notları kalıcı olarak silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.';

  @override
  String get restore => 'Geri Getir';

  @override
  String get noteRestored => 'Not geri getirildi';

  @override
  String get deletePermanently => 'Kalıcı Olarak Sil';

  @override
  String deletePermanentlyConfirm(String title) {
    return '\"$title\" notunu kalıcı olarak silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.';
  }

  @override
  String get deletePermanentlyConfirmUntitled =>
      'Bu notu kalıcı olarak silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.';

  @override
  String get justNow => 'Az önce';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}d önce';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}sa önce';
  }

  @override
  String daysAgo(int days) {
    return '$days gün önce';
  }

  @override
  String get deletedJustNow => 'Az önce silindi';

  @override
  String deletedMinutesAgo(int minutes) {
    return '$minutes dakika önce silindi';
  }

  @override
  String deletedHoursAgo(int hours) {
    return '$hours saat önce silindi';
  }

  @override
  String deletedDaysAgo(int days) {
    return '$days gün önce silindi';
  }

  @override
  String deletedOnDate(String date) {
    return '$date tarihinde silindi';
  }

  @override
  String get unknownDate => 'Bilinmeyen tarih';

  @override
  String get errorOccurred => 'Bir hata oluştu';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get listView => 'Liste Görünümü';

  @override
  String get gridView => 'Izgara Görünümü';

  @override
  String get graphView => 'Graf Görünümü';

  @override
  String get reset => 'Sıfırla';

  @override
  String get addNoteToUseGraph => 'Not ekleyerek graf görünümünü kullanın';

  @override
  String get emptyNote => 'Boş not';

  @override
  String get newFolder => 'Yeni Klasör';

  @override
  String get editFolder => 'Klasörü Düzenle';

  @override
  String get folderName => 'Klasör Adı';

  @override
  String get enterFolderName => 'Klasör adını girin';

  @override
  String get pleaseEnterFolderName => 'Lütfen klasör adı girin';

  @override
  String get selectColor => 'Renk Seçin';

  @override
  String get deleteFolder => 'Klasörü Sil';

  @override
  String deleteFolderConfirm(String name) {
    return '\"$name\" klasörünü silmek istediğinize emin misiniz?\n\nKlasördeki notlar silinmeyecek, sadece klasör kaldırılacak.';
  }

  @override
  String get deleteFolderConfirmUntitled =>
      'Bu klasörü silmek istediğinize emin misiniz?\n\nKlasördeki notlar silinmeyecek, sadece klasör kaldırılacak.';

  @override
  String noteCount(int count) {
    return '$count not';
  }

  @override
  String get noNotesInFolder => 'Bu klasörde not yok';

  @override
  String get longPressToAdd =>
      'Notları bu klasöre eklemek için not kartına uzun basın';

  @override
  String get noFoldersYetCreateInSettings => 'Henüz klasör yok';

  @override
  String get createFolderInSettings =>
      'Ayarlar sekmesinden klasör oluşturabilirsiniz';

  @override
  String imageError(String error) {
    return 'Görsel eklenirken hata oluştu: $error';
  }
}
