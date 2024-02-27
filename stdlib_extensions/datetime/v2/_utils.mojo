"""Concrete date/time and related types.

See http://www.iana.org/time-zones/repository/tz-link.html for
time zone and DST data sources.

This file is taken from https://github.com/python/cpython/blob/main/Lib/_pydatetime.py
It's just been converted to Mojo manually.
"""

from ...builtins import list, divmod, round, abs
from ...builtins.string import join
from ...time import struct_time
import math as _math
import sys
from ...builtins import Optional, bytes
from ...builtins._generic_list import _cmp_list
from ...builtins._hash import hash as custom_hash
from ...builtins import bool_to_int
from ..._utils import custom_debug_assert


def _cmp(x, y):
    return 0 if x == y else 1 if x > y else -1


alias MINYEAR = 1
alias MAXYEAR = 9999
alias MAXORDINAL = 3652059  # date.max.toordinal()

# Utility functions, adapted from Python's Demo/classes/Dates.py, which
# also assumes the current Gregorian calendar indefinitely extended in
# both directions.  Difference:  Dates.py calls January 1 of year 0 day
# number 1.  The code here calls January 1 of year 1 day number 1.  This is
# to match the definition of the "proleptic Gregorian" calendar in Dershowitz
# and Reingold's "Calendrical Calculations", where it's the base calendar
# for all computations.  See the book for algorithms for converting between
# proleptic Gregorian ordinals and many other calendar systems.

# -1 is a placeholder for indexing purposes.


fn _get_days_in_month() -> list[Int]:
    return list[Int].from_values(-1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)


# TODO: use the alias instead of the function call when
# https://github.com/modularml/mojo/issues/1730 is fixed
alias _DAYS_IN_MONTH = _get_days_in_month()


fn _get_days_before_month() -> list[Int]:
    var result = list[Int]()
    result.append(-1)  # -1 is a placeholder for indexing purposes.
    var dbm = 0
    # TODO: use the alias instead of the function call when
    # https://github.com/modularml/mojo/issues/1730 is fixed
    for i in range(1, len(_get_days_in_month())):
        var dim = _get_days_in_month()[i]
        result.append(dbm)
        dbm += dim
    return result


alias _DAYS_BEFORE_MONTH = _get_days_before_month()


fn _is_leap(year: Int) -> Bool:
    "year -> 1 if leap year, else 0."
    return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)


fn _days_before_year(year: Int) -> Int:
    "year -> number of days before January 1st of year."
    var y = year - 1
    return y * 365 + y // 4 - y // 100 + y // 400


fn _days_in_month(year: Int, month: Int) -> Int:
    "year, month -> number of days in that month in that year."
    # assert 1 <= month <= 12, month
    if month == 2 and _is_leap(year):
        return 29
    # TODO: use the alias _DAYS_IN_MONTH when
    # https://github.com/modularml/mojo/issues/1730 is fixed
    return _get_days_in_month()[month]


fn _bool_to_int(x: Bool) -> Int:
    """Remove when Bool is Intable"""
    if x:
        return 1
    else:
        return 0


fn _days_before_month(year: Int, month: Int) -> Int:
    "year, month -> number of days in year preceding first day of month."
    # assert 1 <= month <= 12, 'month must be in 1..12'
    # TODO: use the alias _DAYS_BEFORE_MONTH
    # when https://github.com/modularml/mojo/issues/1730 is fixed
    return _get_days_before_month()[month] + _bool_to_int(month > 2 and _is_leap(year))


fn ymd2ord(year: Int, month: Int, day: Int) -> Int:
    "Year, month, day -> ordinal, considering 01-Jan-0001 as day 1."
    var dim = _days_in_month(year, month)
    return _days_before_year(year) + _days_before_month(year, month) + day


alias _DI400Y = _days_before_year(401)  # number of days in 400 years
alias _DI100Y = _days_before_year(101)  #    "    "   "   " 100   "
alias _DI4Y = _days_before_year(5)  #    "    "   "   "   4   "

# A 4-year cycle has an extra leap day over what we'd get from pasting
# together 4 single years.

# assert _DI4Y == 4 * 365 + 1

# Similarly, a 400-year cycle has an extra leap day over what we'd get from
# pasting together 4 100-year cycles.

# assert _DI400Y == 4 * _DI100Y + 1

# OTOH, a 100-year cycle has one fewer leap day than we'd get from
# pasting together 25 4-year cycles.

# assert _DI100Y == 25 * _DI4Y - 1


