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
import Combine

@available(iOS 13.0, *)
class MyStuff: ObservableObject {
    private(set) var client: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private let delegate: Delegate = Delegate()
    @Published private(set) public var connectivity: ConnectivityState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ ip: String, port: Int) {
        let channel = ClientConnection
            .insecure(group: self.group)
            .withConnectionBackoff(maximum: .seconds(1))
            .withErrorDelegate(self.delegate)
            .withConnectivityStateDelegate(self.delegate)
            .connect(host: ip, port: port)

        self.client = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient(channel: channel)
        
        self.delegate.connectivity.sink(receiveValue: { newState in
            DispatchQueue.main.async {
                self.connectivity = newState
            }
        })
            .store(in: &self.cancellables)
    }
    
    deinit {
        self.cancellables.removeAll()
        do {
            try self.client.channel.close().wait()
            try self.group.syncShutdownGracefully()
        } catch {
            // don't deal with errors here
        }
    }
    
    class Delegate: ConnectivityStateDelegate, ClientErrorDelegate {
        var connectivity = CurrentValueSubject<ConnectivityState, Never>(.idle)
        
        func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState) {
            self.connectivity.value = newState
        }
        
        func didCatchError(_ error: Error, logger: Logger, file: StaticString, line: Int) {
            print(error)
            print(file)
            print(line)
        }
    }
}

class gRPCStuff: NSObject, ClientErrorDelegate, ConnectivityStateDelegate {
    typealias ChatStreamResponse = (Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse) -> Void
//    typealias CurrentState = (ConnectivityState) -> Void
    typealias Failure = (Error) -> Void
    typealias Success = (AnyObject) -> Void
    
    private var chatStreamResponseHandler: ChatStreamResponse?
//    private var currentStateHandler: CurrentState?
    private var errorHandler: Failure?
    private var successHandler: Success?
    
    private var clientRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient?
    private var clienStream: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol?
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var channel: ClientConnection?
    private var bidCall: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>?
    private(set) public var connectivity: ConnectivityState = .idle
    
    var host: String = "172.19.136.161"
    var portNumber: Int = 31105
    var chatRoomID: String?
    var request: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest()
    
    init(ip: String?, port: Int?, success: @escaping Success, chatStreamRespnse: @escaping ChatStreamResponse, error: @escaping Failure) {
        super.init()
        
        if let h: String = ip {
            self.host = h
        }
        
        if let p: Int = port {
            self.portNumber = p
        }
        
        self.successHandler = success
        self.chatStreamResponseHandler = chatStreamRespnse
        self.errorHandler = error
        
        self.initConnect()
    }
    
    deinit {
        self.disconnect(isDealError: false)
        self.commonInit()
    }
    
    func commonInit() {
        if self.channel != nil {
            self.channel = nil
        }
        
        if self.clientRoom != nil {
            self.clientRoom = nil
        }
        
        if self.clienStream != nil {
            self.clienStream = nil
        }
    }
    
    func initConnect() {
        self.commonInit()
        
        self.channel = ClientConnection
            .insecure(group: self.group)
            .withConnectionBackoff(initial: .seconds(1))
            .withConnectionBackoff(maximum: .seconds(60))
            .withConnectionBackoff(multiplier: 1)
            .withConnectionBackoff(jitter: 1)
            .withConnectionTimeout(minimum: TimeAmount.seconds(5))
            .withConnectionBackoff(retries: .upTo(5))
            .withErrorDelegate(self)
            .withConnectivityStateDelegate(self)
            .connect(host: self.host, port: self.portNumber)
        
        self.connect()
    }
    
    func connect() {
        if let ch: ClientConnection = self.channel {
            self.clientRoom = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient(channel: ch)
            self.clienStream = Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClient(channel: ch)
            self.getChatRoomList()
        }
    }
    
    func disconnect(isDealError: Bool = true) {
        do {
//            if let cr = self.clientRoom {
//                try cr.channel.close().wait()
//            }
//
//            if let cs = self.clienStream {
//                try cs.channel.close().wait()
//            }
  
            if let ch = self.channel {
                try ch.close().wait()
            }
            
            try self.group.syncShutdownGracefully()
        } catch let error {
            print("\(type(of: self)):", error.localizedDescription)
            
            if isDealError == true {
                // 에러처리
            }
        }
    }
    
