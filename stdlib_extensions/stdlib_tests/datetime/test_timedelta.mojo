from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...datetime import timedelta


def test_timedelta():
    assert_equal(timedelta().total_seconds(), 0)

    divided = timedelta(hours=1) / timedelta(seconds=1)
    assert_equal(String(divided), "3600.0")


def test_timedelta_constructor():
    one_min = timedelta(minutes=1)
    assert_equal(one_min.seconds, 60)
    assert_equal(one_min.days, 0)
    assert_equal(one_min.microseconds, 0)

    half_a_min = timedelta(minutes=0.5, use_floats=True)
    assert_equal(half_a_min.seconds, 30)
    assert_equal(half_a_min.days, 0)
    assert_equal(half_a_min.microseconds, 0)

    one_day_and_a_half = timedelta(days=1.5, use_floats=True)
    assert_equal(one_day_and_a_half.days, 1)
    assert_equal(one_day_and_a_half.seconds, 43200)
    assert_equal(one_day_and_a_half.microseconds, 0)

    two_weeks = timedelta(weeks=2)
    assert_equal(two_weeks.days, 14)
    assert_equal(two_weeks.seconds, 0)
    assert_equal(two_weeks.microseconds, 0)


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
    test_timedelta_constructor()
