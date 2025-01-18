//
//  TabManager.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI

@Observable
class TabManager {
    private(set) var currentTab: CustomTabs = .home

    init() { }

    func setTab(to newTab: CustomTabs) {
        withAnimation {
            currentTab = newTab
        }
    }
}
