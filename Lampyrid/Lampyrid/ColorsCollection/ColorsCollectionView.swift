//
//  ColorscollectionView.swift
//  Lampyrid
//
//  Created by Alex on 10/1/24.
//

import SwiftUI

struct ColorsCollectionView: View {
    
    @ObservedObject var appModel: AppModel
    @ObservedObject var vm: ColorsCollectionViewModel
    @State private var edit = false
        
    var body: some View {
        GeometryReader { geometryProxy in
            let itemWidth: CGFloat = geometryProxy.size.width / 3.0 - 24
            let columns = [GridItem(.adaptive(minimum: itemWidth))]
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(Array(vm.items.enumerated()), id: \.element.id) { index, item in
                            
                            ColorsCollectionCellView(item: item,
                                                     width: itemWidth,
                                                     height: itemWidth)
                            .onTapGesture {
                                vm.applySelectedItemIndex(index)
                            }
                        }
                    }

                    .padding(10)
                }
                .background(LinearGradient(gradient: Gradient(colors: [Color("collectionBgTop"), Color("collectionBgBottom")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(15)
                .padding(.horizontal, 10)
            }
        }
        .onAppear(perform: {
            vm.appModel = appModel
        })
    }
}

struct ColorscollectionView_Previews: PreviewProvider {
    static var previews: some View {
        ColorsCollectionView(appModel: .init(), vm: .init())
    }
}
