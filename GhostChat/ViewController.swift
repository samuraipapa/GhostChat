//
//  ViewController.swift
//  GhostChat
//
//  Created by GrownYoda on 4/23/15.
//  Copyright (c) 2015 yuryg. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {

    // Core Bluetooth Peripheral Stuff
    var myPeripheralManager: CBPeripheralManager?
    var dataToBeAdvertisedGolbal:[String:AnyObject!]?
    // ID of Peripheral
    var identifer = "My ID"
    // A newly generated UUID for Peripheral
    var uuid = NSUUID()
    
    
    //  CoreBluetooth Central Stuff
    var myCentralManager = CBCentralManager()
    var peripheralArray = [CBPeripheral]() // create now empty array.
    var fullPeripheralArray = [("UUIDString","RSSI", "Name", "Services1")]
    var myPeripheralDictionary:[String:(String, String, String, String)] = ["UUIDString":("UUIDString","RSSI", "Name","Services1")]
    var cleanAndSortedArray = [("UUIDString","RSSI", "Name","Services1")]
    
    
    
    //UI Stuff
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var myTextField: NSTextField!
    @IBOutlet weak var statusText: NSTextField!
    
    @IBAction func sendButtonPressed(sender: NSButton) {
        println( myTextField.stringValue )
        advertiseNewName(myTextField.stringValue)
    }
    
    @IBAction func goSilentButton(sender: NSButtonCell) {
        updateStatusText("Gone Silent")
        myPeripheralManager?.stopAdvertising()
        println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myTextField.stringValue = "I'm on Ghost Chat."
        nameField.stringValue = "Anon"
        putPeripheralManagerIntoMainQueue()
        
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    // Helper Functions
    
    func updateStatusText(passedString: String){
        statusText.stringValue = passedString + "\r" + statusText.stringValue
    }
    
    
    
    func putPeripheralManagerIntoMainQueue(){
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        
        if let manager = myPeripheralManager{
            manager.delegate = self
            
        }

        
    }
    
 
    
    //MARK  CBPeripheral
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        println("did update state!")
        // Stop Advertising
        peripheral.stopAdvertising()
        
        
        switch (peripheral.state) {
        case .PoweredOn:
            println(" Powered ON State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            
            println("We are ON!")
            
            // Prep Advertising Packet for Periperhal
            let manufacturerData = identifer.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            let theUUid = CBUUID(NSUUID: uuid)
            
            let nameString = nameField.stringValue
            let messageString = myTextField.stringValue
            let localNameChatString = "Ghost: \(messageString)"
            
            let dataToBeAdvertised:[String:AnyObject!] = [
                CBAdvertisementDataLocalNameKey: "\(localNameChatString)",
                CBAdvertisementDataManufacturerDataKey: "Hello Hello Hello Hello",
                CBAdvertisementDataServiceUUIDsKey: [theUUid],]
            
            dataToBeAdvertisedGolbal = dataToBeAdvertised
            // Start Advertising The Packet
            myPeripheralManager?.startAdvertising(dataToBeAdvertised)
            
            
            break
        case .PoweredOff:
            println(" Powered OFF State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            println("We are off!")
            
            break;
            
        case .Resetting:
            println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            
            break;
            
        case .Unauthorized:
            //
            println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            break;
            
        case .Unknown:
            //
            println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            break;
            
        case .Unsupported:
            //
            println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            break;
            
        default:
            println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            break;
        }
    
    
}
    func advertiseNewName(passedString: String ){
        
        // Stop Advertising
        myPeripheralManager?.stopAdvertising()
        
        // UI Stuff
        
        
        // Prep Advertising Packet for Periperhal
        let manufacturerData = identifer.dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: false)
        
        let theUUid = CBUUID(NSUUID: uuid)
        
        let nameString = nameField.stringValue
        
        let dataToBeAdvertised:[String:AnyObject!] = [
            CBAdvertisementDataLocalNameKey: "GC: \(nameString): \(passedString)",
            CBAdvertisementDataManufacturerDataKey: "Hello anufacturerDataKey",
            CBAdvertisementDataServiceUUIDsKey: [theUUid],]
        
        // Start Advertising The Packet
        myPeripheralManager?.startAdvertising(dataToBeAdvertised)
    }
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        //
        println(" State in DidStartAdvertising: " + "\(myPeripheralManager?.state.rawValue)"  )
        
        if error == nil {
            //            let myString = peripheral.isAdvertising
            println("Succesfully Advertising Data")
            updateStatusText("Succesfully Advertising Data")
            
        } else{
            println("Failed to Advertise Data.  Error = \(error)")
            updateStatusText("Failed to Advertise Data.  Error = \(error)")
        }
        
    }

    
    
    //MARK  CBCenteral 
    // Put CentralManager in the main queue
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        myCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
    
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        println("centralManagerDidUpdateState")
        
        /*
        typedef enum {
        CBCentralManagerStateUnknown  = 0,
        CBCentralManagerStateResetting ,
        CBCentralManagerStateUnsupported ,
        CBCentralManagerStateUnauthorized ,
        CBCentralManagerStatePoweredOff ,
        CBCentralManagerStatePoweredOn ,
        } CBCentralManagerState;
        */
        switch central.state{
        case .PoweredOn:
            updateStatusText("Central poweredOn")
            
            
        case .PoweredOff:
            updateStatusText("Central State PoweredOFF")
            
        case .Resetting:
            updateStatusText("Central State Resetting")
            
        case .Unauthorized:
            updateStatusText("Central State Unauthorized")
            
        case .Unknown:
            updateStatusText("Central State Unknown")
            
        case .Unsupported:
            updateStatusText("Central State Unsupported")
            
        default:
            updateStatusText("Central State None Of The Above")
            
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        // Refresh Entry or Make an New Entry into Dictionary
        let myUUIDString = peripheral.identifier.UUIDString
        let myRSSIString = String(RSSI.intValue)
        var myNameString = peripheral.name
        var myAdvertisedServices = peripheral.services
        
        //  var myServices1 = peripheral.services
        //  var serviceString = " service string "
        
        var myArray = advertisementData
        var advertString = "\(advertisementData)"
        
        updateStatusText("\r")
        updateStatusText("UUID: " + myUUIDString)
        updateStatusText("RSSI: " + myRSSIString)
        updateStatusText("Name:  \(myNameString)")
        updateStatusText("advertString: " + advertString)
        
        
        
        let myTuple = (myUUIDString, myRSSIString, "\(myNameString)", advertString )
        myPeripheralDictionary[myTuple.0] = myTuple
        
        // Clean Array
        fullPeripheralArray.removeAll(keepCapacity: false)
        
        // Tranfer Dictionary to Array
        for eachItem in myPeripheralDictionary{
            fullPeripheralArray.append(eachItem.1)
        }
        
        // Sort Array by RSSI
        //from http://www.andrewcbancroft.com/2014/08/16/sort-yourself-out-sorting-an-array-in-swift/
        cleanAndSortedArray = sorted(fullPeripheralArray,{
            (str1: (String,String,String,String) , str2: (String,String,String,String) ) -> Bool in
            return str1.1.toInt() > str2.1.toInt()
        })
     //   tableView.reloadData()
    }
    
}