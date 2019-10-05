//
//  YINEstimator.swift
//  pitchTrack
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import Foundation

final class YINEstimator: Estimator {
  let transformer: Transformer = YINTransformer()
  let threshold: Float = 0.05

  func estimateFrequency(sampleRate: Float, buffer: Buffer) throws -> Float {
    var elements = buffer.elements
    YINUtil.cumulativeDifference(yinBuffer: &elements)

    let tau = YINUtil.absoluteThreshold(yinBuffer: elements, withThreshold: threshold)
    var f0: Float

    if tau != 0 {
      let interpolatedTau = YINUtil.parabolicInterpolation(yinBuffer: elements, tau: tau)
      f0 = sampleRate / interpolatedTau
    } else {
      f0 = 0.0
    }

    return f0
  }
}
