"""Current upstream diagnostic repros. Tests assert observed defects, not fixes.

Generated data only. No ARHMM/PCA training, recordings, or biological groups.
"""
from collections import OrderedDict
import numpy as np
import pandas as pd
import pytest


def test_background_treats_zero_dropout_as_depth(tmp_path, monkeypatch):
    from moseq2_extract.extract import proc
    images = np.full((3, 8, 8), 700, dtype=np.uint16)
    images[:2, 2:6, 2:6] = 0
    monkeypatch.setattr(proc.moseq2_extract.io.video, 'load_movie_data', lambda path, idx, **kw: images[idx])
    monkeypatch.setattr(proc, 'write_image', lambda *a, **kw: None)
    value = proc.get_bground_im_file('synthetic-unused', frame_stride=1, med_scale=1,
                                    output_dir=str(tmp_path), finfo={'nframes': 3, 'dims': (8, 8)})
    assert value[3, 3] == 0  # missing zero depths dominate valid 700 mm


def test_noncount_statistic_missing_values_become_zero():
    from moseq2_viz.model.stat import get_session_mean_df
    frame = pd.DataFrame([
        {'group': 'synthetic-a', 'uuid': 'a', 'syllable': 0, 'height': 50., 'usage': 1.},
        {'group': 'synthetic-b', 'uuid': 'b', 'syllable': 1, 'height': 60., 'usage': 1.}])
    result = get_session_mean_df(frame, statistic='height', max_syllable=2)
    assert result.loc['synthetic-a', 'a'][1] == 0
    assert result.loc['synthetic-b', 'b'][0] == 0


def test_whitening_training_parameters_depend_on_heldout_values():
    from moseq2_model.helpers.data import prepare_model_metadata
    config = dict(kappa=100, hold_out=True, nfolds=2, hold_out_seed=0, ncpus=1,
                  gamma=1, alpha=1, nlags=1, robust=False, max_states=2,
                  separate_trans=False, whiten='all', noise_level=0)
    def prepare(offset):
        rng = np.random.RandomState(17)
        data = OrderedDict(a=rng.normal(size=(20, 2)),
                           b=rng.normal(size=(20, 2)) + offset)
        return prepare_model_metadata(data, {'groups': {'a': 'synthetic', 'b': 'synthetic'}}, dict(config))
    first, second = prepare(100), prepare(1000)
    assert first[2] == second[2] == ['a']
    assert first[3] == second[3] == ['b']
    assert not np.array_equal(first[0]['a'], second[0]['a'])


def test_legacy_conversion_rejects_multirow_legacy_arrays():
    from moseq2_viz.scalars.util import convert_legacy_scalars
    values = {key: np.ones(2) for key in ['centroid_x', 'centroid_y', 'width', 'length', 'area', 'height_ave', 'angle']}
    with pytest.raises(ValueError, match='truth value'):
        convert_legacy_scalars(values, force=True)


def test_undefined_transition_entropy_has_nan():
    from moseq2_viz.info.util import transition_entropy
    result = transition_entropy([np.zeros(10, dtype=int)], truncate_syllable=2, relabel_by=None)
    assert np.isnan(result).any()


def test_public_scalar_average_accepts_invalid_mixed_units():
    from moseq2_viz.scalars.util import get_scalar_triggered_average
    result = get_scalar_triggered_average({'synthetic': {'velocity_3d_px': np.arange(12.)}},
                                        {'synthetic': np.tile([0, 0, 1, 1], 3)},
                                        include_keys=['velocity_3d_px'], max_syllable=2, nlags=1)
    assert 'velocity_3d_px' in result
