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
    
    lazy var segmentationEngine: SegmentationEngine = { [weak self] in
        let engine = SegmentationEngine(delegate: self)
        return engine
    }()
    
    @IBAction func btn(_ sender: UIButton) {
        let text = segmentationEngine.active
        ? NSLocalizedString("Start", comment: "").uppercased()
        : NSLocalizedString("Stop", comment: "").uppercased()

        sender.setTitle(text, for: .normal)

        segmentationEngine.active ? segmentationEngine.stop() : segmentationEngine.start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tuner".uppercased()
        view.backgroundColor = UIColor.white
        noteLabel.text = "--"
    }
}

extension ViewController: SegmentationEngineDelegate {
    func segmentationEngine(_ segmentationEngine: SegmentationEngine, didReceiveSegment segment: Segment) {
        // Handle segments
    }
    
    func segmentationEngine(_ segmentationEngine: SegmentationEngine, didReceiveError error: Error) {
        // Handle error
    }
    
    
}
