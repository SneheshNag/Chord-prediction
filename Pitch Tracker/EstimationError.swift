//
//  EstimationError.swift
//  pitchTrack
//
//  Created by Raghavasimhan Sankaranarayanan on 10/2/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

public enum EstimationError: Error {
  case emptyBuffer
  case unknownMaxIndex
  case unknownLocation
  case unknownFrequency
}
