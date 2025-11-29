Industrial Chronometer ⏱️
Industrial Chronometer, endüstri mühendisleri ve zaman etüdü uzmanları için tasarlanmış, yüksek hassasiyetli bir iOS uygulamasıdır. Standart zaman birimlerinin (saniye) yanı sıra endüstriyel zaman birimi olan Cmin (Centiminute - 1/100 dakika) formatını destekler.

Uygulama; modern MVVM mimarisi, Reactive Programming (Combine), Live Activities ve tamamen özelleştirilebilir Neon/Glassmorphism arayüzü ile geliştirilmiştir.

🌟 Temel Özellikler
Çift Birim Desteği: Saniye ve Cmin (Endüstriyel Dakika) arasında anlık geçiş.

Gelişmiş Veri Görselleştirme: DGCharts kullanılarak oluşturulan, kaydırılabilir ve zoom yapılabilir dinamik tur grafikleri.

Live Activities & Dynamic Island: Uygulama arka plandayken bile kilit ekranında canlı sayaç takibi (iOS 16.2+).

Veri Yönetimi: Çalışmaların CSV formatında kaydedilmesi, dosya yönetimi ve paylaşımı (WhatsApp/Mail uyumlu).

Dinamik Tema Motoru: Dark/Light mod desteğinin yanı sıra, uygulama içi "System", "Dark" ve "Light" tema seçimi.

Özel UI Bileşenleri: NeonGlassButton, ThemedLabel gibi özel tasarım bileşenleri.

🏗 Mimari ve Teknoloji Yığını
Proje, MVVM (Model-View-ViewModel) mimari deseni üzerine kurulmuştur. Veri akışı ve UI güncellemeleri için Combine framework'ü kullanılmıştır.

Dil: Swift 5

UI Framework: UIKit (Storyboard & Programmatic UI mix)

Reactivity: Combine (Data Binding)

Grafik Kütüphanesi: DGCharts (Eski adıyla MPAndroidChart)

Diğer Kütüphaneler: ActivityKit (Live Activities), LinkPresentation (Share Sheet Metadata), AVFoundation (Volume Key Control).

📂 Proje Klasör Yapısı
Proje, sorumlulukların ayrılması (Separation of Concerns) ilkesine göre modüler bir yapıda düzenlenmiştir:

Plaintext
IndustrialChronometer/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
│
├── Models/              # Veri Modelleri
│   ├── Laps.swift       # Tekil tur verisi yapısı
│   └── LapsVal.swift    # Tur hesaplama ve istatistik mantığı
│
├── ViewModels/          # İş Mantığı ve State Yönetimi
│   └── ChronometerViewModel.swift  # Timer, State ve Combine publisher'ları
│
├── Views/
│   ├── Controllers/     # View Controller'lar
│   │   ├── PageViewController.swift      # Ana navigasyon container'ı
│   │   ├── ViewController.swift          # Kronometre (Ana Ekran)
│   │   ├── ChartUIViewController.swift   # Grafik Ekranı (DGCharts Wrapper)
│   │   ├── FileListViewController.swift  # Kayıtlı dosyalar ve Paylaşım
│   │   └── AboutViewController.swift     # Ayarlar ve Tema seçimi
│   │
│   ├── Cells/           # Custom TableView Hücreleri
│   │   ├── LapListCellTableViewCell.swift
│   │   ├── LapLineViewControllerTableViewCell.swift
│   │   └── FileTableViewCell.swift
│   │
│   └── CustomComponents/ # Yeniden kullanılabilir UI bileşenleri
│       ├── NeonGlassButton.swift    # Neon ve Cam efektli buton
│       ├── ThemedLabel.swift        # Tema duyarlı etiket
│       └── GlassButton.swift
│
├── Helpers/             # Yardımcı Sınıflar ve Extension'lar
│   ├── AppTheme.swift           # Merkezi Tema Yönetimi (Renkler, Fontlar)
│   ├── Extensions.swift         # UIKit genişletmeleri (Alert, View vb.)
│   ├── TransferService.swift    # Dosya okuma/yazma işlemleri
│   └── ShareActivityItemSource.swift # LPLinkMetadata uyumlu paylaşım
│
├── Resources/
│   ├── Assets.xcassets  # İkonlar ve Renk Setleri
│   ├── Fonts/           # DS-Digital ve Roboto fontları
│   └── Base.lproj/
│       └── Main.storyboard
│
└── WidgetExtension/     # Live Activity Target'ı
    └── ChronometerWidget.swift
🔧 Teknik Detaylar ve Çözümler
1. Dinamik Tema Yönetimi (AppTheme)

Uygulama, iOS sistem temasından bağımsız olarak kendi temasını yönetebilir. NotificationCenter ve UserDefaults kullanılarak tüm UI bileşenleri anlık olarak güncellenir.

Swift
// AppTheme.swift
static var currentTheme: ThemeType {
    // Kullanıcı tercihine veya Sistem moduna göre karar verir
}

// Kullanım (ThemedLabel.swift)
NotificationCenter.default.addObserver(self, selector: #selector(updateColor), name: .themeChanged, object: nil)
2. Grafik Entegrasyonu (ChartUIViewController)

DGCharts kütüphanesi, UIPageViewController'ın gesture hareketleriyle çakışmaması için özel bir UIScrollView wrapper içerisine alınmıştır. Bu sayede grafik yatayda sonsuz kaydırılabilirken, sınırlar aşıldığında sayfa geçişine izin verilir.

3. WhatsApp Beyaz Ekran Sorunu Çözümü

Paylaşım sırasında UIActivityItemSource protokolü LinkPresentation kütüphanesi ile güçlendirilmiştir. Dosya paylaşımı sırasında LPLinkMetadata sağlanarak WhatsApp ve diğer uygulamalarda dosya önizlemesinin doğru çalışması sağlanmıştır.

Swift
func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
    let metadata = LPLinkMetadata()
    metadata.title = title
    metadata.originalURL = fileURL // Kritik nokta
    return metadata
}
🚀 Kurulum
Projeyi yerel ortamınızda çalıştırmak için:

Repoyu klonlayın:

Bash
git clone https://github.com/kullaniciadi/IndustrialChronometer.git
Proje dizinine gidin ve CocoaPods bağımlılıklarını yükleyin:

Bash
cd IndustrialChronometer
pod install
industrialchronometer.xcworkspace dosyasını Xcode ile açın.

Target cihazı seçin ve Run (Cmd+R) yapın.

📝 Gereksinimler
iOS 14.0+ (Live Activities için iOS 16.2+)

Xcode 14.0+

Swift 5.0+
