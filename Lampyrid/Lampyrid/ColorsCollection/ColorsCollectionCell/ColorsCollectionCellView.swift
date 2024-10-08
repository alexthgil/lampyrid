//
//  ColorsCollectionCellView.swift
//  Lampyrid
//
//  Created by Alex on 10/1/24.
//

import SwiftUI

extension Color {
    func brightnessString() -> String {
        var itemColorHue: CGFloat = 0
        var itemColorSat: CGFloat = 0
        var itemColorBr: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getHue(&itemColorHue, saturation: &itemColorSat, brightness: &itemColorBr, alpha: &alpha)
        return "\(Int(itemColorBr * 100))"
    }
}

struct ColorsCollectionCellView: View {
    
    @ObservedObject var item: ColorsCollectionItem
    
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(item.color)
                .cornerRadius(10)
                
                VStack(alignment: .trailing) {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack {
                            HStack {
                                Image(systemName: "light.max")
                                Text(item.color.brightnessString())
                                    .font(.monospacedDigit(.callout)())
                            }.padding(.horizontal, 8)

                        }
                        .background(Capsule()
                            .fill(Color(white: 0, opacity:0.3)))
                        .padding(.trailing, 4)
                        .padding(.bottom, 4)
                    }
                }
            
            if item.isSelected {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .background(Circle()
                                .fill(Color(white: 0, opacity:0)))
                            .foregroundColor(.green)
                            .frame(width: 26, height: 26)
                            .padding(4)
                    }
                    
                    Spacer()
                }
            }
        }
        .frame(width: width, height: height)
    }
}

struct ColorsCollectionCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ColorsCollectionCellView(item: .init(color: .gray, isSelected: false), width: 100, height: 100)
            ColorsCollectionCellView(item: .init(color: .blue, isSelected: true), width: 100, height: 100)
        }
    }
}
