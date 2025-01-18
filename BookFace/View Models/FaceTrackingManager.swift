//
//  FaceTrackingManager.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI
import AVFoundation
import Vision

class FaceTrackingManager: NSObject, ObservableObject {
    
    @Published var isBlinking = false
    @Published var blinkCount = 0
    @Published var capturedImage: UIImage?
    @Published var isSessionActive = true

    let session = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private var faceLandmarks: VNFaceObservation?
    private var wasBlinking = false

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

            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }

            session.startRunning()
        } catch {
            print("Failed to setup camera: \(error)")
        }
    }

    private func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNFaceObservation],
                  let face = observations.first else {
                return
            }

            DispatchQueue.main.async {
                self.faceLandmarks = face
                if let leftEye = face.landmarks?.leftEye,
                   let rightEye = face.landmarks?.rightEye {
                    let leftEyeAspectRatio = self.getEyeAspectRatio(eye: leftEye)
                    let rightEyeAspectRatio = self.getEyeAspectRatio(eye: rightEye)

                    let blinkThreshold: Float = 0.1
                    let isBlinking = (leftEyeAspectRatio < blinkThreshold) &&
                    (rightEyeAspectRatio < blinkThreshold)

                    // Count complete blink (only when eyes open after being closed)
                    if !isBlinking && self.wasBlinking {
                        self.blinkCount += 1

                        // Take photo after 3 blinks
                        if self.blinkCount == 5 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                self.takePhoto()
                            }
                        }
                    }

                    self.wasBlinking = isBlinking
                    self.isBlinking = isBlinking
                }
            }
        }

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored)
        try? imageRequestHandler.perform([faceDetectionRequest])
    }

    private func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func getEyeAspectRatio(eye: VNFaceLandmarkRegion2D) -> Float {
        let points = eye.normalizedPoints
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

    func stopSession() {
        session.stopRunning()
        isSessionActive = false
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

extension FaceTrackingManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }

        DispatchQueue.main.async {
            self.capturedImage = image
            self.stopSession()
        }
    }
}

