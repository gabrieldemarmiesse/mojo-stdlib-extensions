"""Unlike what is present in the standard stdlib, we stop if something fails."""
from testing import (
    assert_equal as assert_equal_stdlib,
    assert_true as assert_true_stdlib,
    assert_false as assert_false_stdlib,
)
from ..builtins import bytes

def assert_equal(a: bytes, b: bytes):
    if a != b:
        raise Error("Expected '" + a.hex() + "' to be equal to '" + b.hex() + "'")

def assert_equal(a: String, b: String):
    if a != b:
        raise Error("Expected '" + a + "' to be equal to '" + b + "'")


def assert_equal(a: Int, b: Int):
    if a != b:
        raise Error("Expected " + String(a) + " to be equal to " + String(b))


def assert_true(value: Bool, message: String):
    if not assert_true_stdlib(value, message):
        raise Error()


def assert_false(value: Bool, message: String):
    if not assert_false_stdlib(value, message):
        raise Error()
