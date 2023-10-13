from stdlib_extensions.stdlib_tests.utils import assert_true, assert_false, assert_equal
from stdlib_extensions.builtins.string import endswith, rjust, ljust, split


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


def test_split():
    assert_equal(split("hello world").__str__(), "['hello', 'world']")
    assert_equal(split("Hello world").__str__(), "['Hello', 'world']")
    assert_equal(split("Hello world", maxsplit=1).__str__(), "['Hello', 'world']")
    assert_equal(
        split("apple::banana::orange", sep="::").__str__(),
        "['apple', 'banana', 'orange']",
    )
    assert_equal(
        split("apple::banana::orange", sep="::", maxsplit=1).__str__(),
        "['apple', 'banana::orange']",
    )
    assert_equal(
        split("a--b--c--d", sep="--", maxsplit=2).__str__(), "['a', 'b', 'c--d']"
    )


def run_tests():
    test_ljust()
    test_rjust()
    test_endswith()
    test_split()
