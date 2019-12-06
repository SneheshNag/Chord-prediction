# iOS App
Before running the iOS app, please [install Alamofire Framework](https://cocoapods.org/pods/Alamofire).

## Using the app
1) Select the scale you want to sing/play and record
2) Start recording by tapping "Start"
3) The chords with indexes are displayed after receiving from the backend

# Pitch Engine
The main ViewController acts as the delegate for the pitch engine. 
```swift
public protocol PitchEngineDelegate: class {
  func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Double) // Called when new pitch value is received
  func pitchEngine(_ pitchEngine: PitchEngine, didReceiveLevel level: Double) // Called when the corresponding instantaneous power level is received
  func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) // Called when there is an error in the signal flow path
  func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) // Called when the input audio goes below the set threshold
}
```

# NoteSegmentation.py
Note Segmenter python class.

## Usage
```python
from NoteSegmentation import NoteSegmenter

Ns = NoteSegmenter()

Ns.convert_freq2midi(fInHz): MIDI conversion tool #(https://www.audiocontentanalysis.org/code/helper-functions/frequency-to-midi-pitch-conversion-2/).
Ns.remove_outlier(pitch) #vibrato removal algorithm (deprecated).
Ns.segment(pitch, power) #using input pitch and power series, compute estimates for MIDI note numbers in audio.
```

# ChordPrediction.ipyndb

Jupyter Notebook containing data loading and conversion, as well as LSTM building and training.

## Usage
```bash
jupyter notebook #select ChordPrediction.ipyndb 
```

# Cloud function
Here is the link to the google cloud function. The storage bucket contains the trained model.
https://console.cloud.google.com/functions/list?project=api-test-256817

# Requirements - python
The requirements for the python scripts are in [requirements.txt](backend/requirements.txt)
