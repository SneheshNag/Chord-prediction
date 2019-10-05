//
//  YINTransformer.swift
//  pitchTrack
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import Foundation
import AVFoundation

final class YINTransformer: Transformer {
  func transform(buffer: AVAudioPCMBuffer) throws -> Buffer {
    let buffer = try SimpleTransformer().transform(buffer: buffer)
    let diffElements = YINUtil.differenceA(buffer: buffer.elements)
    return Buffer(elements: diffElements)
  }
}
