from ...datetime import date
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from python import Python


def test_date():
    var simple_date = date(2020, 1, 1)
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
    var some_time = date(2020, 1, 1)
    var some_time2 = date(2020, 1, 1)

    var some_other_time = date(2020, 1, 2)

    assert_equal(hash(some_time), hash(some_time2))
    assert_true(hash(some_time) != hash(some_other_time), "incorrect hash")
    assert_true(hash(some_time2) != hash(some_other_time), "incorrect hash 2")


def test_date_strftime():
    assert_equal(date(2020, 1, 1).strftime("%Y-%m-%d"), "2020-01-01")
    assert_equal(date(2020, 1, 1).strftime("%Y-%m-%d %H:%M:%S"), "2020-01-01 00:00:00")


def test_full_date_strftime():
    # all codes
    # TODO: Add U, W, G, V and :z
    var format: String = "%a|%A|%w|%d|%b|%B|%m|%y|%Y|%H|%I|%p|%M|%S|%f|%z|%Z|%j|%c|%x|%X|%%|%u|%:z"
    var expected: String = "Tue|Tuesday|2|02|Mar|March|03|21|2021|00|12|AM|00|00|000000|||061|Tue Mar  2 00:00:00 2021|03/02/21|00:00:00|%|2|"
    assert_equal(date(2021, 3, 2).strftime(format), expected)


def test_ctime():
    assert_equal(date(2021, 3, 2).ctime(), "Tue Mar  2 00:00:00 2021")
    assert_equal(date(1821, 1, 10).ctime(), "Wed Jan 10 00:00:00 1821")


def test_fromisoformat():
    """Examples taken from the python documentation."""
    assert_equal(date.fromisoformat("2019-12-04"), date(2019, 12, 4))
    assert_equal(date.fromisoformat("20191204"), date(2019, 12, 4))
    assert_equal(date.fromisoformat("2021-W01-1"), date(2021, 1, 4))


def run_tests():
    test_date()
    test_date_hash()
    test_date_strftime()
    test_full_date_strftime()
    test_ctime()
    test_fromisoformat()
