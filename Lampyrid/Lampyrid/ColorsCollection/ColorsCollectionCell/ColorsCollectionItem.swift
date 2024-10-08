//
//  ColorsCollectionItem.swift
//  Lampyrid
//
//  Created by Alex on 10/3/24.
//

import Foundation
import Combine
import SwiftUI

protocol ColorsCollectionItemDelegate: AnyObject {
    func colorItemDidChange()
}

class ColorsCollectionItem: Identifiable, ObservableObject {
    
    let id = UUID()
    @Published var color: Color
    @Published var isSelected: Bool
    
    private var subscriptionToColor = Set<AnyCancellable>()
    weak var delegate: ColorsCollectionItemDelegate? {
        didSet {
            subscriptionToColor = Set<AnyCancellable>()
            self.$color.sink { [weak self] newColor in
                self?.notifyAboutChanges()
            }.store(in: &subscriptionToColor)
        }
    }

    init(color: Color, isSelected: Bool) {
        self.color = color
        self.isSelected = isSelected
    }
    
    private func notifyAboutChanges() {
        self.delegate?.colorItemDidChange()
    }
}


extension ColorsCollectionItem: Equatable {
    static func == (lhs: ColorsCollectionItem, rhs: ColorsCollectionItem) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
