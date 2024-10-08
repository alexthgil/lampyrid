//
//  LampTabView.swift
//  Lampyrid
//
//  Created by Alex on 10/1/24.
//

import SwiftUI

struct LampTabView: View {
    
    @ObservedObject var appModel: AppModel
    @StateObject private var collectionViewModel = ColorsCollectionViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text(appModel.status)
                .font(.callout)
                .foregroundColor(Color("statusColor"))
                .padding(.horizontal, 10)
            
            ColorsCollectionView(appModel: appModel,
                                 vm: collectionViewModel)

            if appModel.isEditing {
                EditColorPanelView(item: collectionViewModel.selectedItem,
                                   onAddNewItem: { color in
                    collectionViewModel.addNewColor(color)
                },
                                   onRemoveItem: { item in
                    collectionViewModel.removeSelected()
                })
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

struct LampTabView_Previews: PreviewProvider {
    static var previews: some View {
        LampTabView(appModel: .init())
    }
}
