//
//  ContentView.swift
//  Lampyrid
//
//  Created by Alex on 10/8/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var appModel = AppModel()
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            NavigationView() {
                LampTabView(appModel: appModel)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    appModel.isEditing.toggle()
                                }
                            } label: {
                                Image(systemName: "slider.vertical.3")
                            }

                        }
                    }
            }
            .tabItem {
                Text("Lamp")
                Image(systemName: "lamp.table")
                    .renderingMode(.template)
            }
            .tag(0)
            
            NavigationView() {
                Text("")
            }
            .tabItem {
                Text("Info")
                Image(systemName: "gear")
                    .renderingMode(.template)
            }
            .tag(1)
        }
        .onAppear(perform: {
            UITabBar.appearance().unselectedItemTintColor = .systemGray
            UITabBarItem.appearance().badgeColor = .systemPink
            UITabBar.appearance().backgroundColor = .systemGray4
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.gray]
            
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
