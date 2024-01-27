from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...builtins import divmod, round


def test_divmod():
    var a: Int
    var b: Int
    a, b = divmod(10, 4)
    assert_equal(a, 2)
    assert_equal(b, 2)

    a, b = divmod(-11, -2)
    assert_equal(a, 5)
    assert_equal(b, -1)


def test_round():
    assert_equal(round(-2.0), -2)
    assert_equal(round(-1.5), -2)
    assert_equal(round(-1.0), -1)
    assert_equal(round(-0.5), 0)
    assert_equal(round(0.0), 0)
    assert_equal(round(0.5), 0)
    assert_equal(round(1.0), 1)


def run_tests():
    test_divmod()
    test_round()
