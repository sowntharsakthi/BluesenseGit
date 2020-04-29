//
//  BTdata.swift
//  BluesenseFramework
//
//  Created by Mahindra on 17/04/20.
//  Copyright © 2020 Mahindra. All rights reserved.
//

import UIKit
//import MBSLibrary

class BTdata: NSObject {
    static let sharedInstanceVar: BTdata? = {
        var sharedInstance = BTdata()
        return sharedInstance
    }()
    var wIdooropen: UInt8?
    var  uTemp: Int?
   // var storage = ClassStorage()
    
    var lwSautowiper: String?
    var lwSautolamp: String?
    var lwSparklamp: String?
    var lwShvac: String?

    var cCac :  Int?
    var cCecon :  Int?
    var cCblowerspeed :  Int?
    var cCtemp: String?
    var drivetemp: String?
    var cCaircirculation :  Int?
    var cChvac :  Int?
    var cCauto :  Int?
    var cCvent :  Int?
    var cCrearac :  Int?
    var cCdual :  Int?

    
    //source information

    var sIiPod :  Int?
    var sIusb :  Int?
    var sIaux :  Int?
    var sIbt :  Int?
    var sItuner :  Int?
    //startup info
    var stIcontrol :  Int?
    var stIsource :  Int?
    var stIvolume :  Int?
    var sSunitval : Int?
    var dual : Int?
    var mdItitle: String?
    var siLstationlist: [AnyHashable]?

    
    
    // Bool
    
    var isDeviceConnected : Bool = false
    var  acPayload: Bool = false
    var conflag : Int?
    
    var rbItype : Int?
    var rbIname: String?
    var rbInumber : Int?
    func getBitByPosition(_ value: UInt8, _ position: Int) -> UInt8 {
        return UInt8((Int(value) >> position) & 1)
    }
  
}
