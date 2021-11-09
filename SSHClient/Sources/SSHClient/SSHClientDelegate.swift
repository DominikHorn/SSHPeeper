//
//  SSHClientDelegate.swift
//  
//
//  Created by Dominik Horn on 09.11.21.
//

import Foundation

public protocol SSHClientDelegate: AnyObject {
  func onBanner(message: String) async -> Void
  func onError(error: Error) async -> Void
}
