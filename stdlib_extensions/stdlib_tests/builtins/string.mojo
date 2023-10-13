from testing import assert_true, assert_false, assert_equal
from stdlib_extensions.builtins.string import endswith, rjust, ljust


def test_ljust():
    assert_equal(ljust("hello", 10), "hello     ")
    assert_equal(ljust("hello", 10, "x"), "helloxxxxx")
    assert_equal(ljust("hello", 5), "hello")
    assert_equal(ljust("hello", 3), "hello")
    assert_equal(ljust("hello", 3, "x"), "hello")


def test_rjust():
    assert_equal(rjust("hello", 10), "     hello")
    assert_equal(rjust("hello", 10, "x"), "xxxxxhello")
    assert_equal(rjust("hello", 5), "hello")
    assert_equal(rjust("hello", 3), "hello")
    assert_equal(rjust("hello", 3, "x"), "hello")


def test_endswith():
    assert_true(endswith("hello world", "world"), "endswith 1 failed")
    assert_true(endswith("hello world", "world", start=2), "endswith 2 failed")
    assert_true(endswith("hello world", "world", start=6), "endswith 3 failed")
    assert_true(endswith(" worldd", "world", start=0, end=6), "endswith 4 failed")
    assert_true(endswith(" worldd", "world", start=0, end=6), "endswith 5 failed")
    assert_false(endswith(" worldd", "world", start=0, end=7), "endswith 6 failed")
    assert_false(endswith(" worldd", "hello"), "endswith 7 failed")
    assert_false(endswith(" worldd", "world"), "endswith 8 failed")


def run_tests():
    test_ljust()
    test_rjust()
    test_endswith()
