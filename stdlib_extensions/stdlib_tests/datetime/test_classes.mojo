from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...datetime import datetime, timedelta, date, time
from python import Python, PythonObject


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
    now.__repr__()
    now.year()
    now.month()
    now.day()
    now.hour()
    now.second()
    now.microsecond()

    let time_elapsed = datetime.now() - now

    assert_equal(time_elapsed.total_seconds(), 0)  # gotta go fast


def test_datetime_min_max():
    assert_equal(datetime.min().__str__(), str(py_datetime().min))
    assert_equal(datetime.max().__str__(), str(py_datetime().max))


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


def test_timedelta():
    assert_equal(timedelta().total_microseconds(), 0)
    assert_equal(timedelta().total_seconds(), 0)

    divided = timedelta(hours=1) / timedelta(seconds=1)
    assert_equal(String(divided), "3600.0")


def test_timedelta_repr():
    assert_equal(timedelta().__repr__(), "datetime.timedelta(0)")
    assert_equal(timedelta(days=1).__repr__(), "datetime.timedelta(days=1)")
    assert_equal(timedelta(minutes=1).__repr__(), "datetime.timedelta(seconds=60)")
    assert_equal(timedelta(seconds=1).__repr__(), "datetime.timedelta(seconds=1)")
    assert_equal(
        timedelta(microseconds=1).__repr__(), "datetime.timedelta(microseconds=1)"
    )
    assert_equal(
        timedelta(milliseconds=1).__repr__(), "datetime.timedelta(microseconds=1000)"
    )
    assert_equal(timedelta(hours=1).__repr__(), "datetime.timedelta(seconds=3600)")
    assert_equal(
        timedelta(days=1, hours=1).__repr__(),
        "datetime.timedelta(days=1, seconds=3600)",
    )
    assert_equal(
        timedelta(days=1, hours=1, minutes=1).__repr__(),
        "datetime.timedelta(days=1, seconds=3660)",
    )
    assert_equal(
        timedelta(days=1, hours=1, minutes=1, seconds=1).__repr__(),
        "datetime.timedelta(days=1, seconds=3661)",
    )
    assert_equal(
        timedelta(days=1, hours=1, minutes=1, seconds=1, microseconds=1).__repr__(),
        "datetime.timedelta(days=1, seconds=3661, microseconds=1)",
    )
    assert_equal(
        timedelta(
            days=1, hours=1, minutes=1, seconds=1, milliseconds=2, microseconds=1
        ).__repr__(),
        "datetime.timedelta(days=1, seconds=3661, microseconds=2001)",
    )


def test_date():
    let simple_date = date(2020, 1, 1)
    assert_equal(simple_date.year(), 2020)
    assert_equal(simple_date.month(), 1)
    assert_equal(simple_date.day(), 1)
    assert_equal(simple_date.__str__(), "2020-01-01")
    assert_equal(simple_date.__repr__(), "datetime.date(2020, 1, 1)")
    assert_equal(
        simple_date.__str__(),
        str(Python.import_module("datetime").date(2020, 1, 1)),
    )

    # we'd be extremely unlucky if this fails
    assert_equal(date.today().__str__(), str(py_date().today()))
    assert_equal(date.min().__repr__(), "datetime.date(1, 1, 1)")
    assert_equal(date.max().__repr__(), "datetime.date(9999, 12, 31)")


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
    test_datetime_min_max()
    test_datetime_timedelta_interaction()
    test_timedelta()
    test_timedelta_repr()
    test_date()
    test_time()
    test_time_with_microseconds()
