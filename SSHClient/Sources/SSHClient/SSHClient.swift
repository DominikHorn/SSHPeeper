import Dispatch
import Foundation
import NIO
import NIOSSH

public actor SSHClient {
  private let delegate: SSHClientDelegate
  private let group: MultiThreadedEventLoopGroup
  private let rootChannel: Channel
  
  // TODO: authentication?
  public init(host: String, port: Int = 22, auth: Auth, delegate: SSHClientDelegate) async throws {
    self.delegate = delegate
    self.group = .init(numberOfThreads: 1)
    
    let bootstrap = ClientBootstrap(group: group)
      .channelInitializer { channel in
        let clientConfig = SSHClientConfiguration(userAuthDelegate: auth, serverAuthDelegate: auth)
        let role = SSHConnectionRole.client(clientConfig)
        
        return channel.pipeline.addHandlers([
          NIOSSHHandler(role: role, allocator: channel.allocator, inboundChildChannelInitializer: nil),
          InboundEventHandler(onUserBanner: delegate.onBanner(message:), onError: delegate.onError(error:))
        ])
      }
      .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
      .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
    
    self.rootChannel = try await withCheckedThrowingContinuation { continuation in
      do {
        let channel = try bootstrap.connect(host: host, port: port).wait()
        continuation.resume(returning: channel)
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
  
  public func execute(_ command: String) async throws -> (Int, String) {
    return try await withCheckedThrowingContinuation { continuation in
      let parent = rootChannel
      let delegate = delegate
      do {
        let exitStatusPromise = rootChannel.eventLoop.makePromise(of: (Int, String).self)
        let childChannel: Channel = try parent.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
          let promise = parent.eventLoop.makePromise(of: Channel.self)
          sshHandler.createChannel(promise, channelType: .session) { childChannel, channelType in
            childChannel.pipeline.addHandlers([
              ExecHandler(command: command, completePromise: exitStatusPromise),
              InboundEventHandler(onUserBanner: delegate.onBanner(message:), onError: delegate.onError(error:))
            ])
          }
          return promise.futureResult
        }.wait()
        
        // Wait for result
        try childChannel.closeFuture.wait()
        let result = try exitStatusPromise.futureResult.wait()
        continuation.resume(returning: result)
      } catch {
        print(error.localizedDescription)
        continuation.resume(throwing: error)
      }
    }
  }
  
  deinit {
    // TODO: gracefully disconnect
    try! group.syncShutdownGracefully()
  }
  
  enum ClientError: Error {
    case invalidChannelType
    case invalidSelf
    case ourCablesAreBroken
  }
}
