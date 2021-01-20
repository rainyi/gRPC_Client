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
    
    let hostName: String = "172.19.136.161"
    let port: Int = 31105
    var chatRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom()
    var chatRoomServiceclient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient?
    var chatStreamServiceClientProtocol: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol?
    var streamRequest = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest()
    var bidirectionalStreamingCall: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>?
    
    override init() {
        let configuration = ClientConnection.Configuration(target: .hostAndPort(hostName, port), eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1))
        self.chatRoomServiceclient = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient(channel: ClientConnection(configuration: configuration))
        self.chatStreamServiceClientProtocol = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient(channel: ClientConnection(configuration: configuration))
        
        super.init()
    }
    
    func getChatRoomList() -> Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomResponse? {
        do {
            let request = Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomRequest()
            
            if let chatRoomServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient = self.chatRoomServiceclient {
                let response = try chatRoomServiceClient.getAll(request).response.wait()

                print(response)
                
                return response
            }
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func joinToChatRoom(chatRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom, userID: String, userName: String, completion: @escaping (_ result: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse) -> Void) {
        self.streamRequest.chatRoomID = chatRoom.id
        self.streamRequest.command = .join
        self.streamRequest.userID = userID
        self.streamRequest.userName = userName
        
        if let client: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol = self.chatStreamServiceClientProtocol {
            self.bidirectionalStreamingCall = client.send(handler: { (response) in
                print(response)

                completion(response)
            })
        }
        
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
    }
    
    //MARK: - ConnectivityStateDelegate methods
    func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState) {
        print(oldState, newState)
    }
    
    func connectionStartedQuiescing() {
        print("connectionStartedQuiescing")
    }
    
}
