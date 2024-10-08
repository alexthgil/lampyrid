//
//  ColorscollectionViewModel.swift
//  Lampyrid
//
//  Created by Alex on 10/1/24.
//

import Foundation
import SwiftUI
import Combine

class ColorsCollectionViewModel: ObservableObject {
    @Published private(set) var items: [ColorsCollectionItem] = []
    @Published private(set) var selectedItem: ColorsCollectionItem = .init(color: .green, isSelected: false)
    
    private var selectedItemIndex: Int = 0 {
        didSet {
            updateDisplayingSelectedItemIndex()
        }
    }
    
    weak var appModel: AppModel? {
        didSet {
            appModel?.applyColorItem(selectedItem)
        }
    }
    
    init() {
        var newItems = [ColorsCollectionItem]()
        for hue in stride(from: 0.1, to: 1, by: 0.06) {
            let newColor = Color(hue: hue, saturation: 1, brightness: 1)
            newItems.append(ColorsCollectionItem(color: newColor, isSelected: false))
        }
        
        items = newItems
        updateDisplayingSelectedItemIndex()
    }
    
    //MARK: -
    
    func applySelectedItemIndex(_ newIndex: Int) {
        selectedItemIndex = newIndex
    }
    
    func addNewColor(_ color: Color) {
        if 0 <= selectedItemIndex, selectedItemIndex < items.count {
            items.insert(ColorsCollectionItem(color: color, isSelected: false), at: selectedItemIndex)
            updateSelectedIndexToItems()
        } else {
            assert(false)
        }
    }
    
    func removeSelected() {
        if items.count > 1 {
            if 0 <= selectedItemIndex, selectedItemIndex < items.count  {
                items.remove(at: selectedItemIndex)
                updateSelectedIndexToItems()
            } else {
                assert(false)
            }
        }
    }
    
    //MARK: -
    
    private func updateSelectedIndexToItems() {
        if 0 <= selectedItemIndex, selectedItemIndex < items.count {
            updateDisplayingSelectedItemIndex()
        } else {
            selectedItemIndex = items.count - 1
        }
    }
    
    private func updateDisplayingSelectedItemIndex() {
        selectedItem.isSelected = false
        selectedItem = items[selectedItemIndex]
        selectedItem.isSelected = true
        appModel?.applyColorItem(selectedItem)
    }
}
