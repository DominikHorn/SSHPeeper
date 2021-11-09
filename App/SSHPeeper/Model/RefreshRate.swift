//
//  RefreshRate.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 09.11.21.
//

import Foundation

enum RefreshRate: String, CaseIterable, Identifiable {
  case low
  case medium
  case high
  
  var id: String { self.rawValue }
  
  var seconds: Int {
    switch self {
    case .low:
      return 120
    case .medium:
      return 30
    case .high:
      return 5
    }
  }
}
