from ...datetime.v2 import time, timezone, timedelta
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...builtins import Optional


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
    assert_true(
        time(12, 30, 0, tzinfo=timezone(timedelta(0))).utcoffset() is not None,
        "utcoffset should not be None",
    )
    assert_true(
        time(12, 30, 0, tzinfo=timezone(timedelta(0))).utcoffset().value()
        == timedelta(0),
        "utcoffset is 0",
    )
    assert_true(
        time(12, 30, 0, tzinfo=timezone(timedelta(hours=-4))).utcoffset().value()
        == timedelta(hours=-4),
        "utcoffset is 0",
    )


def test_comparison_without_timezone():
    assert_true(time(12, 30, 0) == time(12, 30, 0), "the two times are equal")
    assert_false(time(12, 30, 0) == time(12, 30, 1), "the two times are not equal")

    assert_true(time(12, 30, 0) != time(12, 30, 1), "the two times are not equal")
    assert_false(time(12, 30, 0) != time(12, 30, 0), "the two times are equal")

    assert_true(
        time(12, 30, 0) < time(12, 30, 1), "the first time is less than the second"
    )
    assert_false(
        time(12, 30, 1) < time(12, 30, 0), "the first time is not less than the second"
    )

    assert_true(
        time(12, 30, 0) <= time(12, 30, 1), "the first time is less than the second"
    )
    assert_false(
        time(12, 30, 1) <= time(12, 30, 0), "the first time is not less than the second"
    )
    assert_true(
        time(12, 30, 1) <= time(12, 30, 1),
        "the first time is less or equal to the second",
    )

    assert_true(
        time(12, 30, 1) > time(12, 30, 0), "the first time is greater than the second"
    )
    assert_false(
        time(12, 30, 0) > time(12, 30, 1),
        "the first time is not greater than the second",
    )

    assert_true(
        time(12, 30, 1) >= time(12, 30, 0), "the first time is greater than the second"
    )
    assert_false(
        time(12, 30, 0) >= time(12, 30, 1),
        "the first time is not greater than the second",
    )
    assert_true(
        time(12, 30, 1) >= time(12, 30, 1),
        "the first time is greater or equal to the second",
    )


def test_dst():
    assert_true(time(12, 30, 0).dst() is None, "dst is None")
    assert_true(
        time(12, 30, 0, tzinfo=timezone(timedelta(0))).dst() is None,
        "dst should be None",
    )
    assert_true(
        time(12, 30, 0, tzinfo=timezone(timedelta(hours=-4))).dst() is None,
        "dst is None",
    )


def test_hash_time():
    var t1 = time(12, 30, 0)
    var t2 = time(12, 30, 0)
    assert_true(t1 == t2, "the two times are equal")
    assert_true(hash(t1) == hash(t2), "the two hashes are equal")


def test_hash_time_with_timezone():
    var t1 = time(12, 30, 0, tzinfo=timezone(timedelta(0)))
    var t2 = time(12, 30, 0, tzinfo=timezone(timedelta(0)))
    assert_true(t1 == t2, "the two times are equal")
    assert_true(hash(t1) == hash(t2), "the two hashes are equal")


def test_hash_time_with_different_timezones():
    var t1 = time(12, 30, 0, tzinfo=timezone(timedelta(0)))
    var t2 = time(12, 30, 0, tzinfo=timezone(timedelta(hours=-4, minutes=-3)))
    assert_false(t1 == t2, "the two times should not be equal")
    assert_false(hash(t1) == hash(t2), "the two hashes are not equal")


def test_hash_time_with_different_timezones_equal():
    var t1 = time(12, 30, 0, tzinfo=timezone(timedelta(0)))
    var t2 = time(8, 40, 0, tzinfo=timezone(timedelta(hours=-4, minutes=10)))
    assert_true(t1 == t2, "the two times are equal")
    assert_true(hash(t1) == hash(t2), "the two hashes should be equal")


def test_time_isoformat_default():
    assert_equal(time(12, 30, 0).isoformat(), "12:30:00")
    assert_equal(
        time(12, 30, 0, tzinfo=timezone(timedelta(0))).isoformat(), "12:30:00+00:00"
    )
    assert_equal(
        time(12, 30, 0, tzinfo=timezone(timedelta(hours=-4))).isoformat(),
        "12:30:00-04:00",
    )
    assert_equal(time(12, 30, 0, fold=1).isoformat(), "12:30:00")
    assert_equal(
        time(12, 30, 0, tzinfo=timezone(timedelta(0)), fold=1).isoformat(),
        "12:30:00+00:00",
    )
    assert_equal(
        time(12, 30, 0, 100, tzinfo=timezone(timedelta(hours=-4)), fold=1).isoformat(),
        "12:30:00.000100-04:00",
    )


