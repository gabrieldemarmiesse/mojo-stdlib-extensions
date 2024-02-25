from ...datetime.v2 import time, timezone, timedelta
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...builtins import Optional, ___eq__


def test_time_creation():
    t = time(12, 30, 0)
    assert_equal(t.hour, 12)
    assert_equal(t.minute, 30)
    assert_equal(t.second, 0)
    assert_equal(t.microsecond, 0)
    assert_true(t.tzinfo is None, "tzinfo is None")
    assert_equal(t.fold, 0)


def test_time_repr():
    var utc = timezone(timedelta(0))
    assert_equal(time(12, 30, 0).__repr__(), "datetime.time(12, 30)")
    assert_equal(
        time(12, 30, 0, tzinfo=utc).__repr__(),
        "datetime.time(12, 30, tzinfo=datetime.timezone.utc)",
    )
    assert_equal(time(12, 30, 0, fold=1).__repr__(), "datetime.time(12, 30, fold=1)")
    assert_equal(
        time(12, 30, 0, tzinfo=utc, fold=1).__repr__(),
        "datetime.time(12, 30, tzinfo=datetime.timezone.utc, fold=1)",
    )
    assert_equal(time(12, 30, 8).__repr__(), "datetime.time(12, 30, 8)")
    assert_equal(
        time(12, 30, 8, tzinfo=utc).__repr__(),
        "datetime.time(12, 30, 8, tzinfo=datetime.timezone.utc)",
    )
    assert_equal(time(12, 30, 8, 4).__repr__(), "datetime.time(12, 30, 8, 4)")
    assert_equal(
        time(12, 30, 8, 4, tzinfo=utc).__repr__(),
        "datetime.time(12, 30, 8, 4, tzinfo=datetime.timezone.utc)",
    )
    assert_equal(
        time(12, 30, 8, 4, fold=1).__repr__(), "datetime.time(12, 30, 8, 4, fold=1)"
    )
    assert_equal(
        time(12, 30, 8, 4, tzinfo=utc, fold=1).__repr__(),
        "datetime.time(12, 30, 8, 4, tzinfo=datetime.timezone.utc, fold=1)",
    )


def test_utcoffset():
    var t = time(12, 30, 0)
    assert_true(t.utcoffset() is None, "utcoffset is None")
    var utc = timezone(timedelta(0))
    assert_true(
        t.replace(tzinfo=utc).utcoffset() is not None, "utcoffset should not be None"
    )
    assert_true(
        t.replace(tzinfo=utc).utcoffset().value() == timedelta(0), "utcoffset is 0"
    )


def run_tests():
    test_time_creation()
    test_time_repr()
    test_utcoffset()
