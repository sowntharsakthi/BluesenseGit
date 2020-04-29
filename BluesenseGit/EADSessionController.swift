//
//  EADSessionController.swift
//  BluesenseFramework
//
//  Created by Mahindra on 17/04/20.
//  Copyright © 2020 Mahindra. All rights reserved.
//

import UIKit
import ExternalAccessory
let EADSessionDataReceivedNotification = "EADSessionDataReceivedNotification"


class EADSessionController: NSObject,EAAccessoryDelegate, StreamDelegate {
    static let sharedController = EADSessionController()
    var _accessory: EAAccessory!
        var _session: EASession!
        var _protocolString: String!
        var _writeData: NSMutableData!
        var _readData: NSMutableData!
        var _dataAsString: String!
        var _dataAsHexString: String!
        
        // MARK: Controller Setup
        
        func setupController(forAccessory accessory: EAAccessory, withProtocolString protocolString: String) {
            _accessory = accessory
            _protocolString = protocolString
        }
        
        // MARK: Opening & Closing Sessions
        
        func openSession() -> Bool {
            print("open session called")
            _accessory?.delegate = self
            _session? = EASession(accessory: _accessory!, forProtocol: _protocolString!)!
            
            if _session != nil {
                _session?.inputStream?.delegate = self
                _session?.inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
                _session?.inputStream?.open()
                
                _session?.outputStream?.delegate = self
                _session?.outputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
                _session?.outputStream?.open()
            } else {
                print("Failed to create session")
            }
            
            return _session != nil
        }
        
        func closeSession() {
            
            _session?.inputStream?.close()
            _session?.inputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            _session?.inputStream?.delegate = nil
            
            _session?.outputStream?.close()
            _session?.outputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            _session?.outputStream?.delegate = nil
            
            _session = nil
            _writeData = nil
            _readData = nil
        }
        
        // MARK: Write & Read Data
        
        func writeData(data: Data) {
            if _writeData == nil {
                _writeData = NSMutableData()
            }
            
            _writeData?.append(data)
            self.writeData()
        }
        
        func readData(bytesToRead: Int) -> Data {
            
            var data: Data?
            if (_readData?.length)! >= bytesToRead {
                let range = NSMakeRange(0, bytesToRead)
                data = _readData?.subdata(with: range)
                _readData?.replaceBytes(in: range, withBytes: nil, length: 0)
            }
            
            return data!
        }
        
        func readBytesAvailable() -> Int {
            return (_readData?.length)!
        }
        
        // MARK: - Helpers
        func updateReadData() {
            let bufferSize = 128
            var buffer = [UInt8](repeating: 0, count: bufferSize)
            
            while _session?.inputStream?.hasBytesAvailable == true {
                let bytesRead = _session?.inputStream?.read(&buffer, maxLength: bufferSize)
                if _readData == nil {
                    _readData = NSMutableData()
                }
                _readData?.append(buffer, length: bytesRead!)
                DispatchQueue.main.async(execute:{
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BESessionDataReceivedNotification"), object: nil)
                }
                )
               
            }
        }
        
