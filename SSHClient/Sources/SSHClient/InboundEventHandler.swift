//
//  InboundEventHandler.swift
//  
//
//  Created by Dominik Horn on 07.11.21.
//

import Foundation
import NIO
import NIOSSH

final class InboundEventHandler<T: SSHClientDelegate>: ChannelInboundHandler {
  typealias InboundIn = Any
  
  private weak var delegate: T?
  
  init(delegate: T? = nil) {
    self.delegate = delegate
  }
  
  func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
    if let event = event as? NIOUserAuthBannerEvent {
      Task {
        // Filter control characters as advised in RFC 4252
        let filteredMessage = event.message.trimmingCharacters(in: .controlCharacters)
        await delegate?.onBanner(message: filteredMessage)
      }
    }
  }
  
  func errorCaught(context: ChannelHandlerContext, error: Error) {
    context.close(promise: nil)
    Task {
      await delegate?.onError(error: error)
    }
  }
}
