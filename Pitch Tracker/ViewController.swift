//
//  ViewController.swift
//  Pitch Tracker
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var noteLabel: UILabel!
    
    var str_pitch = "--" {
        didSet {
            noteLabel.text = str_pitch
        }
    }
    
    lazy var pitchEngine: PitchEngine = { [weak self] in
        let config = Config(estimationStrategy: .yin)
        let pitchEngine = PitchEngine(config: config, delegate: self)
        pitchEngine.levelThreshold = -30.0
        return pitchEngine
    }()
    
    @IBAction func btn(_ sender: UIButton) {
        let text = pitchEngine.active
        ? NSLocalizedString("Start", comment: "").uppercased()
        : NSLocalizedString("Stop", comment: "").uppercased()

        sender.setTitle(text, for: .normal)

        pitchEngine.active ? pitchEngine.stop() : pitchEngine.start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tuner".uppercased()
        view.backgroundColor = UIColor.white
        noteLabel.text = "--"
    }

}

// MARK: - PitchEngineDelegate
extension ViewController: PitchEngineDelegate {
  func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Double) {
    str_pitch = "\(pitch)"

    print(str_pitch)
  }

  func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
    print(error)
  }

  public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
    str_pitch = "--"
  }
}
