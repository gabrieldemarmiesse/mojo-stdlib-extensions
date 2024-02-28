from ...datetime.v2 import datetime, timezone, timedelta
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal


def test_aliases():
    assert_equal(datetime.min.year, 1)
    assert_equal(datetime.max.year, 9999)

    # TODO: test resolution when it's possible, currently it's broken because of
    # https://github.com/modularml/mojo/issues/1787


def test_constructor_default():
    a = datetime(2020, 3, 4)
    assert_equal(a.year, 2020)
    assert_equal(a.month, 3)
    assert_equal(a.day, 4)
    assert_equal(a.hour, 0)
    assert_equal(a.minute, 0)
    assert_equal(a.second, 0)
    assert_equal(a.microsecond, 0)
    assert_true(a.tzinfo is None, "tzinfo should be None")
    assert_equal(a.fold, 0)


def test_constructor_all_values():
    a = datetime(2020, 3, 4, 5, 6, 7, 8, tzinfo=timezone(timedelta(hours=-1)), fold=1)
    assert_equal(a.year, 2020)
    assert_equal(a.month, 3)
    assert_equal(a.day, 4)
    assert_equal(a.hour, 5)
    assert_equal(a.minute, 6)
    assert_equal(a.second, 7)
    assert_equal(a.microsecond, 8)
    assert_true(a.tzinfo is not None, "tzinfo should not be None")
    assert_equal(a.tzinfo.value(), timezone(timedelta(hours=-1)))
    assert_equal(a.fold, 1)


def test_datetime_get_timetuple():
    a = datetime(2020, 3, 4, 5, 6, 7, 8, tzinfo=timezone(timedelta(hours=-1)), fold=1)
    timestruct = a.timetuple()
    assert_equal(timestruct.tm_year, 2020)
    assert_equal(timestruct.tm_mon, 3)
    assert_equal(timestruct.tm_mday, 4)
    assert_equal(timestruct.tm_hour, 5)
    assert_equal(timestruct.tm_min, 6)
    assert_equal(timestruct.tm_sec, 7)
    assert_equal(timestruct.tm_wday, 2)
    assert_equal(timestruct.tm_yday, 64)
    assert_equal(timestruct.tm_isdst, -1)


def test_datetime_replace():
    a = datetime(2020, 3, 4, 5, 6, 7, 8, tzinfo=timezone(timedelta(hours=-1)), fold=1)
    a = a.replace(year=2021)
    assert_equal(a.year, 2021)
    assert_equal(a.month, 3)
    assert_equal(a.day, 4)

    a = a.replace(month=9)
    assert_equal(a.year, 2021)
    assert_equal(a.month, 9)

    a = a.replace(day=15)
    assert_equal(a.year, 2021)
    assert_equal(a.month, 9)
    assert_equal(a.day, 15)

    a = a.replace(hour=20)
    assert_equal(a.year, 2021)
    assert_equal(a.month, 9)
    assert_equal(a.day, 15)
    assert_equal(a.hour, 20)
    assert_equal(a.minute, 6)

    a = a.replace(minute=30)
    assert_equal(a.minute, 30)

    a = a.replace(second=1)
    assert_equal(a.second, 1)
    
    a = a.replace(microsecond=2)
    assert_equal(a.microsecond, 2)

    a = a.replace(tzinfo=None)
    assert_true(a.tzinfo is None, "tzinfo should be None")

    a = a.replace(tzinfo=timezone(timedelta(hours=-1)))
    assert_true(a.tzinfo is not None, "tzinfo should not be None")
    assert_equal(a.tzinfo.value(), timezone(timedelta(hours=-1)))

    a = a.replace(fold=0)
    assert_equal(a.fold, 0)




def run_tests():
    test_aliases()
    test_constructor_default()
    test_constructor_all_values()
    test_datetime_get_timetuple()
    test_datetime_replace()
