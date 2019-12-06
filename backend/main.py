from NoteSegmentation import NoteSegmenter
import numpy as np
import pandas as pd
from google.cloud import storage
from keras.models import load_model

model = None

def download_blob(bucket_name, source_blob_name, destination_file_name):
    """Downloads a blob from the bucket."""
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(source_blob_name)
    
    blob.download_to_filename(destination_file_name)

    print('Blob {} downloaded to {}.'.format(
        source_blob_name,
        destination_file_name))
    
def main(request):
    global model
    if model is None:
        download_blob('blstm_data', 'model_15epochs_4notes.h5', '/tmp/model_15epochs.h5')
        model = load_model('/tmp/model_15epochs.h5')
    class_names = ['C0', 'Db', 'D0', 'Eb', 'E0', 'F0', 'F#', 'G0', 'Ab', 'A0', 'Bb', 'B0']
    request_json = request.get_json()
    
    chords = []
    
    request_json = request.get_json()
    if request_json and 'pitch' in request_json and 'level' in request_json:
        pitches = np.array(request_json['pitch'])
        levels = np.array(request_json['level'])
        segmenter = NoteSegmenter()
        segments = segmenter.segment(pitches, levels)
        reminder = 4 - len(segments)%4
        segments = np.concatenate((segments, np.zeros(reminder)))
        segments = np.split(segments, len(segments)/4)
        segments = np.array(segments)
        for seg in segments:
            seg = seg.reshape((1, 4, 1))
            chords.append(np.argmax(model.predict(seg)))
        chords = pd.Series(np.array(chords)).to_json(orient='values')
    else:
        chords = pd.Series([]).to_json(orient='values')
    
    return chords
