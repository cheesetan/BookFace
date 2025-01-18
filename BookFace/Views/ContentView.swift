//
//  ContentView.swift
//  BookFace
//
//  Created by Tristan Chay on 18/1/25.
//

import SwiftUI
import Supabase

struct ContentView: View {

    @State private var tabManager = TabManager()
    @State private var authManager = AuthManager()

    var body: some View {
        VStack {
            switch authManager.authenticationState {
            case .signedOut:
                AuthView()
            case .signedInButNotVerified:
                FaceVerificationView()
            case .signedInAndVerified:
                ZStack {
                    MainScreen().ignoresSafeArea()
                    VStack {
                        Spacer()
                        CustomTabBar()
                            .ignoresSafeArea()
                    }
                }
            case .unknown:
                Text("Unknown")
            }
        }
        .environment(tabManager)
        .environment(authManager)
    }
}

#Preview {
    ContentView()
}
