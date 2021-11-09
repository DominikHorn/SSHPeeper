//
//  InboundEventHandler.swift
//  
//
//  Created by Dominik Horn on 07.11.21.
//

import Foundation
import NIO
import NIOSSH

final class InboundEventHandler: ChannelInboundHandler {
  typealias InboundIn = Any
  
  private let onUserBanner: (String) async -> Void
  private let onError: (Error) async -> Void
  
  init(onUserBanner: @escaping (String) async -> Void, onError: @escaping (Error) async -> Void) {
    self.onUserBanner = onUserBanner
    self.onError = onError
  }
  
  func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
    if let event = event as? NIOUserAuthBannerEvent {
      Task {
        // Filter control characters as advised in RFC 4252
        let filteredMessage = event.message.trimmingCharacters(in: .controlCharacters)
        await onUserBanner(filteredMessage)
      }
    }
  }
  
  func errorCaught(context: ChannelHandlerContext, error: Error) {
    Task {
      context.close(promise: nil)
      await onError(error)
    }
  }
}
