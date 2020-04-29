//
//  BTSharedData.swift
//  BluesenseFramework
//
//  Created by Mahindra on 17/04/20.
//  Copyright © 2020 Mahindra. All rights reserved.
//

import UIKit

class BTSharedData: NSObject {
    static let sharedInstanceVar: BTSharedData? = {
        var sharedInstance = BTSharedData()
        return sharedInstance
    }()


   func sendWatchMessage(_ messageDict: inout [AnyHashable : Any]) {
    let messageDict = messageDict
        print("SENDING RESPONSE : \(messageDict)")
       // messageDict[BT_STATUS] = NSNumber(value: AppDelegateFile.mainApplicationInstance().conflag)

    }
func getDoorOpenInfo() -> [AnyHashable : Any]?
{
    let doorropenstatus = BTdata().wIdooropen
    var doorOpenDict: [AnyHashable : Any] = [:]
    var back = 0
    var hood = 0
    var frontLeft = 0
    var frontRight = 0
    var backLeft = 0
    var backRight = 0

    for i in 0..<7 {
        switch i {
            case 0 /*back */:
                if BTdata().getBitByPosition(doorropenstatus!, 0) == 1 {
                    back = 1
                }
            case 1 /*hood */:
                if BTdata().getBitByPosition(doorropenstatus!, 1) == 1 {
                    hood = 1
                }
            case 2 /*front left */:
                if BTdata().getBitByPosition(doorropenstatus!, 2) == 1 {
                           frontLeft = 1
                       }
            case 3 /*front right */:
                if BTdata().getBitByPosition(doorropenstatus!, 3) == 1 {
                           frontRight = 1
                       }
            case 4 /*rear left */:
                if BTdata().getBitByPosition(doorropenstatus!, 4) == 1 {
                           backLeft = 1
                       }
            case 5 /*rear right */:
                if BTdata().getBitByPosition(doorropenstatus!, 5) == 1 {
                           backRight = 1
                       }
                   default:
                       break
               }
    }
        
        doorOpenDict = [
        "BACK": NSNumber(value: back),
        "HOOD": NSNumber(value: hood),
        "FRONT_LEFT_DOOR": NSNumber(value: frontLeft),
        "FRONT_RIGHT_DOOR": NSNumber(value: frontRight),
       "BACK_LEFT_DOOR": NSNumber(value: backLeft),
        "BACK_RIGHT_DOOR": NSNumber(value: backRight)
        ]
        return doorOpenDict

    
    }   //getDoorOpenInfo


func getInnerTemp() -> String?
{
            //NSString
    let ccTemp: String =  (BTdata().cCtemp != nil) ? BTdata().cCtemp! : "0"

            let val = Float(ccTemp) ?? 0.0

            var strval = ""

            if BTdata().uTemp == 0 {
                strval = String(format: "%.1f°C", val)
                print(String(format: "DRiverTemp", strval))
            } else {
                strval = String(format: "%.1f°F", val)
            }
            print("TEMP{{}}}\(strval)")

            return strval
}//getInnerTemp
    
    
func getOuterTemp() -> String?
{
    let lwShvac: String = (BTdata().lwShvac != nil) ? BTdata().lwShvac! : "0"

        let val1 = Int(lwShvac) ?? 0

        var strval1 = ""

    if BTdata().uTemp == 0 {
            strval1 = "\(val1)°C"
        } else {
            strval1 = "\(val1)°F"
        }
        return strval1
    }//getOuterTemp
    
    
    
func getClimateInfo() -> [AnyHashable : Any]? {
        let climateDict = [
            "CLIMATE_AC": NSNumber(value: BTdata().cCac!),
            "CLIMATE_AC_AUTO": NSNumber(value: BTdata().cCauto!),
            "CLIMATE_AC_REAR": NSNumber(value: BTdata().cCrearac!),
            "CLIMATE_INNER_TEMP": getInnerTemp() as Any,
            "CLIMATE_OUTER_TEMP": getOuterTemp() as Any
            // CLIMATE_TEMP_UNIT:[NSNumber numberWithInt:[AppDelegateFile mainApplicationInstance].UTemp]
            ] as [String : Any]
        return climateDict
    }



    func getAudioControlData() -> [AnyHashable : Any]? {
        let audioControlData = [
            "AUDIO_VOLUME": NSNumber(value: BTdata().stIvolume!),
            "AUDIO_SOURCE": NSNumber(value: BTdata().stIsource!),
            "AUDIO_SOURCE_CONTROL": NSNumber(value: BTdata().stIcontrol!)
        ]
        return audioControlData
    }
    
    
    func getSourceControlData() -> [AnyHashable : Any]? {
        let sourceDataDict = [
            "SOURCE_IPOD": NSNumber(value: BTdata().sIiPod!),
            "SOURCE_USB": NSNumber(value: BTdata().sIusb!),
            "SOURCE_AUX": NSNumber(value: BTdata().sIaux!),
            "SOURCE_BT": NSNumber(value: BTdata().sIbt!),
            "SOURCE_TUNER": NSNumber(value: BTdata().sItuner!)
        ]
        return sourceDataDict
    }
    func getRadioBandInfo() -> [AnyHashable : Any]? {

        let rbiName : String = (BTdata().rbIname != nil) ? BTdata().rbIname! : ""
        let radioBandInfo = [
            "RBI_NAME": rbiName,
            "RBI_TYPE": NSNumber(value: BTdata().rbItype!),
            "RBI_NUMBER": NSNumber(value: BTdata().rbInumber!)
            ] as [String : Any]
        return radioBandInfo
    }
    


























}
