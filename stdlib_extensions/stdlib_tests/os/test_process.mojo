from ...os import getpid
from ..utils import assert_true


def test_getpid():
    current_pid = getpid()
    assert_true(current_pid > 0, "current pid should be above 0")


def run_tests():
    test_getpid()
