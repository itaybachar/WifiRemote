//
//  UDPClient.swift
//  WifiRemote
//
//  Created by Chang Yaramothu on 12/15/21.
//

import Foundation
import Network

class UDPClient {
    
    var socket: NWConnection?
    var connectionFailedCallback: (()-> Void)? = nil
    
    public init(host: String, port: Int)
    {
        /*
        guard let codedAddress = IPv4Address(host),
                    let codedPort = NWEndpoint.Port(rawValue: NWEndpoint.Port.RawValue(port)) else {
                        print("Failed to create connection address")
                        //return
                }
         */
        let codedPort = NWEndpoint.Port(rawValue: NWEndpoint.Port.RawValue(port))
        
        //Try to connect
        //let hostUDP: NWEndpoint.Host = .ipv4(codedAddress)
        let hostUDP = NWEndpoint.Host(host)
        let portUDP: NWEndpoint.Port = codedPort!
        self.socket = NWConnection(host: hostUDP, port: portUDP, using: .udp)
        
        self.socket!.stateUpdateHandler = { (newState) in
             switch (newState) {
                 case .ready:
                    print("State: Ready\n")
                    return
             case .preparing:
                 print("Prep")
                 return
             case .setup:
                 print("setup")
                 return
             case .cancelled:
                 print("Canceled")
                 return
             case .waiting:
                 print("waiting")
                 return
             case .failed:
                 print("Failed")
                
                 guard let callback = self.connectionFailedCallback else {
                     return
                 }
                 callback()
                    
                 return
             default:
                 print("State: Not Ready\n")
             }
        }
    }
    
    func isReady() -> Bool{
        return socket?.state == .ready
    }

    func connect() -> Int
    {
        if self.socket == nil{
            return 1
        }
        
        self.socket!.start(queue: .global())
        
        var timeout = false
        //Wait for socket to be ready
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
           // Excecute after 3 seconds
            print("Timed Out")
            timeout = true
        }
        
        while(socket!.state != .ready)
        {
            if timeout{
                return 1
            }
        }

        return 0
    }
    
    func sendUDP(_ msg: String)
    {
        socket!.send(content: msg.data(using: .utf8), completion: .contentProcessed({ sendError in
            if let error = sendError {
                NSLog("Unable to process and send the data: \(error)")
            }}))
    }
}
