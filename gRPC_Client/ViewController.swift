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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func commonInit() {
        let hostName: String = "172.19.136.161"
        let port: Int = 31105
//        let token: String = ""
//
//        let headers: HPACKHeaders = ["authorization" : token]
        
        
        // Create an event Loop group
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        // Make sure the group is shutdown when we're done with it.
        defer {
            try! group.syncShutdownGracefully()
        }
        
        #if true
        // Create client connection builder
        let builder: ClientConnection.Builder
        
        builder = ClientConnection.secure(group: group)
        
        // Start the connection and create the client
        let connection = builder.connect(host: hostName, port: port)
        
        print("Connection Status=>:\(connection)")
        
        // Create client
        let client = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient.init(channel: connection)
        
        let streamingCall: BidirectionalStreamingCall = client.send(callOptions: nil) { (response) in
            print(response)
        }
        
        let request: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest()
        
        
        streamingCall.sendMessage(request)
        
        
        
        #endif
        
//        // Configure the channel, we're not using TLS so the connection is `insecure`.
//        let channel = ClientConnection.insecure(group: group)
//            .connect(host: hostName, port: port)
//
//        // Close the connection when we're done with it.
//        do {
//            try! channel.close().wait()
//        }
//
//        let room: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient(channel: channel)
//
//        let stream: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient(channel: channel)
//
//        room.create(<#T##request: Com_Ncsoft_Aiss_Chat_Paige_V1_CreateChatRoomRequest##Com_Ncsoft_Aiss_Chat_Paige_V1_CreateChatRoomRequest#>)
//
//        stream.send(callOptions: nil) { (response) in
//            print(response)
//        }
        
        
    }
    
    func getRequest(client: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient) {
        
        
//        do {
//            //build the request Header
//            let getRequestParam: <yourRequest> = .with {
//                $0.<your defined parameter in .pb.swift file for request> = "value"
//                $0.<param2> = “value”
//                $0.<param3> = “value”
//            }
//            //call the request service
//            let getUserRequest = client.getDetails(getRequestParam)
//            getUserRequest.response.whenComplete { result in
//                print(“Output for get request:\(result)”)
//            }
//            let detailsStatus = try getUserRequest.status.wait()
//            print(“Staus:::\(detailsStatus) \n \(detailsStatus.code))”)
//        } catch {
//            print(“Error for get Request:\(error)”)
//        }
    }
    
    func greet(name: String?, client greeter: Helloworld_GreeterClient) {
      // Form the request with the name, if one was provided.
      let request = Helloworld_HelloRequest.with {
        $0.name = name ?? ""
      }

      // Make the RPC call to the server.
      let sayHello = greeter.sayHello(request)

      // wait() on the response to stop the program from exiting before the response is received.
      do {
        let response = try sayHello.response.wait()
        print("Greeter received: \(response.message)")
      } catch {
        print("Greeter failed: \(error)")
      }
    }
    
}

