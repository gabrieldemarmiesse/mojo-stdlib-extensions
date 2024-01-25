"""Unlike what is present in the standard stdlib, we stop if something fails."""

from ..builtins import bytes, Equalable


def assert_equal(a: bytes, b: bytes):
    if a != b:
        raise Error("Expected '" + a.hex() + "' to be equal to '" + b.hex() + "'")


def assert_equal(a: String, b: String):
    if a != b:
        raise Error("Expected '" + a + "' to be equal to '" + b + "'")


def assert_equal(a: Int, b: Int):
    if a != b:
        raise Error("Expected " + String(a) + " to be equal to " + String(b))


def assert_equal[T: Stringable, U: Stringable](a: T, b: U):
    if str(a) != str(b):
        raise Error("Expected " + str(a) + " to be equal to " + str(b))


def assert_true(value: Bool, message: String):
    if not value:
        raise Error(message)


def assert_false(value: Bool, message: String):
    if value:
        raise Error(message)
