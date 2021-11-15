//
//  MemUsageView.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 09.11.21.
//

import SwiftUI
import DequeModule

struct MemUsageView: View {
  @Binding var stats: Deque<ProcessStats>
  
  var body: some View {
    LineChart(entries: stats.map { .init(x: $0.timestamp.timeIntervalSinceReferenceDate, y: $0.memoryPercent)})
  }
}
