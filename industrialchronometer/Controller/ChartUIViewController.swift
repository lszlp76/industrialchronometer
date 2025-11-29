//
//  ChartUIViewController.swift
//  industrialchronometer
//
//  Final Solution: UIScrollView Wrapper Method
//

import UIKit
import DGCharts
import GoogleMobileAds

class ChartUIViewController: UIViewController, ChartViewDelegate {

    // MARK: - ViewModel
    var viewModel: ChronometerViewModel?
    
    // MARK: - UI Elements
    @IBOutlet weak var containerView: UIView!
    
    // YENİ YAPI: ScrollView grafiği tutacak
    private var scrollView: UIScrollView!
    private var combinedChartView: CombinedChartView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollViewAndChart() // Yeni Kurulum
        // setupNavigationButtons() -> PageVC yönetiyor, burayı boş bırak.
        // TEMA DİNLEYİCİSİ
                NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChange), name: .themeChanged, object: nil)
    }
    // Tema değişince çalışacak fonksiyon
        @objc func handleThemeChange() {
            // Eksen renklerini güncellemek için setup'ı tekrar çağırabilir veya manuel güncelleyebiliriz
            // En temiz yol eksen renklerini güncelleyip datayı yenilemektir.
            
            let textColor = AppTheme.Color.mainText
            
            // Eksen Renkleri
            combinedChartView.xAxis.labelTextColor = textColor
            combinedChartView.leftAxis.labelTextColor = textColor
            
            // Data'yı yenile (Çizgilerin üzerindeki yazılar için)
            updateChartData()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChartData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ekran dönünce veya boyut değişince frame'leri güncelle
        if scrollView != nil {
            scrollView.frame = containerView.bounds
            // Content size updateChartData içinde yapılıyor
        }
    }
    
    // MARK: - Setup (En Önemli Kısım)
    
    private func setupScrollViewAndChart() {
        view.backgroundColor = .clear
        // 1. ScrollView Oluştur
        scrollView = UIScrollView()
        scrollView.frame = containerView.bounds
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true // Yaylanma efekti (PageView geçişini kolaylaştırır)
        containerView.addSubview(scrollView)
        
        // 2. ChartView Oluştur (Standart Sınıf)
        combinedChartView = CombinedChartView()
        // Başlangıçta ekran kadar yer kaplasın, sonra büyüteceğiz
        combinedChartView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        scrollView.addSubview(combinedChartView)
        
        // 3. Grafiğin Kendi Dokunmatiklerini KAPAT (Kritik Nokta)
        combinedChartView.dragEnabled = false      // Grafiğin kendi kaydırması KAPALI
        combinedChartView.setScaleEnabled(false)   // Zoom KAPALI (ScrollView yönetecek)
        combinedChartView.pinchZoomEnabled = false
        combinedChartView.highlightPerTapEnabled = true // Tıklama açık kalabilir
        combinedChartView.doubleTapToZoomEnabled = false
        
        // 4. Görsel Ayarlar
        combinedChartView.chartDescription.enabled = false
        combinedChartView.drawOrder = [
            CombinedChartView.DrawOrder.bar.rawValue,
            CombinedChartView.DrawOrder.line.rawValue
        ]
        combinedChartView.legend.enabled = true
        combinedChartView.legend.verticalAlignment = .bottom
        combinedChartView.legend.horizontalAlignment = .center
        
        // Eksen Ayarları
        let xAxis = combinedChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1.0
        xAxis.labelFont = .systemFont(ofSize: 14, weight: .bold)
        xAxis.labelTextColor = .gray
        
        let leftAxis = combinedChartView.leftAxis
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridLineDashLengths = [5, 3, 1, 3]
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        leftAxis.labelTextColor = .gray
        leftAxis.axisMinimum = 0
        
        combinedChartView.rightAxis.enabled = false
        combinedChartView.delegate = self
    }
    
    // MARK: - Data Update & Resizing
    
    private func updateChartData() {
        guard let vm = viewModel else { return }
        
        let chartPoints = vm.getChartViewModel().dataPoints
        let textColor = AppTheme.Color.mainText // <--- YENİ RENK
        
        if chartPoints.isEmpty {
            combinedChartView.data = nil
            combinedChartView.noDataText = "No Data Available"
            return
        }
        
        // --- GRAFİĞİ GENİŞLETME MANTIĞI ---
        let barWidth: CGFloat = 60.0 // Her bir bar için ayrılan piksel
        let calculatedWidth = CGFloat(chartPoints.count) * barWidth
        
        // Genişlik en az ekran kadar olsun, veri çoksa uzasın
        let totalWidth = max(containerView.frame.width, calculatedWidth)
        
        // 1. Grafiğin boyutunu fiziksel olarak büyüt
        combinedChartView.frame = CGRect(x: 0, y: 0, width: totalWidth, height: containerView.frame.height)
        
        // 2. ScrollView'a içeriğin büyüdüğünü söyle
        scrollView.contentSize = CGSize(width: totalWidth, height: containerView.frame.height)
        
        // --- VERİ DOLDURMA (Aynı kalıyor) ---
        
        // A. Bar Data
        var barEntries: [BarChartDataEntry] = []
        for point in chartPoints {
            barEntries.append(BarChartDataEntry(x: Double(point.lapNumber), y: point.value))
        }
        let barDataSet = BarChartDataSet(entries: barEntries, label: "Cycle Time")
        barDataSet.colors = [NSUIColor.systemBlue.withAlphaComponent(0.7)]
        barDataSet.valueFont = UIFont(name: "RobotEx", size: 10) ?? .systemFont(ofSize: 10)
         barDataSet.axisDependency = .left
         barDataSet.valueTextColor = textColor // <--- GÜNCELLE
        // B. Line Data
        var lineEntries: [ChartDataEntry] = []
        var currentSum: Double = 0
        for (index, point) in chartPoints.enumerated() {
            currentSum += point.value
            let avg = currentSum / Double(index + 1)
            lineEntries.append(ChartDataEntry(x: Double(point.lapNumber), y: avg))
        }
        let lineDataSet = LineChartDataSet(entries: lineEntries, label: "Avg. Trend")
        lineDataSet.setColor(.systemYellow)
        lineDataSet.lineWidth = 3.0
        lineDataSet.circleRadius = 4.0
        lineDataSet.setCircleColor(.systemYellow)
        lineDataSet.mode = .cubicBezier
        lineDataSet.valueFont = .systemFont(ofSize: 12, weight: .bold)
        lineDataSet.valueTextColor = .systemOrange
        
        // C. Limit Lines
        let leftAxis = combinedChartView.leftAxis
        leftAxis.removeAllLimitLines()
        
        let maxVal = chartPoints.map { $0.value }.max() ?? 0
        let minVal = chartPoints.map { $0.value }.min() ?? 0
        
        let maxLine = ChartLimitLine(limit: maxVal, label: "Max: \(String(format: "%.2f", maxVal))")
        maxLine.lineWidth = 2.0
        maxLine.lineColor = .systemRed
        maxLine.labelPosition = .leftTop
        maxLine.valueFont = .systemFont(ofSize: 12, weight: .bold)
        maxLine.valueTextColor = .systemRed
        
        let minLine = ChartLimitLine(limit: minVal, label: "Min: \(String(format: "%.2f", minVal))")
        minLine.lineWidth = 2.0
        minLine.lineColor = .systemOrange
        minLine.labelPosition = .leftBottom
        minLine.valueFont = .systemFont(ofSize: 12, weight: .bold)
        minLine.valueTextColor = .systemOrange
        
        leftAxis.addLimitLine(maxLine)
        leftAxis.addLimitLine(minLine)
        leftAxis.axisMaximum = maxVal * 1.15
        
        // D. Combine
        let data = CombinedChartData()
        data.barData = DGCharts.BarChartData(dataSet: barDataSet)
        data.lineData = DGCharts.LineChartData(dataSet: lineDataSet)
        data.barData.barWidth = 0.5
        
        combinedChartView.data = data
        
        // ÖNEMLİ: Artık setVisibleXRangeMaximum KULLANMIYORUZ.
        // Çünkü grafiği fiziksel olarak uzattık.
        
        // Eğer yeni veri geldiyse sağa kaydır (ScrollView metoduyla)
        if scrollView.contentSize.width > scrollView.frame.width {
            let rightOffset = CGPoint(x: scrollView.contentSize.width - scrollView.frame.width, y: 0)
            scrollView.setContentOffset(rightOffset, animated: true)
        }
        
        combinedChartView.notifyDataSetChanged()
    }
    
    // MARK: - Actions (Public)
    
    @objc func saveChartToGallery() {
        // ScrollView kullanınca tüm grafiğin (görünmeyen kısımlar dahil) fotosunu çekmek gerekir
        guard let chartImage = getFullChartImage() else {
            showAlert(title: "Error", message: "Could not create image from chart.")
            return
        }
        UIImageWriteToSavedPhotosAlbum(chartImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // Uzun grafiğin tamamının resmini çeker
    private func getFullChartImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(combinedChartView.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        combinedChartView.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Save Error", message: error.localizedDescription)
        } else {
            showAlert(title: "Success!", message: "Chart image saved to your Photos.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
