//
//  ContentView.swift
//  BookFace
//
//  Created by Tristan Chay on 18/1/25.
//

import SwiftUI
import AVFoundation
import Vision

// Camera view that handles camera preview
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class FaceTrackingManager: NSObject, ObservableObject {
    @Published var isBlinking = false
    let session = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var faceLandmarks: VNFaceObservation?

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to get front camera")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }

            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
            }

            DispatchQueue.main.async {
                self.session.startRunning()
            }
        } catch {
            print("Failed to setup camera: \(error)")
        }
    }

    private func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let observations = request.results as? [VNFaceObservation],
                  let face = observations.first else {
                return
            }

            DispatchQueue.main.async {
                self?.faceLandmarks = face
                // Check for blinking by analyzing eye landmarks
                if let leftEye = face.landmarks?.leftEye,
                   let rightEye = face.landmarks?.rightEye {
                    let leftEyeAspectRatio = self?.getEyeAspectRatio(eye: leftEye)
                    let rightEyeAspectRatio = self?.getEyeAspectRatio(eye: rightEye)

                    // Threshold for determining if eyes are closed
                    let blinkThreshold: Float = 0.1
                    let isBlinking = (leftEyeAspectRatio ?? 1.0 < blinkThreshold) &&
                    (rightEyeAspectRatio ?? 1.0 < blinkThreshold)
                    self?.isBlinking = isBlinking
                }
            }
        }

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored)
        try? imageRequestHandler.perform([faceDetectionRequest])
    }

    private func getEyeAspectRatio(eye: VNFaceLandmarkRegion2D) -> Float {
        let points = eye.normalizedPoints
        // Calculate the eye aspect ratio using the landmark points
        // EAR = (||p2-p6|| + ||p3-p5||) / (2||p1-p4||)
        guard points.count >= 6 else { return 1.0 }

        let p1 = points[0]
        let p2 = points[1]
        let p3 = points[2]
        let p4 = points[3]
        let p5 = points[4]
        let p6 = points[5]

        let width = hypot(p1.x - p4.x, p1.y - p4.y)
        let height1 = hypot(p2.x - p6.x, p2.y - p6.y)
        let height2 = hypot(p3.x - p5.x, p3.y - p5.y)

        return Float((height1 + height2) / (2.0 * width))
    }
}

extension FaceTrackingManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        detectFace(in: pixelBuffer)
    }
}

struct ContentView: View {
    @StateObject private var faceTrackingManager = FaceTrackingManager()

    @State private var blinkCount = 0
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            CameraPreview(session: faceTrackingManager.session)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                Text("\(blinkCount)")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
        }
        .onReceive(timer) { time in
            if blinkCount > 0 {
                blinkCount -= 1
            }
        }
        .onChange(of: faceTrackingManager.isBlinking) { _, newValue in
            if newValue {
                blinkCount += 1
            }
        }
    }
}

#Preview {
    ContentView()
}