        private func writeData() {
            print("length",_writeData.length as Any)
            print(String(format: "write data length %lu",(_writeData!.length)))
            if _writeData?.length == 10 {
                print("_write data if part 10 ")
                var byteCount = 0
                while ((_session?.outputStream?.hasSpaceAvailable) == true) && (_writeData!.length > 7) && (byteCount < 10) {
                    //while ([[_session outputStream] hasSpaceAvailable])
                    var buffer = [UInt8](repeating: 0, count: _writeData!.length)
                     _writeData?.getBytes(&buffer, length: (_writeData?.length)!)
                     let bytesWritten = _session?.outputStream?.write(&buffer, maxLength: _writeData!.length - byteCount)
                    if bytesWritten == -1 {
                        print("write error")
                        break
                    } else if bytesWritten! > 0 {
                        print("data: \(String(describing: _writeData))")
                        byteCount += bytesWritten!
                        if _writeData!.length > 0 {
                            _writeData?.replaceBytes(in: NSRange(location: 0, length: bytesWritten!), withBytes: nil, length: 0)
                        }
                    }
                }
            }
            else if _writeData?.length == 14 {
                 print("_write data if part 10 ")
                               var byteCount = 0
                while ((_session?.outputStream?.hasSpaceAvailable) == true) && (_writeData!.length > 7) && (byteCount < 10) {
                                   //while ([[_session outputStream] hasSpaceAvailable])
                                   var buffer = [UInt8](repeating: 0, count: _writeData!.length)
                                    _writeData?.getBytes(&buffer, length: (_writeData?.length)!)
                                    let bytesWritten = _session?.outputStream?.write(&buffer, maxLength: _writeData!.length - byteCount)
                                   if bytesWritten == -1 {
                                       print("write error")
                                       break
                                   } else if bytesWritten! > 0 {
                                    print("data: \(String(describing: _writeData))")
                                       byteCount += bytesWritten!
                                       if _writeData!.length > 0 {
                                        _writeData?.replaceBytes(in: NSRange(location: 0, length: bytesWritten!), withBytes: nil, length: 0)
                                       }
                                   }
                               }
            }

            else if _writeData?.length == 18 {
            print("_write data if else part 18")
            var byteCount = 0
                while ((_session?.outputStream?.hasSpaceAvailable) == true) && (_writeData!.length > 7) && (byteCount < 18) {
                //while ([[_session outputStream] hasSpaceAvailable])
                var buffer = [UInt8](repeating: 0, count: _writeData!.length)
                _writeData?.getBytes(&buffer, length: (_writeData?.length)!)
                let bytesWritten = _session?.outputStream?.write(&buffer, maxLength: _writeData!.length - byteCount)
                if bytesWritten == -1 {
                    print("write error")
                    break
                } else if bytesWritten! > 0 {
                    // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
                    

                    print("data: \(String(describing: _writeData))")
                    byteCount += bytesWritten!
                    if _writeData!.length > 0 {
                        _writeData!.replaceBytes(in: NSRange(location: 0, length: bytesWritten!), withBytes: nil, length: 0)
                        }
                        
                        }
                }
            }
                        else{
                print("_write data else part else")
                var byteCount = 0
                while (((_session?.outputStream?.hasSpaceAvailable) == true) && (_writeData?.length ?? 0 > 7) && (byteCount < 8)) {
                   var buffer = [UInt8](_writeData! as Data)
                    let bytesWritten = _session?.outputStream?.write(&buffer, maxLength: _writeData.length)
                    print("bytesWritten",bytesWritten as Any)
                    if bytesWritten == -1 {
                        print("write error")
                        break
                    } else if bytesWritten ?? 0 > 0
                    {
                        // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
                        print("data: \(String(describing: _writeData))")
                        byteCount += bytesWritten!
                        if _writeData!.length > 0
                        {
                            _writeData!.replaceBytes(in: NSRange(location: 0, length: bytesWritten!), withBytes: nil, length: 0)
                        }
                
                    }
                }
            }
            
        }
        
        // MARK: - EAAcessoryDelegate
        
        func accessoryDidDisconnect(_ accessory: EAAccessory) {
            print("accessoryDidDisconnect --- EADSessionController")
            closeSession()
                        // Accessory diconnected from iOS, updating accordingly
        }
        
        // MARK: - NSStreamDelegateEventExtensions
        
        func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
            switch eventCode {
            case Stream.Event.openCompleted:
                break
            case Stream.Event.hasBytesAvailable:
                // Read Data
                updateReadData()
                break
            case Stream.Event.hasSpaceAvailable:
                // Write Data
                self.writeData()
                break
            case Stream.Event.errorOccurred:
                break
            case Stream.Event.endEncountered:
                break
                
            default:
                break
            }
        }
}
