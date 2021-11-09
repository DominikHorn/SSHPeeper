//
//  SSHClientDelegate.swift
//  
//
//  Created by Dominik Horn on 09.11.21.
//

import Foundation

public protocol SSHClientDelegate {
  func onBanner(message: String) -> Void
  func onError(error: Error) -> Void
}
