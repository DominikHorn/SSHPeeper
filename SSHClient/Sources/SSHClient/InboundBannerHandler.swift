//
//  InboundBannerHandler.swift
//  
//
//  Created by Dominik Horn on 08.11.21.
//

import Foundation
import NIO
import NIOSSH

final class InboundBannerHandler: ChannelInboundHandler {
  typealias InboundIn = UserAuthBannerEvent
  
  func userInboundEventTriggered(context: ChannelHandlerContext, event: UserAuthBannerEvent) {
    // TODO: properly display banner
    print(event.message)
  }
}
