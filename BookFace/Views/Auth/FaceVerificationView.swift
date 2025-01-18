//
//  FaceVerificationView.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI

struct FaceVerificationView: View {

    @StateObject private var faceTrackingManager = FaceTrackingManager()
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        VStack(spacing: 15) {
            Image("longlogo")
                .resizable()
                .scaledToFit()
                .frame(height: 30)

            Text("Lastly, blink 5 times to capture your photo and verify your identify.")
                .multilineTextAlignment(.center)

            if faceTrackingManager.isSessionActive {
                CameraPreview(session: faceTrackingManager.session)
                    .edgesIgnoringSafeArea(.all)
                    .mask(RoundedRectangle(cornerRadius: 16))
            } else if let capturedImage = faceTrackingManager.capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .edgesIgnoringSafeArea(.all)
                    .mask(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        Color.white.opacity(0.3)
                        VStack(spacing: 10) {
                            Image(systemName: "hand.thumbsup.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                                .foregroundStyle(.buttonBlue)
                            
                            Text("Successfully Verified")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    }
            }

        }
        .padding(.horizontal, 30)
        .padding(.vertical)
        .onChange(of: faceTrackingManager.capturedImage) {
            if let image = faceTrackingManager.capturedImage, faceTrackingManager.blinkCount >= 5 {
                authManager.verifyFace(image: image)
            }
        }
    }
}
