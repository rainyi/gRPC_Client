//
//  ViewController.swift
//  gRPC_Client
//
//  Created by Rainyi on 2021/01/19.
//

import UIKit
import NIO
import NIOSSL
import GRPC
import SwiftProtobuf
import NIOHTTP2
import NIOHTTP1
import NIOHPACK

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btnJoin: UIButton!
    
    @IBOutlet weak var tfMessage: UITextField!
    
    var chatRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom()
    var client: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient?
    var streamRequest = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest()
    var bdsCall: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>?
    
    lazy var configuration: GRPC.ClientConnection.Configuration = {
        let hostName: String = "172.19.136.161"
        let port: Int = 31105
        
        let configuration = ClientConnection.Configuration(
            target: .hostAndPort(hostName, port),
            eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1)
        )
        
        return configuration
    }()
    
    lazy var streamClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol = {
        let streamClient = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient(channel: ClientConnection(configuration: configuration))
        
        return streamClient
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.btnJoin.isEnabled = false
        self.tfMessage.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.commonInit()
    }
    
    func commonInit() {
        if let response: Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomResponse = self.getChatRoom() {
            if response.chatRooms.count > 0 {
                if let selectChatRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom = response.chatRooms.first {
                    self.chatRoom = selectChatRoom
                    self.btnJoin.isEnabled = true
                }
            }
        }
    }
    
    func getChatRoom() -> Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomResponse? {
        do {
            self.client = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient(channel: ClientConnection(configuration: self.configuration))
            let request = Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomRequest()
            
            if let chatRoomServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient = self.client {
                let response = try chatRoomServiceClient.getAll(request).response.wait()

                print(response)
                
                return response
            }
        } catch {
            print("ERROR\n\(error)")
        }
        
        return nil
    }
    
    func joinToChatRoom() {
        self.streamRequest.chatRoomID = "asdfasdfkjaslkfjaslkfjslk" // self.chatRoom.id
        self.streamRequest.command = .join
        self.streamRequest.userID = "2"
        self.streamRequest.userName = "레이니2"
        
        self.bdsCall = self.streamClient.send(handler: { [weak self] (streamRequest) in
            print(streamRequest)
            
            if let weakSelf = self {
                DispatchQueue.main.async {
                    if streamRequest.command == .chat {
                        weakSelf.tfMessage.text = ""
                        weakSelf.view.endEditing(true)
                    } else {
                        weakSelf.tfMessage.isEnabled = true
                    }
                }
            }
        })
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>
            = self.bdsCall {
            call.sendMessage(streamRequest, compression: .deferToCallDefault, promise: .none)
        }
    }
    
    func sendMessageToChatRoom(message: String) {
        self.view.endEditing(true)
        
        self.streamRequest.command = .chat
        self.streamRequest.message = message
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.bdsCall {
            call.sendMessage(streamRequest, compression: .deferToCallDefault, promise: .none)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text: String = textField.text {
            if text.count > 0 {
                self.sendMessageToChatRoom(message: text)
            }
        }
        
        return true
    }
    
    @IBAction func joinButtonWasPressed(_ sender: Any) {
        self.joinToChatRoom()
    }
    
}

