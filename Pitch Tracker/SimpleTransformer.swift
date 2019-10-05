//
//  SimpleTransformer.swift
//  pitchTrack
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import AVFoundation

final class SimpleTransformer: Transformer {
  enum SimpleTransformerError: Error {
    case floatChannelDataIsNil
  }

  func transform(buffer: AVAudioPCMBuffer) throws -> Buffer {
    guard let pointer = buffer.floatChannelData else {
      throw SimpleTransformerError.floatChannelDataIsNil
    }

    let elements = Array.fromUnsafePointer(pointer.pointee, count:Int(buffer.frameLength))
    return Buffer(elements: elements)
  }
}
