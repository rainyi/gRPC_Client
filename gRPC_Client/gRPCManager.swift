//
//  gRPCManager.swift
//  gRPC_Client
//
//  Created by rainyi on 2021/01/20.
//

import Foundation
import NIO
import NIOSSL
import GRPC
import SwiftProtobuf
import NIOHTTP2
import NIOHTTP1
import NIOHPACK
import Logging

class gRPCManager: NSObject, ClientErrorDelegate, ConnectivityStateDelegate {
    
    typealias ChatStreamResponse = (Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse) -> Void
    typealias CurrentState = (ConnectivityState) -> Void
    typealias Failure = (Error) -> Void
    typealias Success = (AnyObject) -> Void
    
    private var chatStreamResponseHandler: ChatStreamResponse?
    private var currentStateHandler: CurrentState?
    private var errorHandler: Failure?
    private var successHandler: Success?
    
    var hostName: String = "172.19.136.161"
    var portNumber: Int = 31105
    var group: MultiThreadedEventLoopGroup?
    var connection: ClientConnection?
    var chatRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom()
    var chatRoomServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient?
    var chatStreamServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol?
    var streamRequest = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest()
    var clientCall: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>?
    var chatRoomID: String?
    
    override init() {
        super.init()
    }
    
    deinit {
        self.disconnect()
        self.commonInit()
    }
    
    func commonInit() {
        if self.group != nil {
            self.group = nil
        }
        
        if self.connection != nil {
            self.connection = nil
        }
        
        if self.chatRoomServiceClient != nil {
            self.chatRoomServiceClient = nil
        }
        
        if self.chatStreamServiceClient != nil {
            self.chatStreamServiceClient = nil
        }
    }
    
    func connet(host: String?, port: Int?, success: @escaping Success, chatStreamRespnse: @escaping ChatStreamResponse, state: @escaping CurrentState, error: @escaping Failure) {
        if let h: String = host {
            self.hostName = h
        }
        
        if let p: Int = port {
            self.portNumber = p
        }
        
        self.successHandler = success
        self.chatStreamResponseHandler = chatStreamRespnse
        self.currentStateHandler = state
        self.errorHandler = error
        
        self.initConnect()
    }
    
    func initConnect() {
        self.commonInit()
        
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        if let gr: MultiThreadedEventLoopGroup = self.group {
            var configuration = ClientConnection.Configuration(target: .hostAndPort(self.hostName, self.portNumber), eventLoopGroup: gr, tls: nil, connectionBackoff: ConnectionBackoff(initialBackoff: 1, maximumBackoff: 60, multiplier: 1, jitter: 1, minimumConnectionTimeout: 5, retries: .upTo(5)))
//            var configuration = ClientConnection.Configuration(target: .hostAndPort(host ?? self.hostName, port ?? self.portNumber), eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1))
            
            configuration.errorDelegate = self
            configuration.connectivityStateDelegate = self
            
            // connection 시작, 클라이언트 생성
            self.connection = ClientConnection.init(configuration: configuration)
            
            self.connecting()
        }
    }
    
    func connecting() {
        if let channel: ClientConnection = self.connection {
            self.chatRoomServiceClient = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient(channel: channel)
            self.chatStreamServiceClient = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient(channel: channel)
            self.makeRPCCall()
        }
    }
    
    func disconnect() {
//        do {
            if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.clientCall {
                call.sendEnd(promise: nil)
//                _ = try call.status.wait()
            }
//        } catch let error {
//            print("\(type(of: self)): Could not shutdown gracefully -", error.localizedDescription)
//        }
        
        if let channel: ClientConnection = self.connection {
            do {
                try channel.close().wait()
            } catch let error {
                print("\(type(of: self)): channel close -", error.localizedDescription)
            }
        }
        
        if let gr: MultiThreadedEventLoopGroup = self.group {
            do {
                try gr.syncShutdownGracefully()
            } catch let error {
                print("\(type(of: self)): syncShutdownGracefully -", error.localizedDescription)
            }
        }
    }
    
    func checkConnectionState() {
        if let channel: ClientConnection = self.connection {
            if channel.connectivity.state != .ready {
                self.connecting()
            }
        } else {
            self.initConnect()
        }
    }
    
