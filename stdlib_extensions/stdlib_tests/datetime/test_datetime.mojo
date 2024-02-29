from ...datetime import datetime, timezone, timedelta
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal
from python import Python


def test_aliases():
    assert_equal(datetime.min.year, 1)
    assert_equal(datetime.max.year, 9999)

    # TODO: test resolution when it's possible, currently it's broken because of
    # https://github.com/modularml/mojo/issues/1787


def test_constructor_default():
    a = datetime(2020, 3, 4)
    assert_equal(a.year, 2020)
    assert_equal(a.month, 3)
    assert_equal(a.day, 4)
    assert_equal(a.hour, 0)
    assert_equal(a.minute, 0)
    assert_equal(a.second, 0)
    assert_equal(a.microsecond, 0)
    assert_true(a.tzinfo is None, "tzinfo should be None")
    assert_equal(a.fold, 0)


def test_constructor_all_values():
    a = datetime(2020, 3, 4, 5, 6, 7, 8, tzinfo=timezone(timedelta(hours=-1)), fold=1)
    assert_equal(a.year, 2020)
    assert_equal(a.month, 3)
    assert_equal(a.day, 4)
    assert_equal(a.hour, 5)
    assert_equal(a.minute, 6)
    assert_equal(a.second, 7)
    assert_equal(a.microsecond, 8)
    assert_true(a.tzinfo is not None, "tzinfo should not be None")
    assert_equal(a.tzinfo.value(), timezone(timedelta(hours=-1)))
    assert_equal(a.fold, 1)


def test_datetime_get_timetuple():
    a = datetime(2020, 3, 4, 5, 6, 7, 8, tzinfo=timezone(timedelta(hours=-1)), fold=1)
    timestruct = a.timetuple()
    assert_equal(timestruct.tm_year, 2020)
    assert_equal(timestruct.tm_mon, 3)
    assert_equal(timestruct.tm_mday, 4)
    assert_equal(timestruct.tm_hour, 5)
    assert_equal(timestruct.tm_min, 6)
    assert_equal(timestruct.tm_sec, 7)
    assert_equal(timestruct.tm_wday, 2)
    assert_equal(timestruct.tm_yday, 64)
    assert_equal(timestruct.tm_isdst, -1)


def test_datetime_replace():
    a = datetime(2020, 3, 4, 5, 6, 7, 8, tzinfo=timezone(timedelta(hours=-1)), fold=1)
    a = a.replace(year=2021)
    assert_equal(a.year, 2021)
    assert_equal(a.month, 3)
    assert_equal(a.day, 4)

    a = a.replace(month=9)
    assert_equal(a.year, 2021)
    assert_equal(a.month, 9)

    a = a.replace(day=15)
    assert_equal(a.year, 2021)
    assert_equal(a.month, 9)
    assert_equal(a.day, 15)

    a = a.replace(hour=20)
    assert_equal(a.year, 2021)
    assert_equal(a.month, 9)
    assert_equal(a.day, 15)
    assert_equal(a.hour, 20)
    assert_equal(a.minute, 6)

    a = a.replace(minute=30)
    assert_equal(a.minute, 30)

    a = a.replace(second=1)
    assert_equal(a.second, 1)

    a = a.replace(microsecond=2)
    assert_equal(a.microsecond, 2)

    a = a.replace(tzinfo=None)
    assert_true(a.tzinfo is None, "tzinfo should be None")

    a = a.replace(tzinfo=timezone(timedelta(hours=-1)))
    assert_true(a.tzinfo is not None, "tzinfo should not be None")
    assert_equal(a.tzinfo.value(), timezone(timedelta(hours=-1)))

    a = a.replace(fold=0)
    assert_equal(a.fold, 0)


def test_datetime_repr():
    a = datetime(2020, 3, 4, 5, 6, 7, 8, tzinfo=timezone(timedelta(hours=-1)), fold=1)
    assert_equal(
        a.__repr__(),
        (
            "datetime.datetime(2020, 3, 4, 5, 6, 7, 8,"
            " tzinfo=datetime.timezone(datetime.timedelta(days=-1, seconds=82800)),"
            " fold=1)"
        ),
    )

    a = datetime(2020, 3, 4)
    assert_equal(a.__repr__(), "datetime.datetime(2020, 3, 4, 0, 0)")


