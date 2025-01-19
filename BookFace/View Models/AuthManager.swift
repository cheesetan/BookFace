//
//  AuthManager.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI
import Supabase

enum AuthState {
    case signedOut, signedInButNotVerified, signedInAndVerified, unknown
}

enum FaceImageUploadType {
    case signUp, comparison
}

@Observable
class AuthManager {

    private(set) var isLoading = false
    private(set) var currentUser: User?

    private(set) var authenticationState: AuthState

    init() {
        if supabase.auth.currentUser == nil {
            authenticationState = .signedOut
        } else if supabase.auth.currentUser?.userMetadata["faceVerified"] == false {
            authenticationState = .signedInButNotVerified
        } else if supabase.auth.currentUser?.userMetadata["faceVerified"] == true {
            authenticationState = .signedInAndVerified
        } else {
            authenticationState = .unknown
        }

        updateUserStatus()
    }

    private func updateUserStatus() {
        withAnimation {
            currentUser = supabase.auth.currentUser
            if supabase.auth.currentUser == nil {
                authenticationState = .signedOut
            } else if supabase.auth.currentUser?.userMetadata["faceVerified"] == false {
                authenticationState = .signedInButNotVerified
            } else if supabase.auth.currentUser?.userMetadata["faceVerified"] == true {
                authenticationState = .signedInAndVerified
            } else {
                authenticationState = .unknown
            }
        }
    }

    func signUp(email: String, password: String) {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                try await supabase.auth.signUp(
                    email: email,
                    password: password,
                    data: [
                        "faceVerified" : false
                    ]
                )

                signIn(email: email, password: password) {
                    self.addtodb(email: email)
                }
            } catch {
                if error.localizedDescription == "User already registered" {
                    signIn(email: email, password: password) {}
                } else {
                    print(error)
                }
            }
        }
    }

    func addtodb(email: String) {
        Task {
            do {
                try await supabase.from("auth").insert(
                    [
                        "id": self.currentUser?.id.uuidString ?? "nil",
                        "email": email,
                        "chats": ""
                    ]
                ).execute()
            } catch {
                print(error)
            }
        }
    }

    func signIn(email: String, password: String, _ completion: @escaping () -> ()) {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                try await supabase.auth.signIn(
                    email: email,
                    password: password
                )
                updateUserStatus()
                completion()
            } catch {
                print(error)
            }
        }
    }

    func signOut() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                try await supabase.auth.signOut()
                updateUserStatus()
            } catch {
                print(error)
            }
        }
    }

    func verifyFace(image: UIImage) {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                try await supabase.auth.update(
                    user: .init(
                        data: [
                            "faceVerified" : true
                        ]
                    )
                )
                uploadFaceImage(image: image, for: .signUp)
            } catch {
                if error.localizedDescription == "sessionMissing" {
                    self.signOut()
                } else {
                    print(error)
                }
            }
        }
    }

    func uploadFaceImage(image: UIImage, for type: FaceImageUploadType) {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let fileName = "\(currentUser?.id.uuidString ?? "nil").jpg"
                
                if let data = image.jpegData(compressionQuality: 1.0) {
                    try await supabase.storage
                        .from("\(type == .signUp ? "new_user" : "Retrieve")")
                        .upload(
                            "\(type == .signUp ? "\(fileName)" : "retrieve.jpg")",
                            data: data,
                            options: FileOptions(
                                cacheControl: "3600",
                                contentType: "image/jpg",
                                upsert: false
                            )
                        )
                    updateUserStatus()
                }
            } catch {
                print(error)
            }
        }
    }
}
