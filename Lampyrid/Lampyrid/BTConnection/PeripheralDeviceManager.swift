//
//  PeripheralDeviceScanner.swift
//  Lampyrid
//
//  Created by Alex on 9/30/24.
//

import Foundation
import CoreBluetooth
import UIKit

enum PeripheralDeviceManagerState {
    case noDevice
    case hasDevice(String)
}

enum PeripheralDeviceManagerStateType {
    case initial
    case startScan
    case scanning(Int)
    case stopScan(PeripheralDeviceManagerState)
}

protocol PeripheralDeviceManagerDelegate: AnyObject {
    func peripheralDeviceScannerDidChangeState(_ scanner: PeripheralDeviceManager, currentStateType: PeripheralDeviceManagerStateType)
}

class PeripheralDeviceManager: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    private static let ledLampServiceUUID = CBUUID(string: "FFE0")
    private static let ledLampServiceCharacteristicUUID = CBUUID(string: "FFE2")
    private static let deviceName = "JDY08"
    
    weak var delegate: PeripheralDeviceManagerDelegate?
    
    private let internalQ = DispatchQueue(label: "PeripheralDeviceManagerQueue")
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var timer: Timer? = nil
    
    private var state: PeripheralDeviceManagerStateType = .initial {
        didSet {
            internalQ.async { [weak self] in
                guard let s = self else {
                    return
                }
                
                s.delegate?.peripheralDeviceScannerDidChangeState(s, currentStateType: s.state)
            }
        }
    }
    
    func scan() {
        internalQ.async { [weak self] in
            
            guard let s = self else {
                return
            }
            
            s.createTimer()
            
            s.centralManager?.stopScan()
            s.peripherals = []
            s.selectedDevice = nil
            s.centralManager = CBCentralManager(delegate: s, queue: s.internalQ)
            s.state = .startScan
        }
    }
    
    func stop() {
        internalQ.async { [weak self] in
            guard let s = self else {
                return
            }
            
            s.centralManager?.stopScan()
            s.peripherals = []
            
            switch s.state {
            case .stopScan(_):
                break
            default:
                s.state = .stopScan(.noDevice)
            }
        }
    }
    
    private func createTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let s = self else {
                return
            }
            
            s.timer = Timer.scheduledTimer(timeInterval: 5.0, target: s, selector: #selector(s.onTimerBlock), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func onTimerBlock() {
        stop()
    }
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        internalQ.async { [weak self] in
            if let s = self, central.state == .poweredOn, central === s.centralManager {
                s.centralManager?.scanForPeripherals(withServices: nil, options: nil)
                s.state = .startScan
            }
        }
    }
    
    private var peripherals = [CBPeripheral]() {
        didSet {
            internalQ.async { [weak self] in
                guard let s = self else {
                    return
                }
                
                s.state = .scanning(s.peripherals.count)
            }
        }
    }
    
    private var selectedDevice: CBPeripheral? {
        didSet {
            connectToSelectedDevice()
        }
    }
    
    private func connectToSelectedDevice() {
        internalQ.async { [weak self] in
            if let s = self, let selectedDevice = s.selectedDevice {
                selectedDevice.delegate = s
                s.centralManager?.connect(selectedDevice, options: nil)
            }
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        internalQ.async { [weak self] in
            guard let s = self, central === s.centralManager else { return }
            
            if s.peripherals.contains(peripheral) == true {
                return
            }

            peripheral.delegate = s
            s.peripherals.append(peripheral)
            
            if peripheral.name == PeripheralDeviceManager.deviceName {
                s.selectedDevice = peripheral
                central.stopScan()
                s.peripherals = []
                s.timer?.invalidate()
            }
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        internalQ.async { [weak self] in
            
            guard central === self?.centralManager else { return }
            
            if peripheral === self?.selectedDevice {
                peripheral.discoverServices(nil)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        internalQ.async { [weak self] in
            
            guard central === self?.centralManager else { return }

            if peripheral === self?.selectedDevice {
                self?.selectedDevice = nil
                self?.serviceCharacteristic = nil
                self?.state = .stopScan(.noDevice)
            }
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        internalQ.async { [weak self] in
            guard peripheral === self?.selectedDevice else { return }
            if let services = peripheral.services {
                for service in services {
                    if service.uuid == PeripheralDeviceManager.ledLampServiceUUID {
                        peripheral.discoverCharacteristics(nil, for: service)
                    }
                }
            }
        }
    }
    
    private var serviceCharacteristic: CBCharacteristic?
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        internalQ.async { [weak self] in
            guard let s = self, let selectedDevice = s.selectedDevice, peripheral === selectedDevice else { return }
            
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.uuid == PeripheralDeviceManager.ledLampServiceCharacteristicUUID {
                        s.serviceCharacteristic = characteristic
                        
                        print("connected to \(PeripheralDeviceManager.deviceName)")
                        if let data = "E8A203E8".hexadecimal() {
                            selectedDevice.writeValue(data, for: characteristic, type: .withoutResponse)
                        }
                
                        let selectedDeviceName = selectedDevice.name ?? "\(peripheral.identifier)"
                        s.state = .stopScan(.hasDevice(selectedDeviceName))
                    }
                }
            }
        }
    }
    
    private let sharedDataLock = NSLock()
    
    private var mColor: UIColor? = nil
    var color: UIColor? {
        set {
            sharedDataLock.lock()
            mColor = newValue
            sharedDataLock.unlock()
        }
        
        get {
            var colorCopy: UIColor? = nil
            sharedDataLock.lock()
            colorCopy = mColor
            sharedDataLock.unlock()
            return colorCopy
        }
    }
    
    private var mIsProcessingColor: Bool = false
    var isProcessingColor: Bool {
        set {
            sharedDataLock.lock()
            mIsProcessingColor = newValue
            sharedDataLock.unlock()
        }
        
        get {
            var isProcessingColorCopy = false
            sharedDataLock.lock()
            isProcessingColorCopy = mIsProcessingColor
            sharedDataLock.unlock()
            return isProcessingColorCopy
        }
    }
    
    func applyColor(_ newColor: UIColor) {
        color = newColor
        if isProcessingColor == false {
            processColor()
        }
    }
    
    private func processColor() {
            
        internalQ.async { [weak self] in
            
            guard
                let newColor = self?.color,
                    let selectedDevice = self?.selectedDevice,
                    let serviceCharacteristic = self?.serviceCharacteristic,
                    selectedDevice.state == .connected
            else {
                self?.isProcessingColor = false
                return
            }
            
            self?.isProcessingColor = true
            
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var alpha: CGFloat = 0
            newColor.getRed(&r, green: &g, blue: &b, alpha: &alpha)

            r = r * 100.0
            g = g * 100.0
            b = b * 100.0
            
            if r < 0 { r = 0 }
            if g < 0 { g = 0 }
            if b < 0 { b = 0 }

            let parts = ["E8A4\(String(Int(r), radix: 16))",
                         "E8A5\(String(Int(g), radix: 16))",
                         "E8A6\(String(Int(b), radix: 16))"]
            for part in parts {
                if let data = part.hexadecimal() {
                    selectedDevice.writeValue(data, for: serviceCharacteristic, type: .withoutResponse)
                    Thread.sleep(forTimeInterval: 0.05)
                }
            }

            self?.processColor()
        }
    }
}

extension String {
    func hexadecimal() -> Data? {
        var data = Data()
        if let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) {
            regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
                if let match = match {
                    let byteString = (self as NSString).substring(with: match.range)
                    if let numValue = UInt8(byteString, radix: 16) {
                        var num = numValue
                        data.append(&num, count: 1)
                    }
                }
            }
        }
        return (data.count > 0) ? data : nil
    }
}
