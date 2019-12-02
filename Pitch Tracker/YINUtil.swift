//
//  YINUtil.swift
//  pitchTrack
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import Accelerate

final class YINUtil {
  class func differenceA(buffer: [Float]) -> [Float] {
    let bufferHalfCount = buffer.count / 2
    var resultBuffer = [Float](repeating:0.0, count:bufferHalfCount)
    var tempBuffer = [Float](repeating:0.0, count:bufferHalfCount)
    var tempBufferSq = [Float](repeating:0.0, count:bufferHalfCount)
    let len = vDSP_Length(bufferHalfCount)
    var vSum: Float = 0.0

    for tau in 0 ..< bufferHalfCount {
      let bufferTau = UnsafePointer<Float>(buffer).advanced(by: tau)
      // do a diff of buffer with itself at tau offset
      vDSP_vsub(buffer, 1, bufferTau, 1, &tempBuffer, 1, len)
      // square each value of the diff vector
      vDSP_vsq(tempBuffer, 1, &tempBufferSq, 1, len)
      // sum the squared values into vSum
      vDSP_sve(tempBufferSq, 1, &vSum, len)
      // store that in the result buffer
      resultBuffer[tau] = vSum
    }

    return resultBuffer
  }

  class func cumulativeDifference(yinBuffer: inout [Float]) {
    yinBuffer[0] = 1.0

    var runningSum: Float = 0.0

    for tau in 1 ..< yinBuffer.count {
      runningSum += yinBuffer[tau]

      if runningSum == 0 {
        yinBuffer[tau] = 1
      } else {
        yinBuffer[tau] *= Float(tau) / runningSum
      }
    }
  }

  class func absoluteThreshold(yinBuffer: [Float], withThreshold threshold: Float) -> Int {
    var tau = 2
    var minTau = 0
    var minVal: Float = 1000.0

    while tau < yinBuffer.count {
      if yinBuffer[tau] < threshold {
        while (tau + 1) < yinBuffer.count && yinBuffer[tau + 1] < yinBuffer[tau] {
          tau += 1
        }
        return tau
      } else {
        if yinBuffer[tau] < minVal {
          minVal = yinBuffer[tau]
          minTau = tau
        }
      }
      tau += 1
    }

    if minTau > 0 {
      return -minTau
    }

    return 0
  }

  class func parabolicInterpolation(yinBuffer: [Float], tau: Int) -> Float {
    guard tau != yinBuffer.count else {
      return Float(tau)
    }

    var betterTau: Float = 0.0

    if tau > 0  && tau < yinBuffer.count - 1 {
      let s0 = yinBuffer[tau - 1]
      let s1 = yinBuffer[tau]
      let s2 = yinBuffer[tau + 1]

      var adjustment = (s2 - s0) / (2.0 * (2.0 * s1 - s2 - s0))

      if abs(adjustment) > 1 {
        adjustment = 0
      }

      betterTau = Float(tau) + adjustment
    } else {
      betterTau = Float(tau)
    }

    return abs(betterTau)
  }

  class func sumSquare(yinBuffer: [Float], start: Int, end: Int) -> Float {
    var out: Float = 0.0

    for i in start ..< end {
      out += yinBuffer[i] * yinBuffer[i]
    }

    return out
  }
}
