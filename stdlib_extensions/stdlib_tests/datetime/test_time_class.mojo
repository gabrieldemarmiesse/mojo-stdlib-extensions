from ...datetime.v2 import time, timezone
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...builtins._types import Optional


def test_time_creation():
    t = time(12, 30, 0)
    assert_equal(t.hour, 12)
    assert_equal(t.minute, 30)
    assert_equal(t.second, 0)
    assert_equal(t.microsecond, 0)
    assert_true(t.tzinfo is None, "tzinfo is None")
    assert_equal(t.fold, 0)


def run_tests():
    test_time_creation()
