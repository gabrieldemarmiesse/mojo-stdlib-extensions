from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...datetime.v2._utils import _is_leap

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


def run_tests():
    test_is_leap()
