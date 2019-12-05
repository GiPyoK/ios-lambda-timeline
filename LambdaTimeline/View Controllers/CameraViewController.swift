//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Gi Pyo Kim on 12/4/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer?
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpCamera()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGuesture(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTapGuesture(_ tapGesture: UITapGestureRecognizer) {
        switch tapGesture.state {
        case .ended:
            playRecording()
        default:
            print("Handle other states: \(tapGesture.state)")
        }
    }
    
    func playRecording() {
        if let player = player {
            // CMTime
            player.seek(to: CMTime.zero)
            
            // time seek to different time
            // CMTime(seconds: 10, preferredTimescale: 600)
            
            player.play()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func setUpCamera() {
        let camera = bestCamera()
        
        captureSession.beginConfiguration()
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Can't create an input")
        }
        
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("This session cannot handle this type of input: \(cameraInput)")
        }
        
        captureSession.addInput(cameraInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        // Add audio input
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
            fatalError("Can't create input from microphone")
        }
        guard captureSession.canAddInput(audioInput) else {
            fatalError("Can't add audio input")
        }
        captureSession.addInput(audioInput)
        
        
        // Add video output (save)
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot record to disk")
        }
        captureSession.addOutput(fileOutput)
        
        
        captureSession.commitConfiguration()
        
        cameraView.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if #available(iOS 13.0, *) {
            if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
                return device
            }
        } else {
            // Fallback on earlier versions
        }
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        fatalError("No cameras on the device (or you are running it on the iPhone simulator)")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        toggleRecord()
    }
    
    private func toggleRecord() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            playerLayer?.removeFromSuperlayer()
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        var topRect = view.bounds
        topRect.size.height = topRect.height / 1.5
        topRect.size.width = topRect.width / 1.5
        topRect.origin.y = view.safeAreaInsets.top
        playerLayer?.frame = topRect
        view.layer.addSublayer(playerLayer!)
        
        player.play()
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }
        
        print(outputFileURL.path)
        updateViews()
        
        playMovie(url: outputFileURL)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
}