def test_isoformat_with_different_timespec():
    t = time(12, 30, 8, 108, tzinfo=timezone(timedelta(hours=-4)), fold=1)
    assert_equal(t.isoformat(), "12:30:08.000108-04:00")
    assert_equal(t.isoformat("hours"), "12-04:00")
    assert_equal(t.isoformat("minutes"), "12:30-04:00")
    assert_equal(t.isoformat("seconds"), "12:30:08-04:00")
    assert_equal(t.isoformat("milliseconds"), "12:30:08.000-04:00")
    assert_equal(t.isoformat("microseconds"), "12:30:08.000108-04:00")


def test_str_function_on_time():
    """Should return isoformat."""
    assert_equal(
        str(time(12, 30, 0, 105, tzinfo=timezone(timedelta(hours=-4)), fold=1)),
        "12:30:00.000105-04:00",
    )
    assert_equal(str(time(12, 30, 0)), "12:30:00")


def test_time_strftime_all_values_filled():
    t = time(
        12,
        30,
        0,
        105,
        tzinfo=timezone(timedelta(hours=-4, minutes=1, seconds=8, microseconds=33)),
        fold=1,
    )
    format = "%a|%A|%w|%d|%b|%B|%m|%y|%Y|%H|%I|%p|%M|%S|%f|%z|%Z|%j|%U|%W|%c|%x|%X|%G|%u|%V|%%|%:z"
    expected = (
        "Mon|Monday|1|01|Jan|January|01|00|1900|12|12|PM|30|00|000105|-035851.999967|UTC-03:58:51.999967|001|00|01|Mon"
        " Jan  1 12:30:00 1900|01/01/00|12:30:00|1900|1|01|%|-03:58:51.999967"
    )
    assert_equal(t.strftime(format), expected)


def test_time_strftime_simple_time():
    t = time(1, 3)
    format = "%a|%A|%w|%d|%b|%B|%m|%y|%Y|%H|%I|%p|%M|%S|%f|%z|%Z|%j|%U|%W|%c|%x|%X|%G|%u|%V|%%|%:z"
    expected = (
        "Mon|Monday|1|01|Jan|January|01|00|1900|01|01|AM|03|00|000000|||001|00|01|Mon"
        " Jan  1 01:03:00 1900|01/01/00|01:03:00|1900|1|01|%|"
    )
    assert_equal(t.strftime(format), expected)


def test_time_format_dunder_empty():
    # empty is the same as isoformat
    t = time(
        12,
        30,
        0,
        105,
        tzinfo=timezone(timedelta(hours=-4, minutes=1, seconds=8, microseconds=33)),
        fold=1,
    )
    assert_equal(t.__format__(""), t.isoformat())


def test_time_format_dunder_non_empty():
    # this should be the same as strftime
    t = time(
        1,
        59,
        59,
        999999,
        tzinfo=timezone(timedelta(hours=4, minutes=1, seconds=8, microseconds=33)),
        fold=1,
    )
    format = "%a|%A|%w|%d|%b|%B|%m|%y|%Y|%H|%I|%p|%M|%S|%f|%z|%Z|%j|%U|%W|%c|%x|%X|%G|%u|%V|%%|%:z"
    expected = (
        "Mon|Monday|1|01|Jan|January|01|00|1900|01|01|AM|59|59|999999|+040108.000033|UTC+04:01:08.000033|001|00|01|Mon"
        " Jan  1 01:59:59 1900|01/01/00|01:59:59|1900|1|01|%|+04:01:08.000033"
    )
    assert_equal(t.__format__(format), expected)


def run_tests():
    test_time_creation()
    test_time_repr()
    test_utcoffset()
    test_comparison_without_timezone()
    test_dst()
    test_hash_time()
    test_hash_time_with_timezone()
    test_hash_time_with_different_timezones()
    test_hash_time_with_different_timezones_equal()
    test_time_isoformat_default()
    test_isoformat_with_different_timespec()
    test_str_function_on_time()
    test_time_strftime_all_values_filled()
    test_time_strftime_simple_time()
    test_time_format_dunder_empty()
    test_time_format_dunder_non_empty()
