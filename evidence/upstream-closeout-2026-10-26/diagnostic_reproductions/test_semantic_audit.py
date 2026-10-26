"""Discriminating synthetic controls for historical inference limits."""
import cv2
import numpy as np

def translated_equal(a, b):
    # Exact, zero-padded integer translations; no interpolation/tolerance search.
    for dy in [-1, 0, 1]:
        for dx in [-1, 0, 1]:
            shifted = np.zeros_like(a)
            ys, ye = max(0, dy), min(a.shape[0], a.shape[0] + dy)
            xs, xe = max(0, dx), min(a.shape[1], a.shape[1] + dx)
            shifted[ys:ye, xs:xe] = a[ys-dy:ye-dy, xs-dx:xe-dx]
            if np.array_equal(shifted, b):
                return True
    return False

def test_byte_inequality_does_not_prove_wrong_orientation():
    reference = np.zeros((80, 80), dtype=np.uint8)
    reference[17:26, 24:28] = 70
    reference[23:26, 24:40] = 40
    reference[40:44, 51:59] = 90
    corrected = np.rot90(reference, 2)
    render = cv2.warpAffine(corrected, cv2.getRotationMatrix2D((40, 40), 180, 1), (80, 80))
    assert not np.array_equal(render, reference)
    assert translated_equal(render, reference)
    assert not translated_equal(render, np.rot90(reference, 2))

def test_modern_scipy_resolves_stats_without_the_old_extra_import():
    import scipy.signal
    import scipy
    assert callable(scipy.stats.zscore)
