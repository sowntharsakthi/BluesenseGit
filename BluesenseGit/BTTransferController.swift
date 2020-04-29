//
//  BTTransferController.swift
//  BluesenseFramework
//
//  Created by Mahindra on 17/04/20.
//  Copyright © 2020 Mahindra. All rights reserved.
//



class BTTransferController: NSObject {
    let PACKET_HEADER_LENGTH = 3
    static let sharedInstanceVar: BTTransferController? = {
           var sharedInstance = BTTransferController()
           return sharedInstance
       }()
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDataReceived), name: NSNotification.Name(rawValue: EADSessionDataReceivedNotification), object: nil)
       // EADSessionController().openSession()
        EADSessionController().closeSession()
       
        

    }
    
     func sendCMD(_ CMD: [UInt8], length: Int) {
            print("entered SendCmd")
            //var CMD: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00]
            print(CMD)
            let dt = Data(bytes: CMD, count: MemoryLayout.size(ofValue: CMD))
            print("data",dt)
            let dt1 = calcEDD(UInt8(dt.count), cmd: dt)
            print("dt1",dt1 as Any)
                if let dt1 = dt1 {
                    print("CMD data \(dt1)")
                }
            print("CMD hex \(NSData(data: dt1!))")
                if let dt1 = dt1
                {
                    EADSessionController().writeData(data: dt1)
                }
            }
    
    
        func calcEDD(_ i: UInt8, cmd: Data?) -> Data? {
                let cmdByte = malloc(Int(i))
                print("dfdgf",cmd as Any)
                var cmdarray = withUnsafeBytes(of: cmd, Array.init)
                print("Array",cmdarray)
                memcpy(cmdByte,[cmdarray], Int(i))
                print("cmd",cmdByte as Any)
                var allData = Data()
                var result: UInt8 = 0
                var nIndex = 0
                while nIndex < Int(i)
                {
                    let one:UInt8 = (UInt8(cmdarray[nIndex]) << 4 | UInt8(cmdarray[nIndex + 1] ))
                    result = UInt8(result) + one
                    nIndex = nIndex + 2
                }
                print("result",result)
                cmdarray[2] = UInt8((Int(result) & 0xf0) >> 0x04)
                print("cmdarra2",cmdarray[2])
                cmdarray[3] = UInt8(Int(result) & 0x0f)
                print("cmdarra3",cmdarray[3])

                for g in 0..<Int(i) {
                    allData.append(&cmdarray[g], count: MemoryLayout.size(ofValue: cmdarray[g]))
                    print("ggfg",allData)
                }

                let resultData : NSData =  Data(allData) as NSData
                return resultData as Data
        }
        
    func hextodec(_ hexVal: Int) -> String?
    {
        let hexString = "\(hexVal)"
        let dec = UnsafeMutablePointer<UInt32>.allocate(capacity: 32)

        let scan = Scanner(string: hexString)
        if scan.scanHexInt32(dec){
            print("Dec value, \(dec) is sccessfully scanned.")
        } else {
            print("No dec value is scanned.")
        }

        return "\(dec)"
    }
    
    func receivedByteParser(_ i: UInt8, data cmd: Data?) -> Data? {
        let cmdByte = malloc(Int(i))
        print("dfdgf",cmd as Any)
        let cmdarray = withUnsafeBytes(of: cmd, Array.init)
        print("Array",cmdarray)
        memcpy(cmdByte,[cmdarray], Int(i))
        print("cmd",cmdByte as Any)

//        if ExpressibleByIntegerLiteral(integerLiteral: cmdarray[0] ?? 0) == 0x52 && ExpressibleByIntegerLiteral(integerLiteral: cmdarray[1] ?? 0) == 0x5a {
//            print("\(String(describing: cmd))")
//        }

        var allData = Data()

        let dataLen = (Int(cmdarray[4] ) - 0x50) << 4 | (Int(cmdarray[5]) - 0x50)

        print("datalenth: \(dataLen) value of i:\(i) cmd data lenght:\(cmd!.count)")
        //NSLog(@"Response data length :%d , Original data lenght:%d",i,[cmd length]);

        if i != 0 {
            for nIndex in 0..<dataLen + PACKET_HEADER_LENGTH {
                let test1: UInt8 = UInt8((Int(cmdarray[nIndex * 2] ) & 0x0f) << 4)
                let test2 :UInt8 = (UInt8(Int(cmdarray[(nIndex * 2) + 1] ) & 0x0f))
                var test = test1 | test2
                
                allData.append(&test, count: MemoryLayout.size(ofValue: test))
            }
        } else {
            var dummyval: UInt8 = 0x5a
            allData.append(&dummyval, count: MemoryLayout.size(ofValue: dummyval))
        }

        return allData as Data
       // return nil
    }
    
    func datatoascii(_ _data: Data?) -> String? {
        var _string = ""
        for i in 0..<(_data?.count ?? 0) {
            let byte = UnsafeMutablePointer<UInt8>.allocate(capacity: 8)
            _data?.copyBytes(to: byte, count: i)
           

            _string += "\(byte)"

            //                    if (_byte >= 32 && _byte < 127) {
            //                        [_string appendFormat:@"%c", _byte];
            //                    } else {
            //                       // [_string appendFormat:@"[%d]", _byte];
            //                    }
        }
        var ascii: String? = nil
        if let _data = _data {
            ascii = String(data: _data, encoding: .ascii)
        }
        print("data to ascii: \(ascii ?? "")")
        print("data to string: \(_string)")
        _string = "\(_string)"
        return _string
    }
    
    @objc public  func sessionDataReceived(_ notification: Notification?) {
        print("called1")
    

        NotificationCenter.default.post(name: NSNotification.Name("watchStateChange"), object: self)
        let sessionController = EADSessionController()
        //var sessionController = notification.object() as? EADSessionController
        let bytesAvailable: UInt32 = 0
        let data = sessionController.readData(bytesToRead: Int(bytesAvailable))

        let receivedByteData = receivedByteParser(UInt8(data.count), data: data)
         if let receivedByteData = receivedByteData {
            print("----Parsed bytes in BTClass: \(receivedByteData)")
        }

       // let bytePtr = receivedByteData?.withUnsafeBytes(of :data , Array.init)
        //print("Bytes Receieved:  \(bytePtr)
        //var bytePtr = [Int8]()
//        let len = receivedByteData?.count ?? 0
//        let byteData1 = malloc(len) as? UInt8
//       // memcpy(byteData1, receivedByteData?.bytes, len)
//       // free(byteData1)
//        var n = bytePtr[60]
//        var buffer = [Int8](repeating: 0, count: 9)
//        buffer[8] = 0 //for null
//        var j = 8
//        while j > 0 {
//            if n & 0x01 != 0 {
//                j -= 1
//                buffer[j] = ("1" as? Int8)!
//            } else {
//                j -= 1
//                buffer[j] = ("0" as? Int8)!
//            }
//            n >>= 1
//        }
//        // bit to int convertion
////        let acc = Int(buffer[0] = ("0" as? Int8)!)
////        print(String(format: "Violation acc: %i", acc))
////        let braking = Int(buffer[1] = "0")
////        print(String(format: "Violation brake: %i", braking))
////        let clutch = Int(buffer[2] ="0")
////        print(String(format: "Violation clutch: %i", clutch))
////        let idling = Int(buffer[3] = "0")
////        print(String(format: "Violation idiling: %i", idling))
////        let gearViolation = Int(buffer[4] = "0")
////        print(String(format: "Violation gear: %i", gearViolation))
////        let overSpeed = Int(buffer[5] ="0")
////        print(String(format: "Violation overspeed: %i", overSpeed))
////        print("\nBTTransfer: \(bytePtr[0])")
//
//        switch bytePtr[0] {
//            case 0x00:
//                break
//                    //Connection/Disconnection
//            case 0x01:
//                    //Polling
//                    print("\n sessionDataReceived: Polling data Receieved\n")
//                    if bytePtr[3] == 0 {
//                        let CMD : [UInt8] = [0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00]
//                        sendCMD(CMD, length: MemoryLayout.size(ofValue: CMD))
//                    }
//                    break
//            case 0x02:
//            //Acknowledgment
//                print("\n sessionDataReceived: ACK data Receieved\n")
//                var val : Int = Int(bytePtr[3])
//                print("val",val)
//                if val == 0 {
//
//
//                }
//                break
//            case 0x03:
//                        break
//                //Request
//
//            case 0x04:
//                        break
//                //Reserved
//            case 0x05:
//            //vechile Configuration
//            break
//            case 0x06:
//            //Reserved
//            break
//        case 0x07:
//            //Ignition information
//            break
//        case 0x08:
//            //Tiretronics Information
//            break
//        case 0x09:
//            //Climate Information
//            print("\n sessionDataReceived: Climate data Receieved\n")
//            BTdata().acPayload = true
//            BTdata().cCac = Int(bytePtr[4])
//            BTdata().cCecon = Int(bytePtr[6])
//            BTdata().cCblowerspeed = Int(bytePtr[8])
//            BTdata().cCaircirculation = Int(bytePtr[15])
//            BTdata().cChvac = Int(bytePtr[17])
//            BTdata().cCauto = Int(bytePtr[19])
//            BTdata().cCvent = Int(bytePtr[21])
//            BTdata().cCrearac = Int(bytePtr[23])
//            //                [[AppDelegateFile mainApplicationInstance] setCCdual:bytePtr[30]];
//            BTdata().dual = Int(bytePtr[30])
//            BTdata().cCtemp = "\(bytePtr[11]).\(bytePtr[13])"
//            //   NSLog(@"cctemp%d",[[AppDelegateFile mainApplicationInstance] setCCtemp])
//            BTdata().drivetemp = "\(bytePtr[26]).\(bytePtr[28])"
//            //Send Update to Watch
//            var msgDict: [AnyHashable : Any] = [:]
//            msgDict["MESSAGE_TYPE"] = NSNumber(value: MESSAGE_TYPES.type_CLIMATE_CONTROL.rawValue )
//            //msgDict["MESSAGE"] = BTSharedData.getClimateInfo()
//
//            NotificationCenter.default.post(name: NSNotification.Name("Climate"), object: "Climate")
//            break
//        case 0x0A:
//            //Fuel Information
//            break
//        case 0x0B:
//            //MBFM Information
//            break
//            case 0x0C:
//            // Reserved
//            break
//            case 0x0D:
//            // Reserved
//            break
//            case 0x0E:
//            // Reserved
//            break
//            case 0x0F:
//            // Reserved
//            break
//            case 0x10:
//            // Reserved
//            break
//            case 0x11:
//            // //Common Control
//            break
//            case 0x12:
//            // Current Source Control
//            break
//            case 0x13:
//            // //Source Information
//                BTdata().sIiPod = bytePtr[4]
//                BTdata().sIusb = bytePtr[6]
//                 BTdata().sIaux = bytePtr[8]
//                 BTdata().sIbt = bytePtr[10]
//                 BTdata().sItuner = bytePtr[12]
//                let usb2 = NSNumber(value: bytePtr[16])
//                let sdCard = NSNumber(value: bytePtr[18])
//                let source6 = bytePtr[14]
//                UserDefaults.standard.setValue(NSNumber(value: source6), forKey: "sourceCD")
//
//                let iPod2 = NSNumber(value: bytePtr[20])
//                //                NSNumber *ipod2 = [NSNumber numberWithInt:bytePtr[20]];
//                UserDefaults.standard.set(usb2, forKey: "usb2")
//                UserDefaults.standard.set(sdCard, forKey: "sdCard")
//                UserDefaults.standard.set(iPod2, forKey: "iPod2")
//                var msgDict: [AnyHashable : Any] = [:]
//                msgDict["MESSAGE_TYPE"] = NSNumber(value: MESSAGE_TYPES.type_SOURCE_CONTROL_DATA.rawValue)
//                msgDict["MESSAGE"] = BTSharedData().getSourceControlData()
//                print("AudioWorks: Source Information: \(msgDict)")
//                NotificationCenter.default.post(name: NSNotification.Name("AudioScreen"), object: "AudioScreen")
//            break
//            case 0x14:
//            // //Startup Information
//                BTdata().stIcontrol = bytePtr[4]
//                BTdata().stIsource = bytePtr[6]
//                BTdata().stIvolume = bytePtr[8]
//                print("AudioWorks: Source: \(BTdata().stIsource)")
//                print("AudioWorks: Control: \(BTdata().stIcontrol)")
//                print("AudioWorks: Volume: \(BTdata().stIvolume)")
//                var msgDict: [AnyHashable : Any] = [:]
//                msgDict["MESSAGE_TYPE"] = NSNumber(value: MESSAGE_TYPES.type_SOURCE_CONTROL_DATA.rawValue)
//                msgDict["MESSAGE"] = BTSharedData().getAudioControlData()
//                NotificationCenter.default.post(name: NSNotification.Name("AudioScreen"), object: "AudioScreen")
//            break
//            case 0x15:
//                       // Volume Control
//                       break
//            case 0x16:
//                       // Reserved
//                       break
//            case 0x17:
//            // //Metadata Information
//                var allData : NSMutableData = Data() as! NSMutableData
//
//                for i in 3..<len {
//                    allData.append(UnsafeRawPointer(Int8(&bytePtr[i])), length: MemoryLayout.size(ofValue: bytePtr[i]))
//                }
//
//                let _data : NSData = Data(referencing: allData) as! NSData
//                BTdata().mdItitle = datatoascii(_data as Data)
//                //Send Update to Watch
//                var msgDict: [AnyHashable : Any] = [:]
//                msgDict["MESSAGE_TYPE"] = NSNumber(value: MESSAGE_TYPES.type_AUDIO_META_DATA.rawValue)
//                msgDict["MESSAGE"] = BTdata().mdItitle
//                NotificationCenter.default.post(name: NSNotification.Name("AudioScreen"), object: "AudioScreen")
//            break
//            case 0x18:
//            // //Radio Band Information
//               print("\n sessionDataReceived: Radio Band data Receieved\n")
//               var allData : NSMutableData = Data() as! NSMutableData
//
//                for i in 0..<len {
//                    if i > 6 && i < 17 {
//                        allData.append(UnsafeRawPointer(Int8(&bytePtr[i])), length: MemoryLayout.size(ofValue: bytePtr[i]))
//                    }
//                }
//
//               let _data : NSData = Data(referencing: allData) as! NSData
//
//                BTdata().rbItype = bytePtr[4]
//               BTdata().rbIname = datatoascii(_data as Data)
//                BTdata().rbInumber = bytePtr[16]
//                //Send Update to Watch
//                var msgDict: [AnyHashable : Any] = [:]
//               msgDict["MESSAGE_TYPE"] = NSNumber(value: MESSAGE_TYPES.type_AUDIO_BAND_INFO.rawValue)
//                msgDict["MESSAGE"] = BTSharedData().getRadioBandInfo()
//                NotificationCenter.default.post(name: NSNotification.Name("AudioScreen"), object: "AudioScreen")
//
//
//            break
//            case 0x19:
//            // Preset Station control
//            break
//        case 0x1A:
//            // Current Band Control
//            break
//            case 0x1B:
//            // Reserved
//            break
//            case 0x1C:
//            // RDS Information
//            break
//        case 0x1D:
//            // Station Info
//          print("\n sessionDataReceived: Station Info data Receieved\n")
//            var station1 = Data()
//            var station2 = Data()
//            var station3 = Data()
//            var station4 = Data()
//            var station5 = Data()
//            var station6 = Data()
//
//            for i in 0..<len {
//                if i > 3 && i < 13 {
//                    //station1.append(UnsafeRawPointer(Int8(&bytePtr[i])), count: MemoryLayout.size(ofValue: bytePtr[i]))
//                    station1.append(&UInt8(bytePtr[i]), count: MemoryLayout.size(ofValue: bytePtr[i]))
//                } else if i > 13 && i < 23 {
//                    station2.append(UnsafeRawPointer(Int8(&bytePtr[i])), count: MemoryLayout.size(ofValue: bytePtr[i]))
//                } else if i > 23 && i < 33 {
//                    station3.append(UnsafeRawPointer(Int8(&bytePtr[i])), count: MemoryLayout.size(ofValue: bytePtr[i]))
//                } else if i > 33 && i < 43 {
//                    station4.append(UnsafeRawPointer(Int8(&bytePtr[i])), count: MemoryLayout.size(ofValue: bytePtr[i]))
//                } else if i > 43 && i < 53 {
//                    station5.append(UnsafeRawPointer(Int8(&bytePtr[i])), count: MemoryLayout.size(ofValue: bytePtr[i]))
//                }
//                else if i > 53 && i < 63 {
//                    station6.append(UnsafeRawPointer(Int8(&bytePtr[i])), count: MemoryLayout.size(ofValue: bytePtr[i]))
//                }
//          }
//          var stationlist: [AnyHashable] = []
//          stationlist.append(datatoascii(station1))
//          stationlist.append(datatoascii(station2))
//          stationlist.append(datatoascii(station3))
//          stationlist.append(datatoascii(station4))
//          stationlist.append(datatoascii(station5))
//          stationlist.append(datatoascii(station6))
//          BTdata().siLstationlist = stationlist
//          NotificationCenter.default.post(name: NSNotification.Name("AudioScreen"), object: "AudioScreen")
//
//
//            break
//            case 0x1E:
//            // Current Band Data Control
//            break
//            case 0x1F:
//            // Settings Information
//            break
//            case 0x20:
//            // Reserved
//            break
//            case 0x21:
//            // Settings Control
//            break
//            case 0x22:
//                       // Settings Control
//                       break
//            case 0x23:
//                       // Settings Control
//                       break
//            case 0x24:
//                       // Settings Control
//                       break
//            case 0x25:
//                       // Settings Control
//                       break
//            case 0x26:
//                       // Settings Control
//                       break
//            case 0x27:
//                       // Settings Control
//                       break
//            case 0x28:
//                       // Settings Control
//                       break
//            case 0x29:
//                       // Settings Control
//                       break
//            case 0x2A:
//                       // Settings Control
//                       break
//            case 0x2B:
//                       // Settings Control
//                       break
//            case 0x2C:
//                       // Settings Control
//                       break
//            case 0x2D:
//                       // Settings Control
//                       break
//            case 0x2F:
//                       // Settings Control
//                       break
//            case 0x30:
//            // Settings Control
//            break
//            case 0x3C:
//            // Settings Control
//            break
//            case 0x37:
//                       // Settings Control
//                       break
//
//        }
//
//
//
    }

}
