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


def run_tests():
    test_aliases()
    test_constructor_default()
    test_constructor_all_values()
