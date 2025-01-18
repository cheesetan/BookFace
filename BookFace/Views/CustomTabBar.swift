//
//  CustomTabBar.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI

enum CustomTabs {
    case home, scan, profile
}

struct CustomTabBar: View {

    @Environment(TabManager.self) private var tabManager

    var body: some View {
        HStack {
            Spacer()
            Button {
                tabManager.setTab(to: .home)
            } label: {
                Image("home")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32)
            }
            .buttonStyle(.plain)
            Spacer()
            Button {
                tabManager.setTab(to: .scan)
            } label: {
                Image("scan")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48)
            }
            .buttonStyle(.plain)
            Spacer()
            Button {
                tabManager.setTab(to: .profile)
            } label: {
                Image("profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .frame(height: 55)
        .background(.white)
    }
}

#Preview {
    CustomTabBar()
}
