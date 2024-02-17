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


def test_date_strftime():
    assert_equal(date(2020, 1, 1).strftime("%Y-%m-%d"), "2020-01-01")
    assert_equal(date(2020, 1, 1).strftime("%Y-%m-%d %H:%M:%S"), "2020-01-01 00:00:00")


def test_full_date_strftime():
    # all codes
    # TODO: Add U and W
    var format: String = "%a|%A|%w|%d|%b|%B|%m|%y|%Y|%H|%I|%p|%M|%S|%f|%z|%Z|%j|%c|%x|%X|%%"
    print("format", format)
    var expected: String = "Fri|Friday|5|03|May|May|05|20|920|00|12|AM|00|00|000000|||124|Fri May  3 00:00:00 920|05/03/20|00:00:00|%"
    print("expected", expected)
    print("expected")
    assert_equal(date(2020, 5, 3).strftime(format), expected)
    print("done")


def run_tests():
    test_date()
    test_date_hash()
    test_date_strftime()
    test_full_date_strftime()
