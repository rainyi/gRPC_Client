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
    
    typealias CurrentState = (ConnectivityState) -> Void
    typealias Failure = (Error) -> Void
    typealias Success = (AnyObject) -> Void
    
    private var currentStateHandler: CurrentState?
    private var errorHandler: Failure?
    private var successHandler: Success?
    
    let hostName: String = "172.19.136.161"
    let portNumber: Int = 31105
    var connection: ClientConnection?
    var chatRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom()
    var chatRoomServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient?
    var chatStreamServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol?
    var streamRequest = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest()
    var bidirectionalStreamingCall: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>?
    
    override init() {
        super.init()
    }
    
    func connet(host: String?, port: Int?, success: @escaping Success, state: @escaping CurrentState, error: @escaping Failure) {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        var configuration = ClientConnection.Configuration(target: .hostAndPort(host ?? self.hostName, port ?? self.portNumber), eventLoopGroup: group, tls: nil, connectionBackoff: ConnectionBackoff(initialBackoff: 1, maximumBackoff: 60, multiplier: 1, jitter: 1, minimumConnectionTimeout: 5))
//        var configuration = ClientConnection.Configuration(target: .hostAndPort(host ?? self.hostName, port ?? self.portNumber), eventLoopGroup: group)

        configuration.errorDelegate = self
        configuration.connectivityStateDelegate = self
        
        self.successHandler = success
        self.currentStateHandler = state
        self.errorHandler = error
        
        // connection 시작, 클라이언트 생성
        self.connection = ClientConnection.init(configuration: configuration)
        self.chatRoomServiceClient = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient(channel: self.connection!)
        
    }
    
    func disconnect() {
        if let channel: ClientConnection = self.connection {
            do {
                try! channel.close().wait()
            }
        }
    }
    
    func getChatRoomList() -> Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomResponse? {
        do {
            let request = Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomRequest()
            
            if let chatRoomServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient = self.chatRoomServiceClient {
                let response = try chatRoomServiceClient.getAll(request).response.wait()
                
                print(response)
                
                return response
            }
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func connectChatClientStreamService(completion: @escaping (_ result: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse) -> Void) {
        if let channel: ClientConnection = self.connection {
            self.chatStreamServiceClient = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient(channel: channel)
            
            if let client: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol = self.chatStreamServiceClient {
                self.bidirectionalStreamingCall = client.send(handler: { (response) in
                    print(response)
                    
                    completion(response)
                })
            }
            
            if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.bidirectionalStreamingCall {
                call.status.whenSuccess({ (status) in
                    print(#function, status)
                })
                
                call.status.whenFailure({ (error) in
                    print(#function, error)
                })
                
                call.status.whenComplete({ (result) in
                    print(#function, result)
                    
                    switch result {
                    case let .success(value):
                        print(value)
                        
                    case let .failure(error):   
                        print(error)
                        
                    }
                })
            }
        }
    }
    
    func createChatRoom (createRoomID: String, createRoomTitle: String = "우경이의 방") {
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
    
    func joinChatRoom(chatRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom, userID: String, userName: String) {
        self.streamRequest.chatRoomID = "````test4````" // chatRoom.id
        self.streamRequest.command = .join
        self.streamRequest.userID = userID
        self.streamRequest.userName = userName
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>
            = self.bidirectionalStreamingCall {
            call.sendMessage(streamRequest, compression: .deferToCallDefault, promise: .none)
        }
    }
    
    func leaveChatRoom() {
        self.streamRequest.command = .leave
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.bidirectionalStreamingCall {
            call.sendMessage(streamRequest, compression: .deferToCallDefault, promise: .none)
        }
    }
    
    func sendMessageToChatRoom(message: String) {
        self.streamRequest.command = .chat
        self.streamRequest.message = message
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.bidirectionalStreamingCall {
            call.sendMessage(streamRequest, compression: .deferToCallDefault, promise: .none)
        }
    }
    
//    Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom
    
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
