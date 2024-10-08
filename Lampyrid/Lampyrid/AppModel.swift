//
//  AppModel.swift
//  Lampyrid
//
//  Created by Alex on 9/30/24.
//

import Foundation
import SwiftUI

class AppModel: ObservableObject, PeripheralDeviceManagerDelegate, ColorsCollectionItemDelegate {

    @Published var status = ""
    @Published var isEditing = false
    
    weak var currentColorItem: ColorsCollectionItem? {
        didSet {
            oldValue?.delegate = nil
            currentColorItem?.delegate = self
            updateDeviceWithColor()
        }
    }
    
    private let peripheralDeviceScanner: PeripheralDeviceManager
    
    init() {
        peripheralDeviceScanner = PeripheralDeviceManager()
        peripheralDeviceScanner.delegate = self
        peripheralDeviceScanner.scan()
    }
    
    func applyColorItem(_ item: ColorsCollectionItem) {
        currentColorItem = item
    }
    
    //MARK: - ColorsCollectionItemDelegate
    
    func colorItemDidChange() {
        updateDeviceWithColor()
    }
    
    //MARK: - PeripheralDeviceScanerDelegate
    
    func peripheralDeviceScannerDidChangeState(_ scanner: PeripheralDeviceManager, currentStateType: PeripheralDeviceManagerStateType) {
        
        guard peripheralDeviceScanner === scanner else {
            return
        }
        
        Task { @MainActor in
            switch currentStateType {
            case .initial:
                status = ""
            case .startScan:
                status = "... start scan"
            case .scanning(let v):
                status = "... scanning \(v)"
            case .stopScan(let peripheralDeviceManagerState):
                switch peripheralDeviceManagerState {
                case .noDevice:
                    status = "no device"
                case .hasDevice(let dName):
                    status = dName
                    updateDeviceWithColor()
                }
            }
        }
    }
    
    //MARK: -
    
    private func updateDeviceWithColor() {
        if let currentColorItem = currentColorItem {
            peripheralDeviceScanner.applyColor(UIColor(currentColorItem.color))
        }
    }
    
}
