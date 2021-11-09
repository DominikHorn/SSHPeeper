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
  
  private let onUserBanner: (String) -> Void
  private let onError: (Error) -> Void
  
  init(onUserBanner: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
    self.onUserBanner = onUserBanner
    self.onError = onError
  }
  
  func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
    if let event = event as? NIOUserAuthBannerEvent {
      // Filter control characters as advised in RFC 4252
      let filteredMessage = event.message.trimmingCharacters(in: .controlCharacters)
      onUserBanner(filteredMessage)
    }
  }
  
  func errorCaught(context: ChannelHandlerContext, error: Error) {
    onError(error)
    context.close(promise: nil)
  }
}
