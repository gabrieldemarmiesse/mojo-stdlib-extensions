from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...datetime import (
    datetime,
    datetime_min,
    timedelta,
    datetime_now,
    datetime_max,
)
from python import Python, PythonObject


def py_datetime() -> PythonObject:
    return Python.import_module("datetime").datetime


def py_timedelta() -> PythonObject:
    return Python.import_module("datetime").timedelta


def test_datetime_now():
    let now = datetime_now()
    now.__str__()
    now.__repr__()
    now.year()
    now.month()
    now.day()
    now.hour()
    now.second()
    now.microsecond()

    let time_elapsed = datetime_now() - now

    assert_equal(time_elapsed.total_seconds(), 0)  # gotta go fast


def test_datetime_min_max():
    assert_equal(datetime_min().__str__(), py_datetime().min.__str__().to_string())
    assert_equal(datetime_max().__str__(), py_datetime().max.__str__().to_string())


def test_datetime_timedelta_interaction():
    var mojo_dt = datetime_min()
    var py_dt = py_datetime().min

    # we apply the same transformation to both and see if the representation
    # is always the same, python is our reference

    for i in range(10_000):
        mojo_dt = mojo_dt + timedelta(0, 0, i * 100_000)
        py_dt = py_dt + py_timedelta()(0, 0, i * 100_000)
        assert_equal(mojo_dt.__str__(), py_dt.__str__().to_string())
        assert_equal(mojo_dt.__repr__(), py_dt.__repr__().to_string())


def run_tests():
    test_datetime_now()
    test_datetime_min_max()
    test_datetime_timedelta_interaction()
