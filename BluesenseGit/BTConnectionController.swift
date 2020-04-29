//
//  BTConnectionController.swift
//  BluesenseFramework
//
//  Created by Mahindra on 19/04/20.
//  Copyright © 2020 Mahindra. All rights reserved.
//

import UIKit
import ExternalAccessory

public class BTConnectionController : NSObject{
    

      var accessoryList:                  [EAAccessory]?
    var accessoryManager: EAAccessoryManager?
      var selectedAccessory:              EAAccessory?
    var bluetoothEnabled:Bool = false


    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidConnect), name: Notification.Name.EAAccessoryDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidDisconnect), name: Notification.Name.EAAccessoryDidDisconnect, object: nil)
        EAAccessoryManager.shared().registerForLocalNotifications()
        //performSelector(onMainThread: #selector(startBluetoothStatusMonitoring), with: nil, waitUntilDone: true)
                btconnection()
        

    }
    
    public func btconnection(){
        print("bt called")
           let CMD : [UInt8] =  [0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00]
        BTTransferController().sendCMD(CMD, length: MemoryLayout.size(ofValue: CMD))    }
    
    public static func ConnectToInfotainment() -> Bool
    {
            var accessoryManager:               EAAccessoryManager?
            var selectedAccessory:              EAAccessory?
        
        
        accessoryManager = EAAccessoryManager.shared()
        if accessoryManager != nil
        {
            let connectedAccessories :NSArray = (accessoryManager?.connectedAccessories as? NSArray)!
                print("ConnectedAccessories = %@", connectedAccessories)
                print("\nConnectedAccessories: Connected Accessories Count: %lu\n",connectedAccessories.count)
                
                if connectedAccessories.count > 0
                {
                            let infoDict = Bundle.main.infoDictionary! as NSDictionary
                            let Strpro = infoDict.object(forKey: "UISupportedExternalAccessoryProtocols") as! NSArray
                            let strprotocol :NSString = Strpro[0] as! NSString
                            var protocolNamesTemp: [AnyHashable] = []
                            var protocolStringsTemp: [AnyHashable] = []
                            for i in 0..<connectedAccessories.count
                            {
                                selectedAccessory = connectedAccessories[i] as? EAAccessory
                                    if !((selectedAccessory?.name) != nil) || (selectedAccessory?.name == "")
                                    {
                                        protocolNamesTemp.insert("unknown", at: i)
                                        
                                    } else
                                    {
                                        protocolNamesTemp.insert(selectedAccessory?.name, at: i)
                                    }
                                protocolStringsTemp.insert(selectedAccessory?.name, at: i)
                            }
                            if !protocolNamesTemp.contains("unknown")
                            {
                                for i in 0..<connectedAccessories.count
                                {
                                
                                    selectedAccessory = (connectedAccessories[i] as! EAAccessory)
                                    var protocolStrings :NSArray = NSArray()
                                    protocolStrings = selectedAccessory?.protocolStrings as! NSArray
                                    for protocolstring in protocolStrings
                                    {
                                        print("\nConnectedAccessories: Connected Accessories Protocol: %s\n",protocolstring)
                                        if((protocolstring as AnyObject) as! String) == strprotocol as String
                                        {
                                            //connection code
                                            EADSessionController().setupController(forAccessory: selectedAccessory!, withProtocolString: (selectedAccessory?.protocolStrings[0])!)
                                            print("ConnectionStatus: Connected with pripheral");
                                            BTdata().isDeviceConnected = true
                                            UserDefaults.standard.set(true, forKey: "connectblue")
                                            
                                            
                                            
                                        } //if-end
                                        else{
                                          let alert = UIAlertController(title: "Connection failed:Infotainment not supported", message: nil, preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                        }
                                            
                                           // SessionController.sharedController
                                           
                                        }//for-end
                                    
                                    }//for-end
                                BTConnectionController().btconnection()
                                    return false
                                }//if-end
                    
                    }
                else{
                    print("called")
                   // BTTransferController.init()
                    
                    return false
            }
            }
        return true

        }
    func closeSession() -> Void
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.EAAccessoryDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:EADSessionDataReceivedNotification ), object: nil)
    }
     @objc func accessoryDidConnect(notificaton: NSNotification) {
           print("Connected Called")
           let connectedAccessory =        notificaton.userInfo![EAAccessoryKey]
           accessoryList?.append(connectedAccessory as! EAAccessory)
          
       }
       
       
       @objc func accessoryDidDisconnect(notification: NSNotification) {
        print("DisConnected called")
           
           let disconnectedAccessory =             notification.userInfo![EAAccessoryKey]
           var disconnectedAccessoryIndex =        0
           for accessory in accessoryList! {
               if (disconnectedAccessory as! EAAccessory).connectionID == accessory.connectionID {
                   break
               }
               disconnectedAccessoryIndex += 1
           }
           
           if disconnectedAccessoryIndex < (accessoryList?.count)! {
               accessoryList?.remove(at: disconnectedAccessoryIndex)
           } else {
               print("Could not find disconnected accessories in list")
           }
       }
}

