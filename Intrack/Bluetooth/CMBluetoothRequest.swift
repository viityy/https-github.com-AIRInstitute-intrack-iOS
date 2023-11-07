//
//  CMBluetoothRequest_SmartLamp.swift
//  SmartLamp_v2
//
//  Created by Carlos Martin de Arribas on 21/5/18.
//  Copyright © 2018 Carlos Martin de Arribas. All rights reserved.
//

import Foundation
import CoreBluetooth

class CMBluetoothRequest {
    class public func startMachine(heat: Int, temp1: Int, time1: Int, temp2: Int, time2: Int, step2: Bool, extra: Int = 5, completionHandler: @escaping ((_ errorCode: Int) -> Void)) {
        
        if (serialBT == nil) {
            completionHandler(-2)
            return
        }
    
        if !serialBT.isReady {
            completionHandler(-1) // Bluetooth no conectado
            debugPrint("No está conectado, animal de bellota")
            return
        }
    
        // envio el mensaje
        serialBT.sendMessageToDevice("msg")
        completionHandler(0)
    }
    
    class public func powerOffMachine(completionHandler: @escaping ((_ errorCode: Int) -> Void)) {
        if (serialBT == nil) {
            completionHandler(-2)
            return
        }
        
        if !serialBT.isReady {
            completionHandler(-1) // Bluetooth no conectado
            debugPrint("No está conectado, animal de bellota")
            return
        }
        
        var msg = "@0,,,,,,#"
        
        debugPrint(msg)
        
        
        // envio el mensaje
        serialBT.sendMessageToDevice(msg)
        completionHandler(0)
    }
    
    class public func getMachineIdentifier(completionHandler: @escaping ((_ code: String?) -> Void)) {
        guard serialBT != nil, serialBT.isReady else {
            completionHandler(nil)
            return
        }
        
        serialBT.sendMessageToDevice("M")
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("ReceiveMachineID"), object: nil, queue: nil) { (notification) in
            guard let machineID = notification.object as? String else {
                completionHandler(nil)
                return
            }
            
            completionHandler(machineID)
        }
    }
    
    class public func blockMachine(completionHandler: @escaping ((_ code: Bool) -> Void)) {
        guard serialBT != nil, serialBT.isReady else {
            completionHandler(false)
            return
        }
               
        serialBT.sendMessageToDevice("!")
        completionHandler(true)
    }
    
    class public func releaseMachine(completionHandler: @escaping ((_ code: Bool) -> Void)) {
        guard serialBT != nil, serialBT.isReady else {
            completionHandler(false)
            return
        }
                  
        serialBT.sendMessageToDevice("$")
        completionHandler(true)
    }
}
