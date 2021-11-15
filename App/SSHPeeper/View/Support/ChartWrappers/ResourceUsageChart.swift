//
//  LineChart.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 15.11.21.
//

import Charts
import SwiftUI
import DequeModule

struct ResourceUsageChart: NSViewRepresentable {
  let data: Deque<ProcessStats>
  
  let yValueFormatter: AxisValueFormatter = PercentageFormatter()
  let xValueFormatter: AxisValueFormatter = DateValueFormatter()
  
  func makeNSView(context: Context) -> LineChartView {
    LineChartView()
  }
  
  func updateNSView(_ nsView: LineChartView, context: Context) {
    // MARK: dataset
    // TODO: localize
    let memUsageDS = LineChartDataSet(entries: data.map { .init(x: $0.timestamp.timeIntervalSinceReferenceDate, y: $0.memoryPercent)}, label: "Memory Usage")
    memUsageDS.mode = .linear
    memUsageDS.lineWidth = 3
    memUsageDS.drawCirclesEnabled = false
    
    let cpuUsageDS = LineChartDataSet(entries: data.map { .init(x: $0.timestamp.timeIntervalSinceReferenceDate, y: $0.cpuPercent)}, label: "CPU Usage")
    cpuUsageDS.mode = .linear
    cpuUsageDS.lineWidth = 3
    cpuUsageDS.drawCirclesEnabled = false
    cpuUsageDS.colors = [.orange]
    
    // MARK: general view
    nsView.xAxis.drawGridLinesEnabled = false
    nsView.xAxis.drawLabelsEnabled = true
    nsView.xAxis.labelPosition = .bottom
    nsView.xAxis.labelFont = .labelFont(ofSize: 14)
    nsView.xAxis.labelCount = 3
    nsView.xAxis.valueFormatter = xValueFormatter
    
    nsView.legend.enabled = true
    nsView.legend.font = .boldSystemFont(ofSize: 16)
    nsView.legend.entries.forEach {
      $0.form = .line
    }
    nsView.legend.xEntrySpace = 10
    
    nsView.leftAxis.drawLabelsEnabled = true
    nsView.leftAxis.labelFont = .labelFont(ofSize: 14)
    nsView.leftAxis.valueFormatter = yValueFormatter
    
    nsView.rightAxis.drawLabelsEnabled = false
    nsView.rightAxis.drawGridLinesEnabled = false
    nsView.rightAxis.drawAxisLineEnabled = false
    
    // MARK: update data
    nsView.data = LineChartData(dataSets: [memUsageDS, cpuUsageDS])
  }
}

extension ResourceUsageChart {
  class DateValueFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
      let formatter = DateFormatter()
      formatter.dateStyle = .none
      formatter.timeStyle = .medium
      return formatter.string(from: Date(timeIntervalSinceReferenceDate: value))
    }
  }
  
  class PercentageFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
      String(format: "%.1f %%", value * 100)
    }
  }
}
