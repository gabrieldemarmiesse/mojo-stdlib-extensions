from ...datetime.v2._date import date
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from python import Python


def test_date():
    let simple_date = date(2020, 1, 1)
    assert_equal(simple_date.year, 2020)
    assert_equal(simple_date.month, 1)
    assert_equal(simple_date.day, 1)
    assert_equal(simple_date.__str__(), "2020-01-01")
    assert_equal(simple_date.__repr__(), "datetime.date(2020, 1, 1)")
    assert_equal(
        simple_date.__str__(),
        str(Python.import_module("datetime").date(2020, 1, 1)),
    )

    # we'd be extremely unlucky if this fails
    assert_equal(
        date.today().__str__(), str(Python.import_module("datetime").date.today())
    )
    assert_equal(date.min.__repr__(), "datetime.date(1, 1, 1)")
    assert_equal(date.max.__repr__(), "datetime.date(9999, 12, 31)")


def run_tests():
    test_date()
