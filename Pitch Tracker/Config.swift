//
//  Config.swift
//  pitchTrack
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import AVFoundation

public struct Config {
  public let bufferSize: AVAudioFrameCount
  public let estimationStrategy: EstimationStrategy
  public let audioUrl: URL?

  // MARK: - Initialization
  public init(bufferSize: AVAudioFrameCount = 4096,
              estimationStrategy: EstimationStrategy = .yin,
              audioUrl: URL? = nil) {
      self.bufferSize = bufferSize
      self.estimationStrategy = estimationStrategy
      self.audioUrl = audioUrl
  }
}
