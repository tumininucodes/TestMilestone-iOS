//
//  WebSocketService.swift
//  TestMilestone
//
//  Created by Oluwatumininu Ojo on 07.12.25.
//

import Foundation
import Combine

class WebSocketService {
    
    enum ConnectionState {
        case connected
        case disconnected
        case retrying
    }
    
    private let url = URL(string: "ws://websockeet.onrender.com/ws")!
    private var webSocketTask: URLSessionWebSocketTask?
    private let _bids = PassthroughSubject<Bid, Never>()
    @Published var connectionState: ConnectionState = .disconnected
    

    var bids: AnyPublisher<Bid, Never> {
        _bids.eraseToAnyPublisher()
    }
    
    private var receiveTask: Task<Void, Never>?
    
    func connect(onError: @escaping (Error?) -> Void) {
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        print("WebSocketService Connecting...")
        
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                print("WebSocketService Ping failed: \(error)")
            } else {
                print("WebSocketService Ping success, connected")
                DispatchQueue.main.async {
                    self?.connectionState = .connected
                }
            }
        }
        
        startReceiving(onError: onError)
    }
    
    func disconnect() {
        receiveTask?.cancel()
        webSocketTask?.cancel(with: .normalClosure, reason: "User disconnected".data(using: .utf8))
        webSocketTask = nil
        connectionState = .disconnected
    }
    
    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        Task {
            do {
                try await webSocketTask?.send(message)
            } catch {
                print("WebSocketService Error sending message: \(error)")
            }
        }
    }
    

    private func startReceiving(onError: @escaping (Error?) -> Void) {
        receiveTask = Task {
            while !Task.isCancelled {
                do {
                    guard let message = try await webSocketTask?.receive() else { break }
                    handleMessage(message)
                } catch {
                    if error is CancellationError || Task.isCancelled {
                        print("WebSocketService Task cancelled")
                        break
                    }
                    print("WebSocketService Error receiving message: \(error)")
                    onError(error)
                    scheduleRetry(onError: onError)
                    break
                }
            }
        }
    }
    
    private func scheduleRetry(onError: @escaping (Error?) -> Void) {
        print("WebSocketService Retrying connection instantly...")
        connectionState = .retrying
        connect(onError: onError)
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            print("WebSocketService Received message: \(text)")
            parseBid(from: text)
        case .data(_):
            break
        @unknown default:
            break
        }
    }
    
    private func parseBid(from text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            var bid = try JSONDecoder().decode(Bid.self, from: data)
            print("\(getUTCISO())")
            bid.timestamp = getUTCISO()
            _bids.send(bid)
        } catch {
            print("WebSocketService Error parsing message: \(error)")
        }
    }
}
