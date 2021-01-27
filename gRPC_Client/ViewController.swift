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
    
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var btnDisconnect: UIButton!
    @IBOutlet weak var btnGetRoomList: UIButton!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var btnLeave: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    
    @IBOutlet weak var tfHostName: UITextField!
    @IBOutlet weak var tfPort: UITextField!
    @IBOutlet weak var tfRoomID: UITextField!
    @IBOutlet weak var tfMessage: UITextField!
    
    var chatRoomID: String?
//    var chatRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom()
    
    var grpcManager: gRPCManager = gRPCManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.initButtons()
        self.makeBorderButton()
        self.changeStateButton()
        
//        self.btnConnect.isEnabled = true
//        self.btnDisconnect.isEnabled = false
//        self.btnGetRoomList.isEnabled = false
//        self.btnCreate.isEnabled = false
//        self.btnJoin.isEnabled = false
//        self.btnLeave.isEnabled = false
//        self.btnSend.isEnabled = false
    }
    
    func initButtons() {
        self.btnConnect.setBackgroundImage(self.colorGraphic(color: UIColor.gray), for: .disabled)
        self.btnDisconnect.setBackgroundImage(self.colorGraphic(color: UIColor.gray), for: .disabled)
        self.btnGetRoomList.setBackgroundImage(self.colorGraphic(color: UIColor.gray), for: .disabled)
        self.btnJoin.setBackgroundImage(self.colorGraphic(color: UIColor.gray), for: .disabled)
        self.btnCreate.setBackgroundImage(self.colorGraphic(color: UIColor.gray), for: .disabled)
        self.btnLeave.setBackgroundImage(self.colorGraphic(color: UIColor.gray), for: .disabled)
        self.btnSend.setBackgroundImage(self.colorGraphic(color: UIColor.gray), for: .disabled)
    }
    
    func colorGraphic(color:UIColor) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = colorImage {
            return image
        }
        
        return UIImage.init()
    }
    
    func makeBorderButton() {
        self.btnConnect.layer.masksToBounds = true
        self.btnConnect.layer.cornerRadius = 5
        self.btnConnect.layer.borderWidth = 0.5
        self.btnConnect.layer.borderColor = UIColor.black.cgColor
        
        self.btnDisconnect.layer.masksToBounds = true
        self.btnDisconnect.layer.cornerRadius = 5
        self.btnDisconnect.layer.borderWidth = 0.5
        self.btnDisconnect.layer.borderColor = UIColor.black.cgColor
        
        self.btnGetRoomList.layer.masksToBounds = true
        self.btnGetRoomList.layer.cornerRadius = 5
        self.btnGetRoomList.layer.borderWidth = 0.5
        self.btnGetRoomList.layer.borderColor = UIColor.black.cgColor
        
        self.btnJoin.layer.masksToBounds = true
        self.btnJoin.layer.cornerRadius = 5
        self.btnJoin.layer.borderWidth = 0.5
        self.btnJoin.layer.borderColor = UIColor.black.cgColor
        
        self.btnCreate.layer.masksToBounds = true
        self.btnCreate.layer.cornerRadius = 5
        self.btnCreate.layer.borderWidth = 0.5
        self.btnCreate.layer.borderColor = UIColor.black.cgColor
        
        self.btnLeave.layer.masksToBounds = true
        self.btnLeave.layer.cornerRadius = 5
        self.btnLeave.layer.borderWidth = 0.5
        self.btnLeave.layer.borderColor = UIColor.black.cgColor
        
        self.btnSend.layer.masksToBounds = true
        self.btnSend.layer.cornerRadius = 5
        self.btnSend.layer.borderWidth = 0.5
        self.btnSend.layer.borderColor = UIColor.black.cgColor
    }
    
    func changeStateButton() {
//        var state: ConnectivityState = .idle
//
//        if let s: ConnectivityState = self.grpcManager.connection?.connectivity.state {
//            state = s
//        }
//
//        if state == .idle || state == .shutdown {
//            self.btnConnect.isEnabled = true
//            self.btnDisconnect.isEnabled = false
//            self.btnGetRoomList.isEnabled = false
//            self.btnCreate.isEnabled = false
//            self.btnJoin.isEnabled = false
//            self.btnLeave.isEnabled = false
//            self.btnSend.isEnabled = false
//        } else if state == .ready {
//            self.btnConnect.isEnabled = false
//            self.btnDisconnect.isEnabled = true
//            self.btnGetRoomList.isEnabled = true
//            self.btnCreate.isEnabled = false
//            self.btnJoin.isEnabled = false
//            self.btnLeave.isEnabled = false
//            self.btnSend.isEnabled = true
//        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfRoomID {
            self.btnCreate.isEnabled = true
            self.btnJoin.isEnabled = true
        } else if textField == self.tfMessage {
            self.sendButtonWasPressed(self.btnSend!)
        }
        
        return true
    }
    
    @IBAction func connectButtonWasPressed(_ sender: Any) {
        self.grpcManager.connet(host: nil, port: nil) { (success) in
            print(#function, success)
        } chatStreamRespnse: { [weak self] (response) in
            print(#function, response)
            
            if let weakSelf = self {
                DispatchQueue.main.async {
                    weakSelf.changeStateButton()

                    if response.command == .chat {
                        weakSelf.tfMessage.text = ""
                        weakSelf.view.endEditing(true)
                    } else {

                    }
                }
            }
        } state: { (state) in
            print(#function, state)
        } error: { (error) in
            print(#function, error)
        }
    }
    
    @IBAction func disconnectButtonWasPressed(_ sender: Any) {
        self.grpcManager.disconnect()
        self.changeStateButton()
    }
    
    @IBAction func getRoomListButtonWasPressed(_ sender: Any) {
        self.grpcManager.getChatRoomList { [weak self] (response) in
            if let chatRooms: [Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom] = response?.chatRooms, chatRooms.count > 0 {
                if let selectChatRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom = chatRooms.first {
                    if let weakSelf = self {
                        DispatchQueue.main.async {
                            weakSelf.chatRoomID = selectChatRoom.id
                            weakSelf.btnCreate.isEnabled = true
                            weakSelf.btnJoin.isEnabled = true
                            
                            let alert = UIAlertController(title: "방 목록", message: "\(String(describing: response))", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: { action in
                                
                            }))
                            
                            weakSelf.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func createButtonWasPressed(_ sender: Any) {
        self.grpcManager.createChatRoom(createRoomID: "8728")
    }
    
    @IBAction func joinButtonWasPressed(_ sender: Any) {
//        self.grpcManager.joinChatRoom(chatRoom: self.chatRoom, userID: "2", userName: "레이니2")
        self.grpcManager.joinChatRoom(chatRoomID: self.chatRoomID ?? "", userID: "1", userName: "레이니")
    }
    
    @IBAction func leaveButtonWasPressed(_ sender: Any) {
        self.grpcManager.leaveChatRoom()
        self.changeStateButton()
    }
    
    @IBAction func sendButtonWasPressed(_ sender: Any) {
        if let text: String = self.tfMessage.text {
            if text.count > 0 {
                self.grpcManager.sendMessageToChatRoom(message: text)
            }
        }
    }
}

