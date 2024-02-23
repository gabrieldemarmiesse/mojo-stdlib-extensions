from ...datetime.v2 import time, timezone, timedelta
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...builtins._types import Optional


def test_timezone_utc():
    a = timezone(timedelta(0))
    assert_equal(str(a), "UTC")
    # TODO: use when https://github.com/modularml/mojo/issues/1787 is fixed
    # assert_equal(timezone.utc, timezone(timedelta(0)))


def test_timezone_equality():
    assert_true(
        timezone(offset=timedelta(0)) == timezone(timedelta(0)),
        "timezones should be equal",
    )
    assert_true(
        timezone(offset=timedelta(0), name=String("dodo")) == timezone(timedelta(0)),
        "timezones should be equal",
    )
    assert_true(
        timezone(offset=timedelta(hours=-4), name=String("dodo"))
        == timezone(timedelta(hours=-4)),
        "timezones should be equal",
    )


def test_timezone_repr():
    assert_equal(
        timezone(offset=timedelta(hours=-4), name=String("dodo")).__repr__(),
        "datetime.timezone(datetime.timedelta(days=-1, seconds=72000), 'dodo')",
    )


def test_hash():
    assert_equal(hash(timezone(timedelta(0))), hash(timezone(timedelta(0))))
    assert_equal(
        hash(timezone(timedelta(0), name=String("dodo"))), hash(timezone(timedelta(0)))
    )

    assert_false(
        hash(timezone(timedelta(0))) == hash(timezone(timedelta(hours=1))),
        "timezones should not have the same hash",
    )
    assert_false(
        hash(timezone(timedelta(0), name=String("dodo")))
        == hash(timezone(timedelta(hours=1), name=String("dodo"))),
        "timezones should not have the same hash",
    )


def test_tzname():
    assert_equal(timezone(timedelta(0)).tzname(None), "UTC")
    assert_equal(timezone(timedelta(0), name=String("dodo")).tzname(None), "dodo")
    assert_equal(timezone(timedelta(hours=2)).tzname(None), "UTC+02:00")
    assert_equal(
        timezone(timedelta(hours=2, minutes=6, seconds=8, milliseconds=444)).tzname(
            None
        ),
        "UTC+02:06:08.444000",
    )

    assert_equal(str(timezone(timedelta(0))), "UTC")
    assert_equal(str(timezone(timedelta(0), name=String("dodo"))), "dodo")
    assert_equal(str(timezone(timedelta(hours=2))), "UTC+02:00")
    assert_equal(
        str(timezone(timedelta(hours=2, minutes=6, seconds=8, milliseconds=444))),
        "UTC+02:06:08.444000",
    )


def run_tests():
    test_timezone_utc()
    test_timezone_equality()
    test_timezone_repr()
    test_hash()
    test_tzname()
