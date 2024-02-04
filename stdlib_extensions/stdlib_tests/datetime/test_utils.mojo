from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from ...datetime.v2._utils import (
    _DAYS_IN_MONTH,
)




def test_days_in_month():
    assert_equal(_DAYS_IN_MONTH.__getitem__(0), 1)


def run_tests():
    test_days_in_month()
