//
//  ProcessStats.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 09.11.21.
//

import Foundation

struct ProcessStats {
  var timestamp: Date = Date()
  var cpuPercent: Float = 0.0
  var memoryPercent: Float = 0.0
}
