//
//  AuthView.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI

struct AuthView: View {

    @State private var email = ""
    @State private var password = ""

    @Environment(AuthManager.self) private var authManager

    var body: some View {
        VStack(spacing: 15) {
            Image("longlogo")
                .resizable()
                .scaledToFit()
                .frame(height: 30)

            Spacer()
            Spacer()

            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading) {
                    Text("Welcome!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.signUpBlue)

                    Text("Sign Up or Log In to continue.")
                }

                VStack(spacing: 15) {
                    CustomTextField(
                        "Email",
                        "johndoe123@gmail.com",
                        text: $email
                    )
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)

                    CustomTextField(
                        "Password",
                        "At least 6 characters long",
                        text: $password,
                        redact: true
                    )
                    .textContentType(.password)
                }
            }

            Button {
                authManager.signUp(email: email, password: password)
            } label: {
                HStack {
                    Spacer()
                    Text("Let's go!")
                    Spacer()
                    Image(systemName: "arrowtriangle.right.fill")
                }
                    .padding(10)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.buttonBlue)
            .mask(Capsule())
            .disabled(email.isEmpty || password.count < 6)

            Spacer()
            Spacer()
            Spacer()
        }
        .padding(.vertical)
        .padding(.horizontal, 30)
    }
}
