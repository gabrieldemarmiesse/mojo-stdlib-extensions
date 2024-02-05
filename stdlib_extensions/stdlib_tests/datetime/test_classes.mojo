from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...datetime import datetime, timedelta, date, time
from python import Python, PythonObject
from ...builtins import hash


def py_datetime() -> PythonObject:
    return Python.import_module("datetime").datetime


def py_timedelta() -> PythonObject:
    return Python.import_module("datetime").timedelta


def py_time() -> PythonObject:
    return Python.import_module("datetime").time


def py_date() -> PythonObject:
    return Python.import_module("datetime").date


def test_datetime_now():
    let now = datetime.now()
    now.__str__()
    str(now)
    now.__repr__()
    now.year()
    now.month()
    now.day()
    now.hour()
    now.second()
    now.microsecond()

    let time_elapsed = datetime.now() - now

    assert_equal(time_elapsed.total_seconds(), 0)  # gotta go fast


def test_datetime_hash():
    let some_time = datetime(2020, 1, 1, 12, 30, 0)
    let some_time2 = datetime(2020, 1, 1, 12, 30, 0)

    let some_other_time = datetime(2020, 1, 1, 12, 30, 2)

    assert_equal(hash(some_time), hash(some_time2))
    assert_true(hash(some_time) != hash(some_other_time), "incorrect hash")
    assert_true(hash(some_time2) != hash(some_other_time), "incorrect hash 2")


def test_datetime_min_max():
    assert_equal(str(datetime.min()), str(py_datetime().min))
    assert_equal(str(datetime.max()), str(py_datetime().max))


def test_datetime_timedelta_interaction():
    var mojo_dt = datetime.min()
    var py_dt = py_datetime().min

    # we apply the same transformation to both and see if the representation
    # is always the same, python is our reference

    for i in range(1_000):
        mojo_dt = mojo_dt + timedelta(0, 0, i * 100_000)
        py_dt = py_dt + py_timedelta()(0, 0, i * 100_000)
        assert_equal(mojo_dt.__str__(), str(py_dt))
        assert_equal(mojo_dt.__repr__(), str(py_dt.__repr__()))


def test_time():
    let simple_time = time(12, 30, 0)
    assert_equal(simple_time.hour(), 12)
    assert_equal(simple_time.minute(), 30)
    assert_equal(simple_time.second(), 0)
    assert_equal(simple_time.microsecond(), 0)
    assert_equal(simple_time.__str__(), "12:30:00")
    assert_equal(simple_time.__repr__(), "datetime.time(12, 30)")
    assert_equal(
        simple_time.__str__(),
        str(Python.import_module("datetime").time(12, 30)),
    )

    assert_equal(time.min().__repr__(), "datetime.time(0, 0)")
    assert_equal(time.max().__repr__(), "datetime.time(23, 59, 59, 999999)")


def test_time_with_microseconds():
    let simple_time = time(12, 30, 0, 123456)
    assert_equal(simple_time.microsecond(), 123456)
    assert_equal(simple_time.__str__(), "12:30:00.123456")
    assert_equal(simple_time.__repr__(), "datetime.time(12, 30, 0, 123456)")


def run_tests():
    test_datetime_now()
    test_datetime_hash()
    test_datetime_min_max()
    test_datetime_timedelta_interaction()
    test_time()
    test_time_with_microseconds()
