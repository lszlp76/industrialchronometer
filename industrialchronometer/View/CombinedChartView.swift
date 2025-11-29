//
//  CombinedChartView.swift
//  industrialchronometer
//
//  Refactored on 24.11.2025
//

import SwiftUI

struct CombinedChartView: View {
    @ObservedObject var viewModel: ChronometerViewModel
    
    var body: some View {
        let chartData = viewModel.getChartViewModel()
        let data = chartData.dataPoints
        
        // Veri setindeki GERÇEK maksimum değeri buluyoruz
        let absoluteMax = data.map { $0.value }.max() ?? 0
        
        VStack(spacing: 10) {
            
            if data.isEmpty {
                emptyStateView
            } else {
                // 1. GRAFİK ALANI
                GeometryReader { geometry in
                    let height = geometry.size.height
                    let width = geometry.size.width
                    
                    let itemWidth: CGFloat = 50
                    let totalChartWidth = max(width, CGFloat(data.count) * itemWidth)
                    
                    ZStack(alignment: .topLeading) {
                        
                        // A. SABİT KATMAN (Grid + Limit Çizgileri)
                        ZStack(alignment: .topLeading) {
                            
                            // A1. Arka Plan Grid
                            drawFixedGrid(maxY: chartData.maxY, height: height, width: width)
                            
                            // A2. Max ve Min Çizgileri (DÜZ ÇİZGİ)
                            
                            // DÜZELTME: Artık 'chartData.maxY / 1.1' yerine 'absoluteMax' kullanıyoruz.
                            // Böylece çizgi tam olarak en uzun barın tepesine yapışır.
                            LimitLineView(value: absoluteMax, color: .red, label: "Max", isDashed: false, chartData: chartData, height: height, width: width)
                            
                            LimitLineView(value: chartData.minY, color: .orange, label: "Min", isDashed: false, chartData: chartData, height: height, width: width)
                        }
                        .zIndex(0)
                        
                        // B. KAYDIRILABİLİR İÇERİK (Barlar + Trend)
                        ScrollView(.horizontal, showsIndicators: false) {
                            ZStack(alignment: .bottom) {
                                
                                // B1. Bar Chart
                                HStack(alignment: .bottom, spacing: 0) {
                                    ForEach(data) { point in
                                        let normalizedValue = chartData.normalizedValue(point.value)
                                        let barHeight = height * normalizedValue
                                        
                                        VStack(spacing: 4) {
                                            Spacer()
                                            
                                            // Bar Değeri
                                            Text(String(format: "%.1f", point.value))
                                                .font(Font(AppTheme.Font.robotex(size: 15)))
                                                .foregroundColor(Color(AppTheme.Color.mainText ?? .label))
                                                .lineLimit(1)
                                                .fixedSize()
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.blue.opacity(0.7))
                                            // --- X EKSENİ (LAP NO) ---
                                            Text("\(point.lapNumber)")
                                                .font(.system(size: 14, weight: .medium)) // FONT BÜYÜTÜLDÜ (Eski: caption2)
                                                .foregroundColor(.gray)
                                                .frame(height: 25) // Yükseklik artırıldı
                                        }
                                                .frame(width: itemWidth * 0.5, height: max(0, barHeight))
                                        .frame(width: itemWidth)
                                    }
                                }
                                
                                // B2. Kümülatif Ortalama (Trend)
                                if data.count > 1 {
                                    drawTrendLine(data: data, height: height, itemWidth: itemWidth, chartData: chartData)
                                }
                                
                            }
                            .frame(width: totalChartWidth, height: height)
                        }
                        .zIndex(1)
                    }
                }
                .padding(.leading, 30)
                .padding(.vertical)
                
                // 2. LEGEND
                HStack(spacing: 15) {
                    LegendItem(color: .blue, text: "Cycle Time")
                    LegendItem(color: .yellow, text: "Avg. Trend")
                    LegendItem(color: .red, text: "Max Limit")
                    LegendItem(color: .orange, text: "Min Limit")
                }
                .padding(.bottom, 10)
            }
        }
        .padding()
        .background(Color(AppTheme.Color.systemBackground ?? .systemBackground))
    }
    
    // MARK: - Helpers
    
    var emptyStateView: some View {
        VStack {
            Image(systemName: "chart.xyaxis.line")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("No Data Available").foregroundColor(.gray).padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func drawFixedGrid(maxY: Double, height: CGFloat, width: CGFloat) -> some View {
        let numberOfLines = 5
        return ZStack {
            ForEach(0...numberOfLines, id: \.self) { i in
                let normalizedY = CGFloat(i) / CGFloat(numberOfLines)
                let yPos = height * (1 - normalizedY)
                let value = (maxY / Double(numberOfLines)) * Double(i)
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: yPos))
                    path.addLine(to: CGPoint(x: width, y: yPos))
                }
                .stroke(
                    Color.gray.opacity(0.4),
                    style: StrokeStyle(lineWidth: 1, dash: [5, 3, 1, 3])
                )
                
                // --- Y EKSENİ DEĞERLERİ ---
                                Text(String(format: "%.1f", value))
                                    .font(.system(size: 12)) // FONT BÜYÜTÜLDÜ (Eski: caption2)
                                    .foregroundColor(.gray)
                                    .position(x: -25, y: yPos) // Sola kaydırma artırıldı (-20 -> -25)
                            }
        }
    }
    
    func drawTrendLine(data: [ChartDataPoint], height: CGFloat, itemWidth: CGFloat, chartData: ChartViewModel) -> some View {
        ZStack {
            Path { path in
                var currentSum: Double = 0
                for (index, point) in data.enumerated() {
                    currentSum += point.value
                    let currentAvg = currentSum / Double(index + 1)
                    let normalized = chartData.normalizedValue(currentAvg)
                    let yPos = height * (1 - normalized)
                    let xPos = (CGFloat(index) * itemWidth) + (itemWidth / 2)
                    let p = CGPoint(x: xPos, y: yPos)
                    if index == 0 { path.move(to: p) } else { path.addLine(to: p) }
                }
            }
            .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                let subset = data[0...index]
                let sum = subset.reduce(0) { $0 + $1.value }
                let avg = sum / Double(index + 1)
                
                let normalized = chartData.normalizedValue(avg)
                let yPos = height * (1 - normalized)
                let xPos = (CGFloat(index) * itemWidth) + (itemWidth / 2)
                
                Group {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 6, height: 6)
                        .position(x: xPos, y: yPos)
                    
                    Text(String(format: "%.1f", avg))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .black, radius: 1, x: 0, y: 0)
                        .position(x: xPos, y: yPos - 12)
                }
            }
        }
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(text)
                .font(.caption)
                .foregroundColor(Color(AppTheme.Color.mainText ?? .label))
        }
    }
}

// MARK: - Limit Line View
struct LimitLineView: View {
    let value: Double
    let color: Color
    let label: String
    var isDashed: Bool
    var lineWidth: CGFloat = 1
    let chartData: ChartViewModel
    let height: CGFloat
    let width: CGFloat
    
    var body: some View {
        let normalized = chartData.normalizedValue(value)
        let safeNormalized = (normalized.isNaN || normalized.isInfinite) ? 0 : normalized
        let yPos = height * (1 - safeNormalized)
        
        ZStack(alignment: .leading) {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: width, y: 0))
            }
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, dash: isDashed ? [5] : []))
            
            Text("\(label): \(String(format: "%.2f", value))")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .padding(4)
                .background(color.opacity(0.8))
                .cornerRadius(4)
                .offset(x: 5, y: -10)
        }
        .offset(y: yPos)
        .frame(height: 1, alignment: .top)
    }
}
