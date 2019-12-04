//
//  VoiceRecordViewController.swift
//  LambdaTimeline
//
//  Created by Gi Pyo Kim on 12/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceRecordViewController: UIViewController {
    
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var recordStopButton: UIButton!
    
    // Playback properties
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    // Recording properties
    var audioRecorder: AVAudioRecorder?
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    var post: Post!
    var postController: PostController!
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize, weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize, weight: .regular)

        audioPlayer?.delegate = self
        updateViews()
    }
    
    private func updateViews() {
        let playButtonTitle = isPlaying ? "⏸" : "▶️"
        playPauseButton.setTitle(playButtonTitle, for: .normal)
        
        let elapsedTime = audioPlayer?.currentTime ?? 0
        timeElapsedLabel.text = timeFormatter.string(from: elapsedTime)
        
        playbackSlider.minimumValue = 0
        playbackSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
        playbackSlider.value = Float(elapsedTime)
        
        if let totalTime = audioPlayer?.duration {
            let remainingTime = totalTime - elapsedTime
            timeRemainingLabel.text = timeFormatter.string(from: remainingTime)
        } else if let recordingTime = audioRecorder?.currentTime {
            timeRemainingLabel.text = timeFormatter.string(from: recordingTime)
        } else {
            timeRemainingLabel.text = timeFormatter.string(from: 0)
        }
        
        let recordButtonTitle = isRecording ? "⏹" : "⏺"
        recordStopButton.setTitle(recordButtonTitle, for: .normal)
        
        if !isPlaying && !isRecording {
            playPauseButton.isEnabled = true
            recordStopButton.isEnabled = true
        } else if isPlaying && !isRecording {
            playPauseButton.isEnabled = true
            recordStopButton.isEnabled = false
        } else if !isPlaying && isRecording {
            playPauseButton.isEnabled = false
            recordStopButton.isEnabled = true
        }
    }
    
    // Playback
    private func playPause() {
        if isPlaying {
            audioPlayer?.pause()
            cancelTimer()
            updateViews()
        } else {
            audioPlayer?.play()
            startTimer()
            updateViews()
        }
    }
    
    private func startTimer() {
        cancelTimer()
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(updateTimer(timer:)), userInfo: nil, repeats: true)
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func updateTimer(timer: Timer) {
        updateViews()
    }
    
    // Record
    private func record() {
        // Path to save in the documents direcgtory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Filename (ISO8601 format for time) .caf extension (core audio file)
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        
        // 2019-12-03T10:42:35-08:00.caf
        let file = documentsDirectory.appendingPathComponent(name).appendingPathExtension("caf")
        
        print("Record URL: \(file)")
        // Audio Quality 44.1KHz
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        // Start a recoding
        audioRecorder = try! AVAudioRecorder(url: file, format: format)
        audioRecorder?.delegate = self
        audioRecorder?.record()
        cancelTimer()
        startTimer()
    }
    
    private func stopRecodring() {
        audioRecorder?.stop()
        audioRecorder = nil
        cancelTimer()
    }
    
    private func toggleRecord() {
        if isRecording {
            stopRecodring()
        } else {
            record()
        }
    }
    
    
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        playPause()
    }
    @IBAction func recordStopButtonPressed(_ sender: Any) {
        toggleRecord()
    }
    

}

extension VoiceRecordViewController: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio playback error: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()   // TODO: is this on the main thread?
        // TODO: Cancel timer?
    }
}

extension VoiceRecordViewController: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio record error: \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag == true {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: recorder.url)
                postController.addVoiceComment(with: recorder.url, to: &self.post!)
            } catch {
                print("Error while finishing recording: \(error)")
            }
        }
    }
}

