//
//  MainScreen.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI

struct MainScreen: View {

    @Environment(TabManager.self) private var tabManager

    var body: some View {
        switch tabManager.currentTab {
        case .home: Color.red
        case .scan: Color.blue
        case .profile: Color.green
        }
    }
}

#Preview {
    MainScreen()
}
