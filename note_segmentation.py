import numpy as np


class NoteSegmenter:
    """
    Note Segmentation Class
    """

    def convert_freq2midi(self, fInHz, fA4InHz: int = 440):
        """
        Converts frequency to MIDI note number.
        :param fInHz: input frequency
        :param fA4InHz: default 400Hz tuning
        :return: MIDI note number
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
g
    def segment(self, f0):
        """
        Converts freuqency estimates to detected onsets.
        :param f0: Series of frequency estimates
        :return: which frequency estimate is at a note onset
        """

        sig_value = np.abs(np.diff(f0))
        sig_value = np.concatenate(([0], sig_value), axis=0)

        sig_value[f0 == 0] = 0

        sig_value[self.convert_freq2midi(sig_value) > 1] = f0[self.convert_freq2midi(sig_value) > 1]

        return sig_value





