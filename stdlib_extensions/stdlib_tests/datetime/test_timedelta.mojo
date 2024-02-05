from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...datetime.v2._timedelta import timedelta


def test_timedelta():
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


def run_tests():
    test_timedelta()
    test_timedelta_repr()
