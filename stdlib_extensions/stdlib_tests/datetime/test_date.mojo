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


def test_date_hash():
    let some_time = date(2020, 1, 1)
    let some_time2 = date(2020, 1, 1)

    let some_other_time = date(2020, 1, 2)

    assert_equal(hash(some_time), hash(some_time2))
    assert_true(hash(some_time) != hash(some_other_time), "incorrect hash")
    assert_true(hash(some_time2) != hash(some_other_time), "incorrect hash 2")


def run_tests():
    test_date()
    test_date_hash()
