from ...datetime.v2 import time, timezone, timedelta
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...builtins._types import Optional


def test_timezone_utc():
    a = timezone(timedelta(0))
    assert_equal(str(a), "UTC")
    # TODO: use when https://github.com/modularml/mojo/issues/1787 is fixed
    # assert_equal(timezone.utc, timezone(timedelta(0)))


def run_tests():
    test_timezone_utc()
