//
//  Array+Extensions.swift
//  pitchTrack
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

extension Array where Element:Comparable {
  static func fromUnsafePointer(_ data: UnsafePointer<Element>, count: Int) -> [Element] {
    let buffer = UnsafeBufferPointer(start: data, count: count)
    return Array(buffer)
  }

  var maxIndex: Int? {
    return self.enumerated().max(by: {$1.element > $0.element})?.offset
  }
}
