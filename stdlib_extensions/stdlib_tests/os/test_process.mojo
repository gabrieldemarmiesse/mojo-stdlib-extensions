from ...os import getpid, urandom
from ...builtins import bytes
from ..utils import assert_true, assert_equal


def test_getpid():
    current_pid = getpid()
    assert_true(current_pid > 0, "current pid should be above 0")


def test_urandom():
    some_random_bytes = urandom(10)
    assert_equal(len(some_random_bytes), 10)

    some_new_bytes = urandom(10)
    assert_true(some_random_bytes != some_new_bytes, "random bytes should be different")

    empty_bytes = urandom(0)
    assert_equal(len(empty_bytes), 0)


def run_tests():
    test_getpid()
    test_urandom()
