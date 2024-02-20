from ...datetime.v2 import time, timezone, timedelta
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...builtins._types import Optional


def test_timezone_utc():
    assert_equal(timezone.utc, timezone(timedelta(0)))
    print("yolo")


def run_tests():
    test_timezone_utc()
