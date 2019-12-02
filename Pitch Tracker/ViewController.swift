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
    
    @IBOutlet var keyPicker: UIPickerView!
    
    var pitches:[Double] = []
    var levels:[Double] = []
    
    var keys = ["C", "D", "E", "F", "G", "A", "B"]
    var mode = ["major", "minor"]
    
    var selectedScale = [0.0, 0.0]
    
    var startTime = CFAbsoluteTimeGetCurrent()
    
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
                startTime = CFAbsoluteTimeGetCurrent()
                sendPitchesToServer(pitches: pitches)
                pitches = []
                levels = []
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Play with Shimon"
        keyPicker.delegate = self
        keyPicker.dataSource = self
    }
    
    func sendPitchesToServer( pitches: [Double]) {
        let parameters: [String: [Double]] = [
            "pitch": pitches,
            "level": levels,
            "key": selectedScale
        ]
        
        print(selectedScale)

        AF.request("https://us-central1-api-test-256817.cloudfunctions.net/postPitch", method: .post, parameters: parameters, encoding:
        JSONEncoding.default).responseJSON { response in
            switch response.result {
                case .success:
                    print("time elapsed: \(CFAbsoluteTimeGetCurrent() - self.startTime) sec")
                    let returned = response.value! as! [[Double]]
                    print(returned)

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
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveLevel level: Double) {
        levels.append(level)
    }

  func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
    print(error)
  }

  public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
    pitches.append(0)
    levels.append(0)
  }
}

extension ViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return keys.count
        }
        return mode.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return keys[row]
        } else {
            return mode[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedScale[component] = Double(row)
    }
    
}
