//
//  SegmentationEngine.swift
//  Pitch Tracker
//
//  Created by Raghavasimhan Sankaranarayanan on 10/12/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import Foundation

public protocol SegmentationEngineDelegate: class {
    func segmentationEngine(_ segmentationEngine: SegmentationEngine, didReceiveSegment segment: Segment)
    func segmentationEngine(_ segmentationEngine: SegmentationEngine, didReceiveError error:Error)
}

public final class SegmentationEngine {
    public weak var delegate: SegmentationEngineDelegate?
    public private(set) var active = false
    
    fileprivate var pitches = [Double]()
    
    lazy var pitchEngine: PitchEngine = { [weak self] in
        let config = Config(estimationStrategy: .yin)
        let pitchEngine = PitchEngine(config: config)
        pitchEngine.levelThreshold = -30.0
        return pitchEngine
    }()
    
    public init(delegate: SegmentationEngineDelegate?) {
        pitchEngine.delegate = self
        self.delegate = delegate
        // Init segmentor stuffs here
    }
    
    public func start() {
        pitchEngine.start()
        active = true
        // start segmentor
    }
    
    public func stop() {
        pitchEngine.stop()
        active = false
        //stop segmentor
    }
    
    fileprivate func computeSegments() {
        
    }
}

extension SegmentationEngine: PitchEngineDelegate {
    public func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Double) {
        pitches.append(pitch)
    }

    public func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
        delegate?.segmentationEngine(self, didReceiveError: error)
    }

    public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        print("level below threshold")
    }
}
