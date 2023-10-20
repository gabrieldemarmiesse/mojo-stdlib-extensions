from ...time import time_ns
from python import Python
from ..utils import assert_true


def test_time_ns():
    py_time_ns = Python.import_module("time").time_ns

    t1 = py_time_ns()
    t_mojo = time_ns()
    t2 = py_time_ns()

    assert_true(
        t1.to_float64().cast[DType.int64]() <= t_mojo,
        "time_ns() should return a value equal or above the previous python call",
    )
    assert_true(
        t_mojo <= t2.to_float64().cast[DType.int64](),
        "time_ns() should return a value equal or below the next python call",
    )


def run_tests():
    test_time_ns()