fn ord2ymd(owned n: Int) -> Tuple[Int, Int, Int]:
    "Ordinal -> (year, month, day), considering 01-Jan-0001 as day 1."
    # n is a 1-based index, starting at 1-Jan-1.  The pattern of leap years
    # repeats exactly every 400 years.  The basic strategy is to find the
    # closest 400-year boundary at or before n, then work with the offset
    # from that boundary to n.  Life is much clearer if we subtract 1 from
    # n first -- then the values of n at 400-year boundaries are exactly
    # those divisible by _DI400Y:
    #
    #     D  M   Y            n              n-1
    #     -- --- ----        ----------     ----------------
    #     31 Dec -400        -_DI400Y       -_DI400Y -1
    #      1 Jan -399         -_DI400Y +1   -_DI400Y      400-year boundary
    #     ...
    #     30 Dec  000        -1             -2
    #     31 Dec  000         0             -1
    #      1 Jan  001         1              0            400-year boundary
    #      2 Jan  001         2              1
    #      3 Jan  001         3              2
    #     ...
    #     31 Dec  400         _DI400Y        _DI400Y -1
    #      1 Jan  401         _DI400Y +1     _DI400Y      400-year boundary
    n -= 1
    var n400: Int
    n400, n = divmod(n, _DI400Y)
    var year = n400 * 400 + 1  # ..., -399, 1, 401, ...
    # Now n is the (non-negative) offset, in days, from January 1 of year, to
    # the desired date.  Now compute how many 100-year cycles precede n.
    # Note that it's possible for n100 to equal 4!  In that case 4 full
    # 100-year cycles precede the desired day, which implies the desired
    # day is December 31 at the end of a 400-year cycle.
    var n100: Int
    n100, n = divmod(n, _DI100Y)
    # Now compute how many 4-year cycles precede it.
    var n4: Int
    n4, n = divmod(n, _DI4Y)
    # And now how many single years.  Again n1 can be 4, and again meaning
    # that the desired day is December 31 at the end of the 4-year cycle.
    var n1: Int
    n1, n = divmod(n, 365)
    year += n100 * 100 + n4 * 4 + n1
    if n1 == 4 or n100 == 4:
        # assert n == 0
        return year - 1, 12, 31
    # Now the year is correct, and n is the offset from January 1.  We find
    # the month via an estimate that's either exact or one too large.
    var leapyear = n1 == 3 and (n4 != 24 or n100 == 3)
    # assert leapyear == _is_leap(year)
    var month = (n + 50) >> 5
    # TODO: use alias when
    # https://github.com/modularml/mojo/issues/1730 is fixed
    var preceding = _get_days_before_month()[month] + _bool_to_int(
        month > 2 and leapyear
    )
    if preceding > n:  # estimate is too large
        month -= 1
        # TODO: use alias when
        # https://github.com/modularml/mojo/issues/1730 is fixed
        preceding -= _get_days_in_month()[month] + _bool_to_int(month == 2 and leapyear)
    n -= preceding
    # assert 0 <= n < _days_in_month(year, month)
    # Now the year and month are correct, and n is the offset from the
    # start of that month:  we're done!
    return year, month, n + 1


# Month and day names.  For localized versions, see the calendar module.
# TODO: use alias when https://github.com/modularml/mojo/issues/1730 is fixed
fn get_months_short_names() -> list[String]:
    return list[String].from_values(
        "",
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
    )


alias MONTHS_SHORT_NAMES = get_months_short_names()


fn get_months_names() -> list[String]:
    return list[String].from_values(
        "",
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
    )


alias MONTHS_NAMES = get_months_names()


fn get_days_short_names() -> list[String]:
    return list[String].from_values(
        "",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
        "Sun",
    )


alias DAYS_SHORT_NAMES = get_days_short_names()


fn get_days_names() -> list[String]:
    return list[String].from_values(
        "",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
    )


alias DAYS_NAMES = get_days_names()


fn _build_struct_time(
    y: Int, m: Int, d: Int, hh: Int, mm: Int, ss: Int, dstflag: Int
) -> struct_time:
    var wday = (ymd2ord(y, m, d) + 6) % 7
    var dnum = _days_before_month(y, m) + d
    return struct_time((y, m, d, hh, mm, ss, wday, dnum, dstflag))


