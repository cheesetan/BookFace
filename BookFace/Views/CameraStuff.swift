//
//  CameraStuff.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI
import AVFoundation

class CameraManager: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get camera")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }

            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }

            session.startRunning()
        } catch {
            print("Failed to setup camera: \(error)")
        }
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }

        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                Button(action: {
                    cameraManager.takePhoto()
                }) {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 70, height: 70)
                        .padding(.bottom, 150)
                }
            }
        }
        .onChange(of: cameraManager.capturedImage) { newImage in
            if let image = newImage {
                capturedImage = image
                dismiss()
            }
        }
    }
}
