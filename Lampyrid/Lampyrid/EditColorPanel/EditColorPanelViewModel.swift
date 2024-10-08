//
//  SelectColorPaletteViewModel.swift
//  Lampyrid
//
//  Created by Alex on 10/1/24.
//

import Foundation
import SwiftUI

class EditColorPanelViewModel: ObservableObject {
    @Published var hueValue: Double = 0.0
    @Published var saturationValue: Double = 1.0
    @Published var brightnessValue: Double = 1.0
    
    func updateWith(_ value: EditColorPanelColorChangeType, item: ColorsCollectionItem) {
        switch value {
        case .item(let color):
            var itemColorHue: CGFloat = 0
            var itemColorSat: CGFloat = 0
            var itemColorBr: CGFloat = 0
            var alpha: CGFloat = 0
            UIColor(color).getHue(&itemColorHue, saturation: &itemColorSat, brightness: &itemColorBr, alpha: &alpha)
            
            if isDifferent(hueValue, itemColorHue) {
                hueValue = itemColorHue
            }
            
            if isDifferent(saturationValue, itemColorSat) {
                saturationValue = itemColorSat
            }

            if isDifferent(brightnessValue, itemColorBr) {
                brightnessValue = itemColorBr
            }
            
        case .sliderHue(let newHueValue):
            if isDifferent(hueValue, newHueValue) {
                hueValue = newHueValue
            }
            item.color = Color(hue: hueValue, saturation: saturationValue, brightness: brightnessValue)
        case .sliderSaturation(let newSaturationValue):
            if isDifferent(saturationValue, newSaturationValue) {
                saturationValue = newSaturationValue
            }
            item.color = Color(hue: hueValue, saturation: saturationValue, brightness: brightnessValue)
        case .sliderBrightness(let newBrightnessValue):
            if isDifferent(brightnessValue, newBrightnessValue) {
                brightnessValue = newBrightnessValue
            }
            item.color = Color(hue: hueValue, saturation: saturationValue, brightness: brightnessValue)
        }
    }
    
    private func isDifferent(_ a: Double, _ b: Double) -> Bool {
        let m: Double = 100
        return (Int(a * m) != Int(b * m))
    }
}
