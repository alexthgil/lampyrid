//
//  EditColorActionButton.swift
//  Lampyrid
//
//  Created by Alex on 10/4/24.
//

import SwiftUI

struct EditColorActionButtonView: View {
    
    let title: String
    let actionBlock: (() -> Void)?
    
    var body: some View {
        Button {
            actionBlock?()
        } label: {
            Text(title)
                .padding(8)
                .foregroundColor(.white)
                .background(Color.blue.opacity(0.7))
                .cornerRadius(10)
        }
    }
}

struct EditColorActionButton_Previews: PreviewProvider {
    static var previews: some View {
        EditColorActionButtonView(title: "Delete", actionBlock: nil)
    }
}
