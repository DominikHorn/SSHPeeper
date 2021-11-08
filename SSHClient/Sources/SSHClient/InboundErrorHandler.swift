//
//  InboundErrorHandler.swift
//  
//
//  Created by Dominik Horn on 07.11.21.
//

import Foundation
import NIO

final class InboundErrorHandler: ChannelInboundHandler {
  typealias InboundIn = Any
  
  func errorCaught(context: ChannelHandlerContext, error: Error) {
    // TODO: proper error handling
    print("Error in pipeline: \(error.localizedDescription)")
    context.close(promise: nil)
  }
}
