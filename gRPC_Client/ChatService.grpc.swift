//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: ChatService.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import SwiftProtobuf


/// services
///
/// Usage: instantiate `Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient`, then call methods of this protocol to make API calls.
internal protocol Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClientInterceptorFactoryProtocol? { get }

  func create(
    _ request: Com_Ncsoft_Aiss_Chat_Paige_V1_CreateChatRoomRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Com_Ncsoft_Aiss_Chat_Paige_V1_CreateChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom>

  func remove(
    _ request: Com_Ncsoft_Aiss_Chat_Paige_V1_RemoveChatRoomRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Com_Ncsoft_Aiss_Chat_Paige_V1_RemoveChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom>

  func get(
    _ request: Com_Ncsoft_Aiss_Chat_Paige_V1_GetChatRoomRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Com_Ncsoft_Aiss_Chat_Paige_V1_GetChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom>

  func getAll(
    _ request: Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomResponse>
}

extension Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClientProtocol {
  internal var serviceName: String {
    return "com.ncsoft.aiss.chat.paige.v1.ChatRoomService"
  }

  /// Unary call to create
  ///
  /// - Parameters:
  ///   - request: Request to send to create.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func create(
    _ request: Com_Ncsoft_Aiss_Chat_Paige_V1_CreateChatRoomRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Com_Ncsoft_Aiss_Chat_Paige_V1_CreateChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom> {
    return self.makeUnaryCall(
      path: "/com.ncsoft.aiss.chat.paige.v1.ChatRoomService/create",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makecreateInterceptors() ?? []
    )
  }

  /// Unary call to remove
  ///
  /// - Parameters:
  ///   - request: Request to send to remove.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func remove(
    _ request: Com_Ncsoft_Aiss_Chat_Paige_V1_RemoveChatRoomRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Com_Ncsoft_Aiss_Chat_Paige_V1_RemoveChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom> {
    return self.makeUnaryCall(
      path: "/com.ncsoft.aiss.chat.paige.v1.ChatRoomService/remove",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeremoveInterceptors() ?? []
    )
  }

  /// Unary call to get
  ///
  /// - Parameters:
  ///   - request: Request to send to get.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func get(
    _ request: Com_Ncsoft_Aiss_Chat_Paige_V1_GetChatRoomRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Com_Ncsoft_Aiss_Chat_Paige_V1_GetChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom> {
    return self.makeUnaryCall(
      path: "/com.ncsoft.aiss.chat.paige.v1.ChatRoomService/get",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makegetInterceptors() ?? []
    )
  }

  /// Unary call to getAll
  ///
  /// - Parameters:
  ///   - request: Request to send to getAll.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getAll(
    _ request: Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomResponse> {
    return self.makeUnaryCall(
      path: "/com.ncsoft.aiss.chat.paige.v1.ChatRoomService/getAll",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makegetAllInterceptors() ?? []
    )
  }
}

internal protocol Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'create'.
  func makecreateInterceptors() -> [ClientInterceptor<Com_Ncsoft_Aiss_Chat_Paige_V1_CreateChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom>]

  /// - Returns: Interceptors to use when invoking 'remove'.
  func makeremoveInterceptors() -> [ClientInterceptor<Com_Ncsoft_Aiss_Chat_Paige_V1_RemoveChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom>]

  /// - Returns: Interceptors to use when invoking 'get'.
  func makegetInterceptors() -> [ClientInterceptor<Com_Ncsoft_Aiss_Chat_Paige_V1_GetChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom>]

  /// - Returns: Interceptors to use when invoking 'getAll'.
  func makegetAllInterceptors() -> [ClientInterceptor<Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomResponse>]
}

internal final class Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the com.ncsoft.aiss.chat.paige.v1.ChatRoomService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// Usage: instantiate `Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient`, then call methods of this protocol to make API calls.
internal protocol Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientInterceptorFactoryProtocol? { get }

  func send(
    callOptions: CallOptions?,
    handler: @escaping (Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse) -> Void
  ) -> BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>
}

extension Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol {
  internal var serviceName: String {
    return "com.ncsoft.aiss.chat.paige.v1.ChatStreamService"
  }

  /// Bidirectional streaming call to send
  ///
  /// Callers should use the `send` method on the returned object to send messages
  /// to the server. The caller should send an `.end` after the final message has been sent.
  ///
  /// - Parameters:
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ClientStreamingCall` with futures for the metadata and status.
  internal func send(
    callOptions: CallOptions? = nil,
    handler: @escaping (Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse) -> Void
  ) -> BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> {
    return self.makeBidirectionalStreamingCall(
      path: "/com.ncsoft.aiss.chat.paige.v1.ChatStreamService/send",
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makesendInterceptors() ?? [],
      handler: handler
    )
  }
}

internal protocol Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'send'.
  func makesendInterceptors() -> [ClientInterceptor<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>]
}

internal final class Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the com.ncsoft.aiss.chat.paige.v1.ChatStreamService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}
