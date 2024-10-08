//
//  SelectColorPaletteView.swift
//  Lampyrid
//
//  Created by Alex on 10/1/24.
//

import SwiftUI

enum EditColorPanelColorChangeType {
    case item(Color)
    case sliderHue(Double)
    case sliderSaturation(Double)
    case sliderBrightness(Double)
}

struct EditColorPanelView: View {
    
    @StateObject private var vm = EditColorPanelViewModel()
    @ObservedObject var item: ColorsCollectionItem
    
    let onAddNewItem: (Color) -> Void
    let onRemoveItem: (ColorsCollectionItem) -> Void
    
    var body: some View {
        VStack {
            
            HStack {
                EditColorActionButtonView(title: "Duplicate",
                                          actionBlock: { onAddNewItem(item.color) })
                
                Spacer()
                
                EditColorActionButtonView(title: "Remove",
                                          actionBlock: { onRemoveItem(item) })
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
            EditColorSliderView(value: $vm.hueValue, title: "Hue", backgroundFill: hueSliderBg)
                .onChange(of: vm.hueValue) { newValue in
                    vm.updateWith(.sliderHue(newValue), item: item)
                }
            
            EditColorSliderView(value: $vm.saturationValue, title: "Saturation", backgroundFill: saturationSliderBg)
                .onChange(of: vm.saturationValue) { newValue in
                    vm.updateWith(.sliderSaturation(newValue), item: item)
                }
            
            EditColorSliderView(value: $vm.brightnessValue, title: "Brightness", backgroundFill: brightnessSliderBg)
                .onChange(of: vm.brightnessValue) { newValue in
                    vm.updateWith(.sliderBrightness(newValue), item: item)
                }
        }
        .onChange(of: item, perform: { newValue in
            vm.updateWith(.item(newValue.color), item: newValue)
        })
        .onAppear(perform: {
            vm.updateWith(.item(item.color), item: item)
        })
        .padding(.vertical, 20)
        .background(Color(white: 0.5).opacity(0.4))
        .cornerRadius(15)
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
    }
    
    private var hueSliderBg: LinearGradient {
        return LinearGradient(gradient: Gradient(colors: [
            Color(hue: 0, saturation: 1, brightness: 1),
            Color(hue: 1/6, saturation: 1, brightness: 1),
            Color(hue: 2/6, saturation: 1, brightness: 1),
            Color(hue: 3/6, saturation: 1, brightness: 1),
            Color(hue: 4/6, saturation: 1, brightness: 1),
            Color(hue: 5/6, saturation: 1, brightness: 1),
            Color(hue: 1, saturation: 1, brightness: 1)
        ]), startPoint: .leading, endPoint: .trailing)
    }
    
    private var saturationSliderBg: LinearGradient {
        return LinearGradient(gradient: Gradient(colors: [
            Color(hue: vm.hueValue, saturation: 0, brightness: vm.brightnessValue),
            Color(hue: vm.hueValue, saturation: 1, brightness: vm.brightnessValue)
        ]), startPoint: .leading, endPoint: .trailing)
    }
    
    private var brightnessSliderBg: LinearGradient {
        return LinearGradient(gradient: Gradient(colors: [
            Color(hue: vm.hueValue, saturation: vm.saturationValue, brightness: 0),
            Color(hue: vm.hueValue, saturation: vm.saturationValue, brightness: 1)
        ]), startPoint: .leading, endPoint: .trailing)
    }
}

struct SelectColorPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        EditColorPanelView(item: .init(color: .blue, isSelected: false), onAddNewItem: { _ in }, onRemoveItem: { _ in })
    }
}
