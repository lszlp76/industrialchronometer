//
//  LapChartView.swift
//  industrialchronometer
//
//  Created by ulas özalp on 22.11.2025.
//
import SwiftUI
import Charts // iOS 16+ için

@available(iOS 16.0, *)
struct LapChartView: View {
    @ObservedObject var viewModel: ChronometerViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.chartData.isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView("No Data", systemImage: "chart.xyaxis.line", description: Text("Start the timer and take laps to see the chart."))
                    } else {
                        // Fallback on earlier versions
                    }
                } else {
                    Chart(viewModel.chartData) { item in
                        // Çizgi Grafiği
                        LineMark(
                            x: .value("Lap", item.lapNumber),
                            y: .value("Time", item.value)
                        )
                        .interpolationMethod(.catmullRom) // Eğrisel çizgi
                        .symbol(by: .value("Type", "Cycle Time"))
                        
                        // Noktaları belirginleştir
                        PointMark(
                            x: .value("Lap", item.lapNumber),
                            y: .value("Time", item.value)
                        )
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartXAxisLabel("Lap Number")
                    .chartYAxisLabel("Time (\(viewModel.currentUnitLabel))")
                    .padding()
                }
                
                // Alt bilgi
                HStack {
                    StatBox(title: "Avg", value: viewModel.avgCycleText)
                    StatBox(title: "Max", value: viewModel.maxCycleText)
                    StatBox(title: "Min", value: viewModel.minCycleText)
                }
                .padding()
            }
            .navigationTitle("Live Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        // UIKit'ten kapatmak için dismiss işlemi
                        // HostingController kullanacağımız için buna gerek kalmayabilir ama bulunsun.
                    }
                }
            }
        }
    }
}

// Ufak bir istatistik kutusu tasarımı
struct StatBox: View {
    let title: String
    let value: String
    var body: some View {
        VStack {
            Text(title).font(.caption).foregroundColor(.gray)
            if #available(iOS 15.0, *) {
                Text(value).font(.headline).monospacedDigit()
            } else {
                Text(value).font(.headline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
