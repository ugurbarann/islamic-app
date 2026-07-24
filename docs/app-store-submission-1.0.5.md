# İslami Cep 1.0.5 — App Store gönderim kontrolü

## App Store Connect alanları

- Copyright: `2026 Uğur Baran`
- Privacy Policy URL: `https://ugurbarann.github.io/islamic-app/docs/privacy-policy.html`
- Support URL: `https://ugurbarann.github.io/islamic-app/docs/`
- Support email: `admin@ugurbaran.com`
- Sign-in required: Hayır
- Release: Onaydan sonra kontrol isteniyorsa `Manually release this version`
- Build: `1.0.5 (5)`
- Platform: iPhone only
- Export compliance: Uygulama yalnız işletim sistemi/standart HTTPS şifrelemesi kullanır; `ITSAppUsesNonExemptEncryption = NO` pakete eklendi.

## App Privacy beyanı

- Tracking: Evet; yalnız ATT izni verildiğinde cihaz tanımlayıcısı Meta App Events tarafından reklam ölçümü için kullanılabilir
- User account: Yok
- Advertising: Uygulama içinde reklam gösterilmez; Meta App Events reklam etkinliği ölçümü için kullanılır
- Precise Location: Toplanır/kullanılır; kullanıcıyla ilişkilendirilmez; takip için kullanılmaz; amaç `App Functionality`
- Diagnostics > Other Diagnostic Data: Toplanır; kullanıcıyla ilişkilendirilmez; takip için kullanılmaz; amaç `Analytics` (Firestore SDK kullanıcı aracısı/tanılama metadatası)
- Identifiers > Device ID: Toplanabilir; kullanıcıyla ilişkilendirilebilir; takip için kullanılabilir; amaçlar `Third-Party Advertising`, `Analytics` ve `App Functionality` (Meta SDK gizlilik bildirimi)
- Other Data: Toplanabilir; kullanıcıyla ilişkilendirilmez; takip için kullanılmaz; amaç `Analytics` (Meta SDK gizlilik bildirimi)
- Diagnostics > Crash Data: Toplanabilir; kullanıcıyla ilişkilendirilmez; takip için kullanılmaz; amaç `App Functionality` (Meta SDK gizlilik bildirimi)
- Konum kullanım amacı: namaz vakti il/ilçe seçimi, kıble ve yakındaki camiler
- Üçüncü taraflar: Meta App Events, Firebase/Firestore, Google Maps Platform, OpenStreetMap tabanlı servisler ve Ezan Vakti servisi

App Store Connect beyanı, uygulamadaki ve üçüncü taraf SDK’lardaki gerçek veri davranışıyla aynı tutulmalıdır.

## Review Notes önerisi

> İslami Cep kullanıcı hesabı veya giriş gerektirmez. Konum izni yalnız namaz vakitleri için il/ilçe seçmek, kıble yönünü hesaplamak ve yakındaki camileri göstermek amacıyla ilgili özellik açıldığında istenir. Namaz vakti konum eşlemesi Türkiye'deki il ve ilçelerle sınırlıdır; desteklenmeyen bir konumda veya izin verilmediğinde uygulama varsayılan/seçilmiş il ve ilçeyle çalışmaya devam eder. Konum daha sonra uygulamadaki “Ayarlar’dan Konum İzni Ver” düğmesiyle tekrar etkinleştirilebilir. App Tracking Transparency izni ana ekran etkinleştikten sekiz saniye sonra ve yalnız durum henüz belirlenmemişse istenir; reddedilmesi uygulamanın temel işlevlerini etkilemez. Meta App Events otomatik uygulama aktivasyonu ve kurulum ölçümü için kullanılır. Günlük içerikler çevrimiçi olduğunda sonraki 30 gün için cihazda önbelleğe alınır ve internet olmadan açılabilir.

## Gönderimden önce manuel kontroller

- En az bir kabul edilen iPhone ekran görüntüsü yükle; 5–7 ekran önerilir.
- Age Rating anketini içerikle uyumlu tamamla; `Unrated` bırakma.
- Fiyat ücretsizse `Free` ve dağıtım ülkelerini seç.
- DSA trader/non-trader durumunu tamamla.
- Content Rights beyanını Kur'an, hadis, harita ve diğer üçüncü taraf içeriklerinin kullanım hakları/lisanslarıyla uyumlu tamamla.
- App Privacy cevaplarını yayımla.
- Meta SDK’nın Xcode Privacy Report çıktısıyla App Privacy cevaplarını karşılaştır.
- Support ve Privacy URL’lerinin oturum açmadan açıldığını doğrula.
- Gerçek cihazda konum `Allow Once`, `While Using`, `Don’t Allow` ve kalıcı reddetme akışlarını dene.
- Uçak modunda daha önce önbelleğe alınan Bugün sayfasını aç.
- `Add for Review` sonrasında App Review sayfasında ayrıca `Submit for Review` düğmesine bas.
