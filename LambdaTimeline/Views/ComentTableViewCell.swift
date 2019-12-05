//
//  ComentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Gi Pyo Kim on 12/4/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

enum CommentType {
    case text
    case audio
}

class ComentTableViewCell: UITableViewCell {

    @IBOutlet weak var textCommentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var audioProgressSlider: UISlider!
    
    var commentType: CommentType?
    var comment: Comment? {
        didSet{
            setCommentType()
            setupPlayer()
            updateViews()
        }
    }
    
    // Audio Play
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    private func setCommentType() {
        if let text = comment?.text, !text.isEmpty {
            commentType = .text
            
            // hide audio comment UI
            playPauseButton.isHidden = true
            audioProgressSlider.isHidden = true
            timeElapsedLabel.isHidden = true
            timeRemainingLabel.isHidden = true
        } else {
            commentType = .audio
            
            // hide text comment UI
            textCommentLabel.isHidden = true
        }
    }
    
    private func setupPlayer() {
        if commentType == .audio {
            guard let audioString = comment?.audioURL, let audioURL = URL(string: audioString) else { return }

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioProgressSlider.minimumValue = 0
                audioProgressSlider.maximumValue = Float(audioPlayer!.duration)
            } catch {
                print("Invalid audioURL: \(audioURL)")
            }
        }
    }

    private func updateViews() {
        guard let comment = comment else { return }
        
        if commentType == .text {
            textCommentLabel.text = comment.text
            
        } else if commentType == .audio {
            playPauseButton.isSelected = isPlaying
            
            let elapsedTime = audioPlayer?.currentTime ?? 0
            timeElapsedLabel.text = timeFormatter.string(from: elapsedTime)
            
            audioProgressSlider.value = Float(elapsedTime)
            
            if let totalTime = audioPlayer?.duration {
                let remainingTime = totalTime - elapsedTime
                timeRemainingLabel.text = timeFormatter.string(from: remainingTime)
            } else {
                timeRemainingLabel.text = timeFormatter.string(from: 0)
            }
        }
        authorLabel.text = comment.author.displayName
    }
    @IBAction func playPauseButtonTabbed(_ sender: Any) {
        playPause()
    }
    
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
    
}
