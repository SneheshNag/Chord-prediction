//
//  ViewController.swift
//  Pitch Tracker
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet var noteLabel: UILabel!
    
    var pitches:[Double] = []
    
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
        
        if !pitchEngine.active {
            if !pitches.isEmpty {
                print("sending pitches to server")
                sendPitchesToServer(pitches: pitches)
                pitches = []
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Play with Shimon"
//        view.backgroundColor = UIColor.white
        noteLabel.isHidden = true
    }
    
    func sendPitchesToServer( pitches: [Double]) {
        let parameters: [String: [Double]] = [
            "pitch": pitches
        ]

        AF.request("https://us-central1-api-test-256817.cloudfunctions.net/postPitch", method: .post, parameters: parameters, encoding:
        JSONEncoding.default).responseJSON { response in
            switch response.result {
                case .success:
                    print(response.value! as! [Double])

                case .failure(let error):
                    print(error)
            }
        }
    }

}

// MARK: - PitchEngineDelegate
extension ViewController: PitchEngineDelegate {
  func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Double) {
    pitches.append(pitch)
  }

  func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
    print(error)
  }

  public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
    pitches.append(0)
//    print("below threshold")
  }
}
