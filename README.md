# Marti Case - Konum Takip Uygulaması

Flutter ile geliştirilmiş, kullanıcının konumunu izleyen ve her 100 metrelik değişimde haritaya marker ekleyen bir mobil uygulama.

## 📱 Özellikler

- ✅ **Konum Takibi**: Kullanıcının konumunu gerçek zamanlı olarak izler
- ✅ **Akıllı Marker Ekleme**: Her 100 metre değişimde otomatik marker eklenir
- ✅ **Ön Plan & Arka Plan Takibi**: Uygulama minimize edilse bile konum takibi devam eder
- ✅ **Adres Bilgisi**: Marker'lara tıklandığında konum adresi görüntülenir (geocoding)
- ✅ **Başlat/Durdur**: Kullanıcı istediği zaman takibi kontrol edebilir
- ✅ **Rota Sıfırlama**: Tüm marker'ları temizleme özelliği
- ✅ **Veri Kalıcılığı**: Uygulama kapatılsa bile veriler saklanır (SharedPreferences)
- ✅ **Harita Görüntüleme**: Google Maps üzerinde marker'lar ve kullanıcı konumu

## 🛠️ Teknolojiler

- **Flutter SDK**: 3.8.1+
- **Google Maps Flutter**: Harita görüntüleme
- **Geolocator**: Konum takibi
- **Geocoding**: Adres bilgisi alma
- **Permission Handler**: İzin yönetimi
- **SharedPreferences**: Veri kalıcılığı

## 📦 Kurulum

### Gereksinimler
- Flutter SDK (3.8.1 veya üzeri)
- Android Studio / Xcode
- Google Maps API Key (proje içinde bulunuyor)

### Adımlar

1. **Repoyu klonlayın**
```bash
git clone https://github.com/berkayismus/marti_case.git
cd marti_case
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Uygulamayı çalıştırın**
```bash
# Android için
flutter run

# iOS için (Mac gerekli)
cd ios && pod install && cd ..
flutter run
```

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                          # Ana uygulama giriş noktası
├── models/
│   └── location_marker.dart          # Konum marker model sınıfı
├── services/
│   ├── location_service.dart         # Konum takip servisi
│   └── storage_service.dart          # Veri saklama servisi
└── screens/
    └── map_screen.dart               # Harita ekranı ve UI
```

## 🎯 Özellik Detayları

### Konum Takibi
- `Geolocator` paketi ile yüksek hassasiyetli konum takibi
- 10 metre filter ile sürekli pozisyon güncellemeleri
- 100 metre threshold kontrolü ile akıllı marker ekleme
- Ön plan ve arka plan desteği

### Veri Yönetimi
- `SharedPreferences` ile lokal depolama
- JSON serializasyon/deserializasyon
- Uygulama yeniden başlatıldığında otomatik veri yükleme

### Kullanıcı Arayüzü
- Google Maps entegrasyonu
- Gerçek zamanlı marker ekleme ve görüntüleme
- Marker'a tıklayınca adres bilgisi dialog'u
- Başlat/Durdur ve Sıfırla butonları
- Toplam konum sayacı

## 🔐 İzinler

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
```

### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Bu uygulama konumunuzu harita üzerinde göstermek için konum izni gerektiriyor.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Bu uygulama arka planda da konumunuzu takip edebilmek için konum izni gerektiriyor.</string>
```

## 📝 Kullanım

1. **Uygulamayı başlatın**: İlk açılışta konum izni istenir
2. **"Takibi Başlat" butonuna basın**: Konum takibi başlar ve ilk marker eklenir
3. **Hareket edin**: Her 100 metrede yeni bir marker otomatik eklenir
4. **Marker'a dokunun**: Konum bilgileri ve adres görüntülenir
5. **"Takibi Durdur"**: İzlemeyi durdurmak için
6. **"Rotayı Sıfırla" (üst sağ)**: Tüm marker'ları temizlemek için

## 🚀 Test

### Gerçek Cihazda Test
```bash
flutter run --release
```

### Emülatörde Test (Konum simülasyonu gerekir)
```bash
flutter run
```

## 📄 Lisans

Bu proje Marti case study için geliştirilmiştir.

## 👨‍💻 Geliştirici

**Berkay Çaylı**
- GitHub: [@berkayismus](https://github.com/berkayismus)

## 🙏 Teşekkürler

Marti ekibine bu fırsatı sağladıkları için teşekkür ederim!
