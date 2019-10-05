//
//  Transformer.swift
//  pitchTrack
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import AVFoundation

protocol Transformer {
  func transform(buffer: AVAudioPCMBuffer) throws -> Buffer
}
