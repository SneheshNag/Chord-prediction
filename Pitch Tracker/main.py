from NoteSegmentation import NoteSegmenter
import numpy as np
import pandas as pd

def main(request):
    request_json = request.get_json()
    if request_json and 'pitch' in request_json:
        pitches = np.array(request_json['pitch'])
        segmenter = NoteSegmenter()
        segments = segmenter.segment(pitches)
        segments = pd.Series(segments).to_json(orient='values')
        
    else:
        segments = pd.Series([]).to_json(orient='values')
    
    return segments
