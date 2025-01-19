//
//  MainScreen.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI

struct MainScreen: View {

    @State private var uuid: String?
    @State private var selectedUser: ProfileUser?

    @State private var image: UIImage?

    @Environment(AuthManager.self) private var authManager
    @Environment(TabManager.self) private var tabManager

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var chatEmails: [String] = []

    var body: some View {
        Group {
            switch tabManager.currentTab {
            case .home: ChatView(chatEmails: $chatEmails)
            case .scan: CameraView(capturedImage: $image)
            case .profile: ProfileView()
            }
        }
        .onChange(of: image) {
            if let image {
                authManager.uploadFaceImage(image: image, for: .comparison)
            }
        }
        .onReceive(timer) { _ in
            dshjhjsdk()
        }
    }

    func dshjhjsdk() {
        Task {
            do {
                let users: [UserAgain] = try await supabase
                    .from("Retrieve")
                    .select("id")
                    .execute()
                    .value

                if users.count > 0 {
                    self.uuid = users[0].id

                    try await supabase
                        .from("Retrieve")
                        .delete()
                        .eq("id", value: self.uuid)
                        .execute()

                    let allusers: [ProfileUser] = try await supabase
                        .from("auth")
                        .select()
                        .execute()
                        .value


                    self.selectedUser = allusers.first(where: { $0.id == self.uuid })
                    chatEmails.append(selectedUser?.email ?? "nil")
                    if selectedUser?.chats.isEmpty == true {
                        try await supabase
                            .from("auth")
                            .update(["chats" : selectedUser?.id])
                            .eq("id", value: authManager.currentUser?.id.uuidString)
                            .execute()
                    } else {
                        let you = allusers.first(where: { $0.id == authManager.currentUser?.id.uuidString })
                        try await supabase
                            .from("auth")
                            .update(["chats" : "\(String(describing: you?.chats))|\(String(describing: selectedUser?.id))"])
                            .eq("id", value: authManager.currentUser?.id.uuidString)
                            .execute()
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

struct ProfileView: View {

    @Environment(AuthManager.self) private var authManager

    var body: some View {
        Button("sign out") {
            authManager.signOut()
        }
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

struct UserAgain: Decodable {
    let id: String
}

struct ProfileUser: Identifiable, Decodable {
    let id: String
    var email: String
    var chats: String
}

struct ChatView: View {

    @Binding var chatEmails: [String]

    var body: some View {
        NavigationStack {
            List {
                ForEach(chatEmails.filter({ $0 != "nil" }), id: \.self) { email in
                    NavigationLink {
                        ChatChatView(email: email)
                    } label: {
                        Text(email)
                    }
                }
            }
            .navigationTitle("Chats")
        }
    }
}

struct ChatChatView: View {

    @State var email: String
    @State private var text = ""

    @State private var what: [String] = []

    var body: some View {
        VStack {
            List(what, id: \.self) { what in
                Text(what)
            }
            HStack {
                TextField("Enter message", text: $text)
                    .textFieldStyle(.roundedBorder)
                Button("Send") {
                    what.append(text)
                    text = ""
                }
            }
            .padding(.bottom, 100)
        }
        .navigationTitle(email)
    }
}

#Preview {
    MainScreen()
}
