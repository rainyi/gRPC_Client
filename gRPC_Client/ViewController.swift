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
        let hostName: String = ""
        let port: Int = 0
        let token: String = ""
        
        let headers: HPACKHeaders = ["authorization" : token]
    }
}

