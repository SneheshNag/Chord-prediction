//
//  PitchEngine.swift
//  pitchTrack
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import AVFoundation

public protocol PitchEngineDelegate: class {
  func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Double)
    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveLevel level: Double)
  func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error)
  func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine)
}

public final class PitchEngine {
  public enum Error: Swift.Error {
    case recordPermissionDenied
  }

  public let bufferSize: AVAudioFrameCount
  public private(set) var active = false
  public weak var delegate: PitchEngineDelegate?

  private let estimator: Estimator
  private let signalTracker: SignalTracker
  private let queue: DispatchQueue

  public var mode: SignalTrackerMode {
    return signalTracker.mode
  }

  public var levelThreshold: Float? {
    get {
      return self.signalTracker.levelThreshold
    }
    set {
      self.signalTracker.levelThreshold = newValue
    }
  }

  public var signalLevel: Float {
    return signalTracker.averageLevel ?? 0.0
  }

  // MARK: - Initialization
  public init(config: Config = Config(),
              signalTracker: SignalTracker? = nil,
              delegate: PitchEngineDelegate? = nil) {
    bufferSize = config.bufferSize

    estimator = YINEstimator()

    self.signalTracker = InputSignalTracker(bufferSize: bufferSize)
    
//    if let signalTracker = signalTracker {
//      self.signalTracker = signalTracker
//    } else {
//      if let audioUrl = config.audioUrl {
//        self.signalTracker = OutputSignalTracker(audioUrl: audioUrl, bufferSize: bufferSize)
//      } else {
//        self.signalTracker = InputSignalTracker(bufferSize: bufferSize)
//      }
//    }

    self.queue = DispatchQueue(label: "BeethovenQueue", attributes: [])
    self.signalTracker.delegate = self
    self.delegate = delegate
  }

  // MARK: - Processing
  public func start() {
    guard mode == .playback else {
      activate()
      return
    }

    let audioSession = AVAudioSession.sharedInstance()

    switch audioSession.recordPermission {
    case AVAudioSessionRecordPermission.granted:
      activate()
    case AVAudioSessionRecordPermission.denied:
      DispatchQueue.main.async {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.openURL(settingsURL)
        }
      }
    case AVAudioSessionRecordPermission.undetermined:
      AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted  in
        guard let weakSelf = self else { return }

        guard granted else {
          weakSelf.delegate?.pitchEngine(weakSelf,
                                         didReceiveError: Error.recordPermissionDenied)
          return
        }

        DispatchQueue.main.async {
          weakSelf.activate()
        }
      }
    @unknown default:
        print("error")
    }
  }

  public func stop() {
    signalTracker.stop()
    active = false
  }

  func activate() {
    do {
      try signalTracker.start()
      active = true
    } catch {
      delegate?.pitchEngine(self, didReceiveError: error)
    }
  }
}

// MARK: - SignalTrackingDelegate
extension PitchEngine: SignalTrackerDelegate {
    public func signalTracker(_ signalTracker: SignalTracker, didReceiveLevel level: Float, atTime time: AVAudioTime) {
        self.delegate?.pitchEngine(self, didReceiveLevel: Double(level))
    }
    
  public func signalTracker(_ signalTracker: SignalTracker,
                            didReceiveBuffer buffer: AVAudioPCMBuffer,
                            atTime time: AVAudioTime) {

      queue.async { [weak self] in
        guard let `self` = self else { return }
        do {
          let transformedBuffer = try self.estimator.transformer.transform(buffer: buffer)
          let frequency = try self.estimator.estimateFrequency(
            sampleRate: Float(time.sampleRate),
            buffer: transformedBuffer)

          DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.pitchEngine(self, didReceivePitch: Double(frequency))
          }
        } catch {
          DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.pitchEngine(self, didReceiveError: error)
          }
        }
    }
  }

  public func signalTrackerWentBelowLevelThreshold(_ signalTracker: SignalTracker) {
    DispatchQueue.main.async {
      self.delegate?.pitchEngineWentBelowLevelThreshold(self)
    }
  }
}
