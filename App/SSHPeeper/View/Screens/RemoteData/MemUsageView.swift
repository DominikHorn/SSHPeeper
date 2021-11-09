//
//  MemUsageView.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 09.11.21.
//

import SwiftUI
import DequeModule
import SwiftUICharts

struct MemUsageView: View {
  @Binding var stats: Deque<ProcessStats>
  
  var body: some View {
    PieChartView(data: [stats.last?.memoryPercent ?? 0, 1 - (stats.last?.memoryPercent ?? 0)], title: "Memory Usage")
  }
}
