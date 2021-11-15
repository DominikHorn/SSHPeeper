//
//  LineChart.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 15.11.21.
//

import Charts
import SwiftUI

struct LineChart: NSViewRepresentable {
  let entries: [ChartDataEntry]
  let yValueFormatter: AxisValueFormatter = PercentageFormatter()
  let xValueFormatter: AxisValueFormatter = DateValueFormatter()
  
  func makeNSView(context: Context) -> LineChartView {
    LineChartView()
  }
  
  func updateNSView(_ nsView: LineChartView, context: Context) {
    // MARK: dataset
    let dataset = LineChartDataSet(entries: entries)
    dataset.mode = .linear
    dataset.lineWidth = 5
    dataset.drawCirclesEnabled = false
    dataset.drawValuesEnabled = false
    nsView.data = LineChartData(dataSet: dataset)
    
    // MARK: general view
    nsView.xAxis.drawGridLinesEnabled = false
    nsView.xAxis.drawLabelsEnabled = true
    nsView.xAxis.labelPosition = .bottom
    nsView.xAxis.labelFont = .labelFont(ofSize: 14)
    nsView.xAxis.valueFormatter = xValueFormatter
    nsView.xAxis.labelCount = 6
    
    nsView.legend.enabled = false
    
    nsView.leftAxis.drawLabelsEnabled = true
    nsView.leftAxis.labelFont = .labelFont(ofSize: 14)
    nsView.leftAxis.valueFormatter = yValueFormatter
    
    nsView.rightAxis.drawLabelsEnabled = false
    nsView.rightAxis.drawGridLinesEnabled = false
    nsView.rightAxis.drawAxisLineEnabled = false
  }
}

extension LineChart {
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
      String(format: "%.0f %%", value * 100)
    }
  }
}

struct LineChart_Previews: PreviewProvider {
  static var previews: some View {
    LineChart(entries: [
      .init(x: 10, y: 0.2),
      .init(x: 2000, y: 0.4),
      .init(x: 5000, y: 0.99),
      .init(x: 10000, y: 0.99),
      .init(x: 20000, y: 0.7),
    ])
  }
}