    func checkConnectionState() {
        if let ch: ClientConnection = self.channel {
            if ch.connectivity.state == .transientFailure {
                self.initConnect()
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
//            if let fail: Failure = self.errorHandler {
//                fail(status)
//            }
            
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
    
    func getChatRoomList() {
        self.checkConnectionState()
        
        if let chatRoomServiceClient: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient = self.clientRoom {
            let request = Com_Ncsoft_Aiss_Chat_Paige_V1_GetAllChatRoomRequest()
            let call: UnaryCall = chatRoomServiceClient.getAll(request)
            let _ = call.response.always { (result) in
                switch result {
                case let .success(value):
                    print(#function, value)
                
                case let .failure(error):
                    print(#function, error)
                }
            }
            
            call.response.whenComplete { [weak self] (result) in
                switch result {
                case .success(let response):
                    print(#function, response)
                    if response.chatRooms.count > 0 {
                        if let selectChatRoom: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoom = response.chatRooms.first {
                            if let weakSelf = self {
                                weakSelf.chatRoomID = selectChatRoom.id
                            }
                        }
                    }
                case .failure(let error):
                    print("CALL FAILED WITH ERROR\n\(error)")
                    
                }
            }
            
            call.status.whenSuccess { (status) in
                print(#function, status)
            }

            call.status.whenFailure { (error) in
                print(#function, error)
            }
        }
    }
    
    func createChatRoom (createRoomID: String, createRoomTitle: String = "의 방") {
        self.checkConnectionState()
        
        var createChatRequest = Com_Ncsoft_Aiss_Chat_Paige_V1_CreateChatRoomRequest()
        
        createChatRequest.chatRoomID = createRoomID
        createChatRequest.chatRoomTitle = createRoomTitle
        
        if let client: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatRoomServiceClient = self.clientRoom {
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
    
    func makeStreamRPCCall() {
        if let client: Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamServiceClientProtocol = self.clienStream {
            self.bidCall = client.send(callOptions: nil, handler: { [weak self] (response) in
                print(response)
                
                if let weakSelf = self {
                    if let responseHandler: ChatStreamResponse = weakSelf.chatStreamResponseHandler {
                        responseHandler(response)
                    }
                }
            })
            
            if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.bidCall {
                let _ = call.status.always { (result) in
                    switch result {
                    case let .success(value):
                        print(#function, value)
                    
                    case let .failure(error):
                        print(#function, error)
                    }
                }
                
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
    
    func joinChatRoom(chatRoomID: String?, userID: String, userName: String) {
        self.checkConnectionState()
        self.chatRoomID = chatRoomID
        
        self.request.chatRoomID = self.chatRoomID ?? "8728"
        self.request.command = .join
        self.request.userID = userID
        self.request.userName = userName
        
        if self.bidCall == nil {
            self.makeStreamRPCCall()
        }
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse>
            = self.bidCall {
            call.sendMessage(self.request, compression: .deferToCallDefault, promise: .none)
        }
    }
    
    func leaveChatRoom() {
        self.checkConnectionState()
        self.request.command = .leave
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.bidCall {
            call.sendMessage(self.request, compression: .deferToCallDefault, promise: .none)
        }
    }
    
    func sendMessageToChatRoom(message: String) {
        self.checkConnectionState()
        self.request.command = .chat
        self.request.message = message
        
        if self.bidCall == nil {
            self.makeStreamRPCCall()
        }
        
        if let call: BidirectionalStreamingCall<Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamRequest, Com_Ncsoft_Aiss_Chat_Paige_V1_ChatStreamResponse> = self.bidCall {
            call.sendMessage(self.request, compression: .deferToCallDefault, promise: .none)
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
        
        self.connectivity = newState
    }
    
    func connectionStartedQuiescing() {
        print("connectionStartedQuiescing")
    }
    
}

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
