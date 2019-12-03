//
//  VoiceRecordViewController.swift
//  LambdaTimeline
//
//  Created by Gi Pyo Kim on 12/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class VoiceRecordViewController: UIViewController {
    
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var recordStopButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
    }
    @IBAction func recordStopButtonPressed(_ sender: Any) {
    }
    

}
