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
        let hostName: String = "172.19.136..161"
        let port: Int = 31105
        let token: String = ""
        
        let headers: HPACKHeaders = ["authorization" : token]
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

