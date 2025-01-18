//
//  CustomTextField.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI

struct CustomTextField: View {

    private var title: String
    private var placeholder: String
    private var redact: Bool

    @Binding var text: String

    init(_ title: String, _ placeholder: String, text: Binding<String>, redact: Bool = false) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.redact = redact
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .padding(.leading, 10)
            if redact {
                SecureField(placeholder, text: $text)
                    .padding()
                    .background(.ultraThickMaterial)
                    .mask(Capsule())
            } else {
                TextField(placeholder, text: $text)
                    .padding()
                    .background(.ultraThickMaterial)
                    .mask(Capsule())
            }
        }
    }
}
