"""Unlike what is present in the standard stdlib, we stop if something fails."""
from testing import (
    assert_equal as assert_equal_stdlib,
    assert_true as assert_true_stdlib,
    assert_false as assert_false_stdlib,
)


def assert_equal(a: String, b: String):
    if not assert_equal_stdlib(a, b):
        raise Error()


def assert_equal(a: Int, b: Int):
    if not assert_equal_stdlib(String(a), String(b)):
        raise Error()


def assert_true(value: Bool, message: String):
    if not assert_true_stdlib(value, message):
        raise Error()


def assert_false(value: Bool, message: String):
    if not assert_false_stdlib(value, message):
        raise Error()
