//
//  EditColorSliderView.swift
//  Lampyrid
//
//  Created by Alex on 10/2/24.
//

import SwiftUI

struct EditColorSliderView: View {
    
    @Binding var value: Double
    
    let title: String
    let backgroundFill: LinearGradient
    
    var body: some View {
        HStack {
            Text(title)
            ZStack {
                backgroundFill.cornerRadius(4)
                GeometryReader { geometry in
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                        Circle()
                            .stroke(Color.blue, lineWidth: 4)
                    }
                    .frame(width: 20, height: 20)
                    .offset(x: value * (geometry.size.width - 20))
                    .gesture(DragGesture(minimumDistance: 0).onChanged { dragValue in
                        let sliderRange = geometry.size.width - 20
                        value = min(max(0, Double((dragValue.location.x - 10) / sliderRange)), 1)
                    })
                }
            }
            .frame(height: 20)
        }
        .padding(10)
    }
}

struct EditColorSliderView_Previews: PreviewProvider {
    static var previews: some View {
        EditColorSliderView(value: .constant(0.5), title: "Hue", backgroundFill: .linearGradient(.init(colors: [.green, .red]), startPoint: .top, endPoint: .bottom))
    }
}
