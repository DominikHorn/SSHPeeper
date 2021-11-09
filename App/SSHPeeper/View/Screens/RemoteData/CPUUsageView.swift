//
//  CPUUsageView.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 10.11.21.
//

import SwiftUI
import DequeModule
import SwiftUICharts

struct CPUUsageView: View {
  @Binding var stats: Deque<ProcessStats>
  
  var body: some View {
    LineChartView(data: stats.map({ $0.cpuPercent }), title: "CPU %")
  }
}
