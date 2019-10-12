//
//  Segment.swift
//  Pitch Tracker
//
//  Created by Raghavasimhan Sankaranarayanan on 10/12/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import Foundation

public struct Segment {
    var startTime:Double
    var note:Double
    var length:Double
    
    // MARK: - Initialization
    init(startTime: Double, note:Double, length:Double) {
        self.startTime = startTime
        self.note = note
        self.length = length
    }
}
