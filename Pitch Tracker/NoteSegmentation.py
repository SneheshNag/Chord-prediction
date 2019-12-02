import numpy as np
from scipy.signal import medfilt, find_peaks


class NoteSegmenter:
    """
    Note Segmentation Class
    """

    def convert_freq2midi(self, fInHz, fA4InHz: int = 440):
        """
        Converts frequency to MIDI note number.
        :param fInHz: input frequency.
        :param fA4InHz: default 400Hz tuning.
        :return: MIDI note number.
        """

        def convert_freq2midi_scalar(f, fA4InHz):
            if f <= 0:
                return 0
            else:
                return 69 + 12 * np.log2(f / fA4InHz)

        fInHz = np.asarray(fInHz)
        if fInHz.ndim == 0:
            return convert_freq2midi_scalar(fInHz, fA4InHz)

        midi = np.zeros(fInHz.shape)
        for k, f in enumerate(fInHz):
            midi[k] = convert_freq2midi_scalar(f, fA4InHz)

        return midi

    def remove_outlier(self, input: np.ndarray):
        """
        Removes pitch detector outliers, high and low.
        Source: USING A PITCH DETECTOR FOR ONSET DETECTION - Nick Collins, 2005
        :param input: pitch detection series to be processed.
        :return: modified input.
        """

        for jj in range(2, 7):
            for ii in range(len(input)-jj):
                testratio = input[ii] / (input[ii+jj] + 1e-5)
                if 0.945 < testratio:
                    for kk in range(jj-1):
                        mid = (input[ii]+input[ii+jj]) * 0.5
                        testratio2 = input[ii+kk] / mid
                        # print(testratio2)
                        if testratio2 > 1.059 or testratio < 0.945:
                            # print('t2', testratio2)
                            input[kk] = mid

        return input

    def segment(self, f0: np.ndarray, rms: np.ndarray):
        """
        Converts freuqency estimates to detected onsets.
        :param f0: Series of frequency estimates.
        :return: which frequency estimate is at a note onset.
        """

        # Remove Outliers / Vibrato
        f0 = self.remove_outlier(self.convert_freq2midi(f0))

        # Peak Picking

        # Pitch series: find starts and stops of notes
        sig_value = np.abs(np.diff(f0))
        sig_value = np.concatenate(([0], sig_value), axis=0)

        # limit to lowest bass singer note (E2)
        sig_value[sig_value < 40] = 0
        sig_idx = find_peaks(sig_value)[0]
        sig_idx = np.concatenate((sig_idx, f0.shape), axis=0)

        # RMS: find fluctuations within note
        rms = np.abs(np.diff(rms))
        rms = np.concatenate(([0], rms), axis=0)
        rms_idx = find_peaks(rms)[0]

        new_pitch = []

        # break rms peaks by pitch-derived starts/stops
        for i in range(len(sig_idx) - 1):
            new_pitch.append([])
            for j in range(sig_idx[i], sig_idx[i+1]):
                if j in rms_idx:
                    if f0[j] > 0:
                        new_pitch[-1].append(f0[j])
            new_pitch[-1] = np.array(new_pitch[-1])

        # segment rms peaks into discrete notes
        midi_series = []
        for i in new_pitch:

            if i.shape[0] > 0:

                # find notes at high rms peaks
                d_i = np.abs(np.diff(i))
                d_i = np.concatenate(([0], d_i), axis=0)
                d_idx = find_peaks(d_i)[0]
                note_series = np.round(medfilt(i[d_idx]))

                if note_series.shape[0] > 1:
                    # increment uniquely changing notes
                    midi_series.append(note_series[1])
                    if note_series.shape[0] > 2:
                        for j in range(2, note_series.shape[0]-1):
                            if midi_series[-1] != note_series[j]:
                                if note_series[j+1] != midi_series[-1]:
                                    midi_series.append(note_series[j])

        return np.array(midi_series)