## Correctly substitute for %z and %Z escapes in strftime formats.
# def _wrap_strftime(object, format, timetuple):
#    # Don't call utcoffset() or tzname() unless actually needed.
#    freplace = None  # the string to use for %f
#    zreplace = None  # the string to use for %z
#    colonzreplace = None  # the string to use for %:z
#    Zreplace = None  # the string to use for %Z
#
#    # Scan format for %z, %:z and %Z escapes, replacing as needed.
#    newformat = []
#    i, n = 0, len(format)
#    while i < n:
#        ch = format[i]
#        i += 1
#        if ch == '%':
#            if i < n:
#                ch = format[i]
#                i += 1
#                if ch == 'f':
#                    if freplace is None:
#                        freplace = '%06d' % getattr(object,
#                                                    'microsecond', 0)
#                    newformat.append(freplace)
#                elif ch == 'z':
#                    if zreplace is None:
#                        if hasattr(object, "utcoffset"):
#                            zreplace = _format_offset(object.utcoffset(), sep="")
#                        else:
#                            zreplace = ""
#                    assert '%' not in zreplace
#                    newformat.append(zreplace)
#                elif ch == ':':
#                    if i < n:
#                        ch2 = format[i]
#                        i += 1
#                        if ch2 == 'z':
#                            if colonzreplace is None:
#                                if hasattr(object, "utcoffset"):
#                                    colonzreplace = _format_offset(object.utcoffset(), sep=":")
#                                else:
#                                    colonzreplace = ""
#                            assert '%' not in colonzreplace
#                            newformat.append(colonzreplace)
#                        else:
#                            newformat.append('%')
#                            newformat.append(ch)
#                            newformat.append(ch2)
#                elif ch == 'Z':
#                    if Zreplace is None:
#                        Zreplace = ""
#                        if hasattr(object, "tzname"):
#                            s = object.tzname()
#                            if s is not None:
#                                # strftime is going to have at this: escape %
#                                Zreplace = s.replace('%', '%%')
#                    newformat.append(Zreplace)
#                else:
#                    newformat.append('%')
#                    newformat.append(ch)
#            else:
#                newformat.append('%')
#        else:
#            newformat.append(ch)
#    newformat = "".join(newformat)
#    return _time.strftime(newformat, timetuple)
#
fn _is_ascii_digit(c: String) -> Bool:
    alias my_str: String = "0123456789"
    for i in range(len(my_str)):
        if c == my_str[i]:
            return True
    return False


#
# def _find_isoformat_datetime_separator(dtstr):
#    # See the comment in _datetimemodule.c:_find_isoformat_datetime_separator
#    len_dtstr = len(dtstr)
#    if len_dtstr == 7:
#        return 7
#
#    assert len_dtstr > 7
#    date_separator = "-"
#    week_indicator = "W"
#
#    if dtstr[4] == date_separator:
#        if dtstr[5] == week_indicator:
#            if len_dtstr < 8:
#                raise ValueError("Invalid ISO string")
#            if len_dtstr > 8 and dtstr[8] == date_separator:
#                if len_dtstr == 9:
#                    raise ValueError("Invalid ISO string")
#                if len_dtstr > 10 and _is_ascii_digit(dtstr[10]):
#                    # This is as far as we need to resolve the ambiguity for
#                    # the moment - if we have YYYY-Www-##, the separator is
#                    # either a hyphen at 8 or a number at 10.
#                    #
#                    # We'll assume it's a hyphen at 8 because it's way more
#                    # likely that someone will use a hyphen as a separator than
#                    # a number, but at this point it's really best effort
#                    # because this is an extension of the spec anyway.
#                    # TODO(pganssle): Document this
#                    return 8
#                return 10
#            else:
#                # YYYY-Www (8)
#                return 8
#        else:
#            # YYYY-MM-DD (10)
#            return 10
#    else:
#        if dtstr[4] == week_indicator:
#            # YYYYWww (7) or YYYYWwwd (8)
#            idx = 7
#            while idx < len_dtstr:
#                if not _is_ascii_digit(dtstr[idx]):
#                    break
#                idx += 1
#
#            if idx < 9:
#                return idx
#
#            if idx % 2 == 0:
#                # If the index of the last number is even, it's YYYYWwwd
#                return 7
#            else:
#                return 8
#        else:
#            # YYYYMMDD (8)
#            return 8
#
#
fn _parse_isoformat_date(dtstr: String) raises -> Tuple[Int, Int, Int]:
    # It is assumed that this is an ASCII-only string of lengths 7, 8 or 10,
    # see the comment on Modules/_datetimemodule.c:_find_isoformat_datetime_separator
    # assert len(dtstr) in (7, 8, 10)
    var year = atol(dtstr[0:4])
    var has_sep = dtstr[4] == "-"
    var pos = 4 + bool_to_int(has_sep)
    if dtstr[pos : pos + 1] == "W":
        # YYYY-?Www-?D?
        pos += 1
        var weekno = atol(dtstr[pos : pos + 2])
        pos += 2
        var dayno = 1
        if len(dtstr) > pos:
            if (dtstr[pos : pos + 1] == "-") != has_sep:
                raise Error("Inconsistent use of dash separator")
            pos += bool_to_int(has_sep)
            dayno = atol(dtstr[pos : pos + 1])
        return _isoweek_to_gregorian(year, weekno, dayno)
    else:
        var month = atol(dtstr[pos : pos + 2])
        pos += 2
        if (dtstr[pos : pos + 1] == "-") != has_sep:
            raise Error("Inconsistent use of dash separator")
        pos += bool_to_int(has_sep)
        var day = atol(dtstr[pos : pos + 2])
        return year, month, day


