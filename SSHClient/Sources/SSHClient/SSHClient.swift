import Dispatch
import Foundation
import NIO
import NIOSSH

public actor SSHClient {
  private let group: MultiThreadedEventLoopGroup
  private let rootChannel: Channel
  
  init(host: String, port: Int = 22) async throws {
    group = .init(numberOfThreads: 1)
    let bootstrap = ClientBootstrap(group: group)
      .channelInitializer { channel in
        let authDelegate = AuthDelegate()
        
        let clientConfig = SSHClientConfiguration(userAuthDelegate: authDelegate, serverAuthDelegate: authDelegate)
        let role = SSHConnectionRole.client(clientConfig)
        
        return channel.pipeline.addHandlers([
          NIOSSHHandler(role: role, allocator: channel.allocator, inboundChildChannelInitializer: nil),
          InboundErrorHandler()
        ])
      }
      .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
      .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
    
    rootChannel = try await withCheckedThrowingContinuation { continuation in
      do {
        let channel = try bootstrap.connect(host: host, port: port).wait()
        continuation.resume(returning: channel)
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
  
  func execute(_ command: String) async throws -> (Int, String) {
    return try await withCheckedThrowingContinuation { continuation in
      do {
        let childChannel: Channel = try rootChannel.pipeline.handler(type: NIOSSHHandler.self).flatMap { [unowned self] sshHandler in
          let promise = rootChannel.eventLoop.makePromise(of: Channel.self)
          sshHandler.createChannel(promise) { childChannel, channelType in
            guard channelType == .session else {
              return rootChannel.eventLoop.makeFailedFuture(ClientError.invalidChannelType)
            }
            
            // TODO: implement
            return childChannel.pipeline.addHandlers([])
  //          return childChannel.pipeline.addHandlers([
  //            ExecHandler(command: command)
  //          ])
          }
          
          return promise.futureResult
        }.wait()
        
        // TODO
        try childChannel.closeFuture.wait()
        //    let exitStatus = try! exitStatusPromise.futureResult.wait()
      } catch {
        continuation.resume(throwing: error)
      }
      
      
      // TODO: implement
      continuation.resume(returning: (0, ""))
    }
  }
  
  deinit {
    // TODO: gracefully disconnect
    try! group.syncShutdownGracefully()
  }
  
  enum ClientError: Error {
    case invalidChannelType
    case invalidSelf
  }
}
