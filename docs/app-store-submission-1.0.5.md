# İslami Cep 1.0.5 — App Store gönderim kontrolü

## App Store Connect alanları

- Copyright: `2026 Uğur Baran`
- Privacy Policy URL: `https://ugurbarann.github.io/islamic-app/privacy-policy.html`
- Support URL: `https://ugurbarann.github.io/islamic-app/`
- Support email: `admin@ugurbaran.com`
- Sign-in required: Hayır
- Release: Onaydan sonra kontrol isteniyorsa `Manually release this version`
- Build: `1.0.5 (5)`
- Platform: iPhone only
- Export compliance: Uygulama yalnız işletim sistemi/standart HTTPS şifrelemesi kullanır; `ITSAppUsesNonExemptEncryption = NO` pakete eklendi.

## App Privacy beyanı

- Tracking: Hayır
- User account: Yok
- Advertising: Yok
- Precise Location: Toplanır/kullanılır; kullanıcıyla ilişkilendirilmez; takip için kullanılmaz; amaç `App Functionality`
- Konum kullanım amacı: namaz vakti il/ilçe seçimi, kıble ve yakındaki camiler
- Üçüncü taraflar: Firebase/Firestore, Google Maps Platform, OpenStreetMap tabanlı servisler ve Ezan Vakti servisi

App Store Connect beyanı, uygulamadaki ve üçüncü taraf SDK’lardaki gerçek veri davranışıyla aynı tutulmalıdır.

## Review Notes önerisi

> İslami Cep kullanıcı hesabı veya giriş gerektirmez. İlk açılışta konum izni yalnız namaz vakitleri için il/ilçe seçmek, kıble yönünü hesaplamak ve yakındaki camileri göstermek amacıyla istenir. İzin verilmezse uygulama varsayılan/seçilmiş il ve ilçeyle çalışmaya devam eder. Konum daha sonra Ayarlar > Geçerli Konumu Kullan alanından tekrar etkinleştirilebilir. Günlük içerikler çevrimiçi olduğunda sonraki 30 gün için cihazda önbelleğe alınır ve internet olmadan açılabilir.

## Gönderimden önce manuel kontroller

- En az bir kabul edilen iPhone ekran görüntüsü yükle; 5–7 ekran önerilir.
- Age Rating anketini içerikle uyumlu tamamla; `Unrated` bırakma.
- Fiyat ücretsizse `Free` ve dağıtım ülkelerini seç.
- DSA trader/non-trader durumunu tamamla.
- App Privacy cevaplarını yayımla.
- Support ve Privacy URL’lerinin oturum açmadan açıldığını doğrula.
- Gerçek cihazda konum `Allow Once`, `While Using`, `Don’t Allow` ve kalıcı reddetme akışlarını dene.
- Uçak modunda daha önce önbelleğe alınan Bugün sayfasını aç.
- `Add for Review` sonrasında App Review sayfasında ayrıca `Submit for Review` düğmesine bas.