    func checkWhetherStatus(status: GRPCStatus) -> Bool {
        var result: Bool = false
        
        print(#function, status)
        
        // https://github.com/grpc/grpc/blob/master/doc/statuscodes.md
        switch status.code {
        case .ok:
            result = true
            break
            
        case .cancelled:
            break
            
        case .unknown:
            break
            
        case .invalidArgument:
            break
            
        case .deadlineExceeded:
            self.initConnect()
            break
            
        case .notFound:
            break
            
        case .alreadyExists:
            break
            
        case .permissionDenied:
            break
            
        case .resourceExhausted:
            break
            
        case .failedPrecondition:
            if let fail: Failure = self.errorHandler {
                fail(status)
            }
            
            break
            
        case .aborted:
            break
            
        case .outOfRange:
            break
            
        case .unimplemented:
            break
            
        case .internalError:
            break
            
        case .dataLoss:
            break
            
        case .unauthenticated:
            break
            
        default:
            break
        }
        
        return result
    }
    
    func makeRPCCall() {
//        let timeAmount = TimeAmount.minutes(1)
//        let timeLimit = TimeLimit.timeout(timeAmount)
//        let options = CallOptions(timeLimit: timeLimit)
        
        if let client: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol = self.chatStreamServiceClient {
            self.clientCall = client.send(callOptions: nil, handler: { [weak self] (response) in
                print(response)
                
                if let weakSelf = self {
                    if let responseHandler: ChatStreamResponse = weakSelf.chatStreamResponseHandler {
                        responseHandler(response)
                    }
                }
            })
            
            if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.clientCall {
                call.status.whenSuccess { [weak self] (status) in
                    print(#function, status)
                    
                    if let weakSelf = self {
                        _ = weakSelf.checkWhetherStatus(status: status)
                    }
                }
                
                call.status.whenFailure { [weak self] (error) in
                    print(#function, error)
                    
                    if let weakSelf = self {
                        if let fail: Failure = weakSelf.errorHandler {
                            fail(error)
                        }
                    }
                }
                
                call.status.whenComplete { (result) in
                    print(#function, result)

                    switch result {
                    case let .success(value):
                        print(value)

                    case let .failure(error):
                        print(error)

                    }
                }
            }
        }
    }
    
    func getChatRoomList(completion: @escaping (Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomResponse?) -> Void) {
        self.checkConnectionState()
        
        if let chatRoomServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient = self.chatRoomServiceClient {
            let request = Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomRequest()

            let call: UnaryCall = chatRoomServiceClient.getAll(request)

            call.response.whenComplete { (result) in
                switch result {
                case .success(let response):
                    print(#function, response)
                    completion(response)
                case .failure(let error):
                    print("CALL FAILED WITH ERROR\n\(error)")
                    completion(nil)
                }
            }
            
            call.status.whenSuccess { (status) in
                print(#function, status)

                if status.code != .ok {
                    completion(nil)
                }
            }

            call.status.whenFailure { (error) in
                print(#function, error)

                completion(nil)
            }
        }
    }
    
    func createChatRoom (createRoomID: String, createRoomTitle: String = "의 방") {
        self.checkConnectionState()
        
        var createChatRequest = Com_Ncsoft_Aiss_Chat_Paige_V1_CreateChatRoomRequest()
        
        createChatRequest.chatRoomID = createRoomID
        createChatRequest.chatRoomTitle = createRoomTitle
        
        if let client: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient = self.chatRoomServiceClient {
            client.create(createChatRequest).status.whenComplete { (result) in
                switch result {
                case let .success(value):
                    print(value)
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
    func joinChatRoom(chatRoomID: String, userID: String, userName: String) {
        self.chatRoomID = chatRoomID
        self.checkConnectionState()
        self.streamRequest.chatRoomID = chatRoomID
        self.streamRequest.command = .join
        self.streamRequest.userID = userID
        self.streamRequest.userName = userName
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>
            = self.clientCall {
            call.sendMessage(streamRequest, compression: .deferToCallDefault, promise: .none)
        }
    }
    
    func leaveChatRoom() {
        self.checkConnectionState()
        self.streamRequest.command = .leave
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.clientCall {
            call.sendMessage(streamRequest, compression: .deferToCallDefault, promise: .none)
        }
    }
    
    func sendMessageToChatRoom(message: String) {
        self.checkConnectionState()
        self.streamRequest.command = .chat
        self.streamRequest.message = message
        
        if self.clientCall == nil {
            self.makeRPCCall()
        }
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.clientCall {
            call.sendMessage(streamRequest, compression: .deferToCallDefault, promise: .none)
        }
    }
    
    
    //MARK: - ClientErrorDelegate methods
    func didCatchError(_ error: Error, logger: Logger, file: StaticString, line: Int) {
        print(error.localizedDescription)
        
        if let fail: Failure = self.errorHandler {
            fail(error)
        }
    }
    
    //MARK: - ConnectivityStateDelegate methods
    func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState) {
        print(#function, oldState, newState)
        
        if let state: CurrentState = self.currentStateHandler {
            state(newState)
        }
    }
    
    func connectionStartedQuiescing() {
        print("connectionStartedQuiescing")
    }
    
}
