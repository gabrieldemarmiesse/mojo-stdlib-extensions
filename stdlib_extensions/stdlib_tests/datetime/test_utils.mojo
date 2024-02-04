from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...datetime.v2._utils import (
    _is_leap,
    _days_before_year,
    _days_in_month,
    _DAYS_IN_MONTH,
)


def test_is_leap():
    assert_true(_is_leap(4), "4 is a leap year")
    assert_true(_is_leap(400), "400 is a leap year")
    assert_false(_is_leap(100), "100 is not a leap year")
    assert_false(_is_leap(200), "200 is not a leap year")
    assert_false(_is_leap(300), "300 is not a leap year")
    assert_false(_is_leap(500), "500 is not a leap year")
    assert_true(_is_leap(40), "400 is a leap year")
    assert_true(_is_leap(8), "8 is a leap year")
    assert_false(_is_leap(1), "1 is not a leap year")


def test_days_before_year():
    assert_equal(_days_before_year(1), 0)
    assert_equal(_days_before_year(2), 365)
    assert_equal(_days_before_year(3), 730)
    assert_equal(_days_before_year(4), 1095)
    assert_equal(_days_before_year(5), 1461)


def test_days_in_month():
    assert_equal(_DAYS_IN_MONTH.__getitem__(0), 1)


# def test_days_in_month2():
#    assert_equal(_days_in_month(1, 1), 31)
#    assert_equal(_days_in_month(2, 1), 28)
#
#    assert_equal(_days_in_month(2, 4), 29)
#    assert_equal(_days_in_month(3, 1), 31)
#    assert_equal(_days_in_month(4, 1), 30)
#    assert_equal(_days_in_month(5, 1), 31)
#    assert_equal(_days_in_month(6, 1), 30)
#    assert_equal(_days_in_month(7, 1), 31)
#    assert_equal(_days_in_month(8, 1), 31)
#    assert_equal(_days_in_month(9, 1), 30)
#    assert_equal(_days_in_month(10, 1), 31)
#    assert_equal(_days_in_month(11, 1), 30)
#    assert_equal(_days_in_month(12, 1), 31)
#
#    assert_equal(_days_in_month(3, 6), 31)


def run_tests():
    test_is_leap()
    test_days_before_year()
    test_days_in_month()
