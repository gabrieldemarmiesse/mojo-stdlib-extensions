from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...builtins.string import (
    endswith,
    rjust,
    ljust,
    split,
    replace,
    removeprefix,
    expandtabs,
    removesuffix,
    startswith,
    join,
)
from ...builtins import list


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


def test_startswith():
    assert_true(startswith("hello world", "hello"), "startswith 1 failed")
    assert_true(startswith("hello world", "hello", start=0), "startswith 2 failed")
    assert_true(
        startswith("hello world", "hello", start=0, end=5), "startswith 3 failed"
    )
    assert_true(
        startswith("hello world", "hello", start=0, end=6), "startswith 4 failed"
    )
    assert_true(
        startswith("hello world", "hello", start=0, end=7), "startswith 5 failed"
    )
    assert_true(
        startswith("hello world", "hello", start=0, end=8), "startswith 6 failed"
    )
    assert_false(startswith("hello world", "world"), "startswith 7 failed")
    assert_false(startswith("hello world", "hello", start=1), "startswith 8 failed")
    assert_false(
        startswith("hello world", "hello", start=1, end=5), "startswith 9 failed"
    )
    assert_false(
        startswith("hello world", "hello", start=1, end=6), "startswith 10 failed"
    )
    assert_false(
        startswith("hello world", "hello", start=1, end=7), "startswith 11 failed"
    )
    assert_false(
        startswith("hello world", "hello", start=1, end=8), "startswith 12 failed"
    )


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


def test_join_simple():
    input_list = list[String]()
    input_list.append("hello")
    input_list.append("Mojo 🔥")
    input_list.append("world")

    assert_equal(join(" ", input_list), "hello Mojo 🔥 world")
    assert_equal(join(", ", input_list), "hello, Mojo 🔥, world")
    assert_equal(join("::", input_list), "hello::Mojo 🔥::world")
    assert_equal(join("", input_list), "helloMojo 🔥world")


def test_join_edge_case():
    input_list = list[String]()

    assert_equal(join(" ", input_list), "")
    assert_equal(join(", ", input_list), "")
    assert_equal(join("::", input_list), "")
    assert_equal(join("", input_list), "")


def test_replace():
    assert_equal(replace("hello world", "world", "there"), "hello there")
    assert_equal(replace("hello world", "world", "there", 1), "hello there")
    assert_equal(replace("hello world", "world", "there", 2), "hello there")

    assert_equal(replace("hello world world", "world", "there", 1), "hello there world")
    assert_equal(replace("hello world world", "world", "there", 2), "hello there there")
    assert_equal(
        replace("hello 0 world world", "world", "there", 0), "hello 0 world world"
    )
    assert_equal(
        replace("hello -1 world world", "world", "there", -1), "hello -1 there there"
    )
    assert_equal(
        replace("hello None world world", "world", "there"), "hello None there there"
    )


def test_removeprefix():
    assert_equal(removeprefix("hello world", "hello"), " world")
    assert_equal(removeprefix("hello world", "world"), "hello world")
    assert_equal(removeprefix("hello world", "hello world"), "")
    assert_equal(removeprefix("hello world", "llo wor"), "hello world")


def test_removesuffix():
    assert_equal(removesuffix("hello world", "world"), "hello ")
    assert_equal(removesuffix("hello world", "hello"), "hello world")
    assert_equal(removesuffix("hello world", "hello world"), "")
    assert_equal(removesuffix("hello world", "llo wor"), "hello world")


def test_expandtabs():
    assert_equal(expandtabs("hello\tworld", 8), "hello        world")
    assert_equal(expandtabs("hello\tworld", 4), "hello    world")
    assert_equal(expandtabs("hello\tworld", 2), "hello  world")
    assert_equal(expandtabs("helloworld", 2), "helloworld")
    assert_equal(expandtabs("hello\tworld", 0), "helloworld")


def run_tests():
    test_ljust()
    test_rjust()
    test_endswith()
    test_startswith()
    test_split()
    test_join_simple()
    test_join_edge_case()
    test_replace()
    test_removeprefix()
    test_removesuffix()
    test_expandtabs()