def test_datetime_add():
    # This could be refactored using str(datetime)
    a = datetime(2020, 3, 4, 5, 6, 7, 8, tzinfo=timezone(timedelta(hours=-1)), fold=1)
    b = timedelta(days=1)
    c = a + b
    assert_equal(c.year, 2020)
    assert_equal(c.month, 3)
    assert_equal(c.day, 5)
    assert_equal(c.hour, 5)
    assert_equal(c.minute, 6)
    assert_equal(c.second, 7)
    assert_equal(c.microsecond, 8)
    assert_equal(c.tzinfo.value(), timezone(timedelta(hours=-1)))
    assert_equal(c.fold, 0)

    a = datetime(2021, 2, 3)
    b = timedelta(days=365)
    c = a + b
    assert_equal(c.year, 2022)
    assert_equal(c.month, 2)
    assert_equal(c.day, 3)

    a = datetime(2020, 3, 4, 5, 6, 7, 8)
    b = timedelta(days=1, minutes=120, seconds=3602)
    c = a + b
    assert_equal(c.year, 2020)
    assert_equal(c.month, 3)
    assert_equal(c.day, 5)
    assert_equal(c.hour, 8)
    assert_equal(c.minute, 6)
    assert_equal(c.second, 9)
    assert_equal(c.microsecond, 8)
    assert_true(c.tzinfo is None, "tzinfo is None")


def test_datetime_sub():
    # This could be refactored using str(datetime)
    a = datetime(2020, 3, 4, 5, 6, 7, 8, tzinfo=timezone(timedelta(hours=-1)), fold=1)
    b = timedelta(days=1)
    c = a - b
    assert_equal(c.year, 2020)
    assert_equal(c.month, 3)
    assert_equal(c.day, 3)
    assert_equal(c.hour, 5)
    assert_equal(c.minute, 6)
    assert_equal(c.second, 7)
    assert_equal(c.microsecond, 8)
    assert_equal(c.tzinfo.value(), timezone(timedelta(hours=-1)))
    assert_equal(c.fold, 0)

    a = datetime(2021, 2, 3)
    b = timedelta(days=365)
    c = a - b
    assert_equal(c.year, 2020)
    assert_equal(c.month, 2)
    assert_equal(c.day, 4)
    a = datetime(2020, 3, 4, 5, 6, 7, 8)
    b = timedelta(days=1, minutes=120, seconds=3602)
    c = a - b
    assert_equal(c.year, 2020)
    assert_equal(c.month, 3)
    assert_equal(c.day, 3)
    assert_equal(c.hour, 2)
    assert_equal(c.minute, 6)
    assert_equal(c.second, 5)
    assert_equal(c.microsecond, 8)
    assert_true(c.tzinfo is None, "tzinfo is None")


def test_datetime_now():
    var python_datetime_module = Python.import_module("datetime")
    var now1 = python_datetime_module.datetime.now()
    var now2 = datetime.now()
    var now3 = python_datetime_module.datetime.now()

    var now2_as_py = now2.to_python()

    assert_true(
        str(now1 <= now2_as_py) == "True", "datetimes should be in order, 1 <= 2"
    )
    assert_true(
        str(now2_as_py <= now3) == "True", "datetimes should be in order, 2 <= 3"
    )


def test_datetime_isoformat():
    a = datetime(
        2020,
        3,
        4,
        5,
        6,
        7,
        8,
        tzinfo=timezone(timedelta(hours=-1, minutes=8, seconds=-9)),
        fold=1,
    )
    assert_equal(a.isoformat(), "2020-03-04T05:06:07.000008-00:52:09")
    assert_equal(a.isoformat(sep="U"), "2020-03-04U05:06:07.000008-00:52:09")
    assert_equal(
        a.isoformat(sep="U", timespec="seconds"), "2020-03-04U05:06:07-00:52:09"
    )
    assert_equal(a.isoformat(sep="U", timespec="minutes"), "2020-03-04U05:06-00:52:09")
    assert_equal(a.isoformat(sep="U", timespec="hours"), "2020-03-04U05-00:52:09")

    a = datetime(2022, 3, 4)
    assert_equal(a.isoformat(), "2022-03-04T00:00:00")


def test_datetime_str():
    a = datetime(
        2020,
        3,
        4,
        5,
        6,
        7,
        8,
        tzinfo=timezone(timedelta(hours=-1, minutes=8, seconds=-9)),
        fold=1,
    )
    assert_equal(str(a), "2020-03-04 05:06:07.000008-00:52:09")


def run_tests():
    test_aliases()
    test_constructor_default()
    test_constructor_all_values()
    test_datetime_get_timetuple()
    test_datetime_replace()
    test_datetime_repr()
    test_datetime_add()
    test_datetime_sub()
    test_datetime_now()
    test_datetime_isoformat()
    test_datetime_str()
