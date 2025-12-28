Flutter ile production-ready, temiz mimariye sahip, ölçeklenebilir bir Not Alma Mobil Uygulaması geliştirmeni istiyorum.

Bu bir demo değil, gerçek bir uygulama olacak.

🧠 ZORUNLU KURALLAR (ÇOK ÖNEMLİ)

Flutter & Dart için en güncel stabil sürümü hedefle

Kullanacağın HER paket için:

pub.dev üzerinden en güncel stabil sürümü kontrol et

pubspec.yaml dosyasına net sürüm numarasıyla ekle

Eski / deprecated API KESİNLİKLE kullanma

Kod:

Temiz

Modüler

Okunabilir

Genişletilebilir olmalı

“Tek dosyada her şey” yaklaşımı YOK

Gereksiz boilerplate YOK

🏗️ MİMARİ

Katmanlı yapı kullan:

data

domain

presentation

Veritabanı, UI ve iş mantığı kesinlikle ayrılmış olsun

State management:

Güncel, sade ve sürdürülebilir bir çözüm seç

Seçtiğin çözümün neden uygun olduğunu kısaca açıkla

📱 UYGULAMA AMACI

Bu uygulama bir not defteri uygulamasıdır:

Not ekleme

Not listeleme

Not düzenleme

Not silme

Farklı görsel sunumlarla notları inceleme

🗄️ VERİTABANI

Yerel veritabanı olarak sqflite kullan

Aşağıdaki alanlara sahip bir Note modeli oluştur:

id

title

content (rich text / json destekli)

createdAt

updatedAt

images (liste)

CRUD işlemlerinin tamamı çalışır olsun

DB işlemleri async, güvenli ve hataya dayanıklı yazılsın

🧭 NAVİGASYON

Sayfalar arası geçişlerde CupertinoPageRoute veya Cupertino animasyonları kullan

iOS hissi veren yumuşak geçişler olsun

Android’de de sorun çıkarmayacak şekilde yapılandır

📌 BOTTOM BAR

Alt navigasyon için google_nav_bar kullan.

Bottom bar 3 sayfadan oluşacak:

1️⃣ NOTES (Ana Sayfa)

Tüm notlar liste halinde gösterilecek

Boş durum (empty state) tasarla

FloatingActionButton ile yeni not eklenebilecek

Nota tıklanınca Not Düzenleme Ekranı açılacak

2️⃣ GRAPH SAYFASI

Notlar graph / node / düğüm yapısı şeklinde gösterilecek

Her not bir node olarak temsil edilecek

Şu an için:

Sadece önizleme

Statik veya basit layout olabilir

İleride:

Notlar arası bağlantılar eklenebilecek şekilde esnek mimari kur

3️⃣ SETTINGS SAYFASI

Uygulama geneli ayarlar

Aydınlık / Karanlık tema

Switch ile kontrol edilecek

Tema anında değişsin

Tercih kalıcı olarak saklansın

Tema tüm widget ağacını etkilesin

📝 NOT DÜZENLEME EKRANI

Not düzenleme için appflowy_editor kullan

Zengin metin özellikleri aktif olsun

Başlık + içerik yapısı kur

Not otomatik kaydedilebilsin (debounce vs.)

📸 FOTOĞRAF DESTEĞİ

Notlara fotoğraf eklenebilsin

Fotoğraf almak için image_picker (Google) kullan

Depolama izni istemeden çalışacak şekilde yapılandır

Seçilen görseller:

Not içeriğiyle ilişkilendirilsin

Veritabanında referansları saklansın

🎨 UI / UX

Tasarımlar için tamamen proje klasorundeki ornek_tasarim klasörünü örnek alabilirsin. 

Minimal

Modern

iOS hissiyatlı

Dark / Light tema uyumlu

Overflow, keyboard ve küçük ekran problemleri düşünülmüş olsun

📦 ÇIKTI BEKLENTİSİ

Çalışan Flutter proje yapısı

Güncel pubspec.yaml

Mantıklı klasör yapısı

Önemli yerlerde kısa ama net açıklamalar

“Burada şunu yapabilirsin” gibi yarım bırakılmış yerler OLMASIN

❌ YAPILMAMASI GEREKENLER

Eski paket sürümleri

Deprecated API

Yarım çalışan örnekler

UI’siz mantık anlatımı

“Varsayalım ki” yaklaşımı