# tuple[int, int, int] -> tuple[int, int, int] version of date.fromisocalendar
fn _isoweek_to_gregorian(year: Int, week: Int, day: Int) -> Tuple[Int, Int, Int]:
    # Year is bounded this way because 9999-12-31 is (9999, 52, 5)
    # if not MINYEAR <= year <= MAXYEAR:
    #    raise ValueError(f"Year is out of range: {year}")
    if not 0 < week < 53:
        var out_of_range = True
        if week == 53:
            # ISO years have 53 weeks in them on years starting with a
            # Thursday and leap years starting on a Wednesday
            var first_weekday = ymd2ord(year, 1, 1) % 7
            if first_weekday == 4 or (first_weekday == 3 and _is_leap(year)):
                out_of_range = False
        # if out_of_range:
        #    raise ValueError(f"Invalid week: {week}")
    # if not 0 < day < 8:
    #    raise ValueError(f"Invalid weekday: {day} (range is [1, 7])")
    # Now compute the offset from (Y, 1, 1) in days:
    var day_offset = (week - 1) * 7 + (day - 1)
    # Calculate the ordinal day for monday, week 1
    var day_1 = isoweek1monday(year)
    var ord_day = day_1 + day_offset
    return ord2ymd(ord_day)


## name is the offset-producing method, "utcoffset" or "dst".
## offset is what it returned.
## If offset isn't None or timedelta, raises TypeError.
## If offset is None, returns None.
## Else offset is checked for being in range.
## If it is, its integer value is returned.  Else ValueError is raised.
fn _check_utc_offset(name: String, offset: Optional[timedelta]):
    custom_debug_assert(
        name == "utcoffset" or name == "dst", "name must be 'utcoffset' or 'dst'"
    )
    if offset is None:
        return
    custom_debug_assert(
        -timedelta(1) < offset.value() < timedelta(1),
        name
        + "()="
        + offset.value()
        + ", must be strictly between -timedelta(hours=24) and timedelta(hours=24)",
    )


fn _check_date_fields(year: Int, month: Int, day: Int):
    # TODO: remove this and use the alias when we don't get "no expansion found" errors
    custom_debug_assert(
        MINYEAR <= year <= MAXYEAR, "year must be in the range 1 to 9999"
    )
    custom_debug_assert(1 <= month <= 12, "month must be in 1..12")
    var dim = _days_in_month(year, month)
    custom_debug_assert(1 <= day <= dim, "day must be in 1.." + str(dim))


fn _check_time_fields(hour: Int, minute: Int, second: Int, microsecond: Int, fold: Int):
    custom_debug_assert(0 <= hour <= 23, "hour must be in 0..23")
    custom_debug_assert(0 <= minute <= 59, "minute must be in 0..59")
    custom_debug_assert(0 <= second <= 59, "second must be in 0..59")
    custom_debug_assert(0 <= microsecond <= 999999, "microsecond must be in 0..999999")
    custom_debug_assert(0 <= fold <= 1, "fold must be in 0 or 1")


# def _divide_and_round(a, b):
#    """divide a by b and round result to the nearest integer
#
#    When the ratio is exactly half-way between two integers,
#    the even integer is returned.
#    """
#    # Based on the reference implementation for divmod_near
#    # in Objects/longobject.c.
#    q, r = divmod(a, b)
#    # round up if either r / b > 0.5, or r / b == 0.5 and q is odd.
#    # The expression r / b > 0.5 is equivalent to 2 * r > b if b is
#    # positive, 2 * r < b if b negative.
#    r *= 2
#    greater_than_half = r > b if b > 0 else r < b
#    if greater_than_half or r == b and q % 2 == 1:
#        q += 1
#
#    return q
#
#


#
#

#


#


#
#
fn isoweek1monday(year: Int) -> Int:
    # Helper to calculate the day number of the Monday starting week 1
    # XXX This could be done more efficiently
    var THURSDAY = 3
    var firstday = ymd2ord(year, 1, 1)
    var firstweekday = (firstday + 6) % 7  # See weekday() above
    var week1monday = firstday - firstweekday
    if firstweekday > THURSDAY:
        week1monday += 7
    return week1monday


# _EPOCH = datetime(1970, 1, 1, tzinfo=timezone.utc)
