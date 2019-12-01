//
//  PitchTracker.swift
//  pitchTrack
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import AVFoundation

public protocol SignalTrackerDelegate: class {
  func signalTracker(_ signalTracker: SignalTracker,
                     didReceiveBuffer buffer: AVAudioPCMBuffer,
                     atTime time: AVAudioTime)
    func signalTracker(_ signalTracker: SignalTracker,
    didReceiveLevel level: Float,
    atTime time: AVAudioTime)
  func signalTrackerWentBelowLevelThreshold(_ signalTracker: SignalTracker)
}

public enum SignalTrackerMode {
  case record, playback
}

public protocol SignalTracker: class {
  var mode: SignalTrackerMode { get }
  var levelThreshold: Float? { get set }
  var peakLevel: Float? { get }
  var averageLevel: Float? { get }
    var delegate: SignalTrackerDelegate? { get set }

  func start() throws
  func stop()
}
