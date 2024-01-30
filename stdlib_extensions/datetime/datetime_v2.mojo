"""Concrete date/time and related types.

See http://www.iana.org/time-zones/repository/tz-link.html for
time zone and DST data sources.

This file is taken from https://github.com/python/cpython/blob/main/Lib/_pydatetime.py
It's just been converted to Mojo manually.
"""

from ..builtins import list, divmod, round, abs
from ..builtins.string import join
import time as _time
import math as _math
import sys
from ..builtins import Optional, bytes
from ..builtins._generic_list import _cmp_list
from ..builtins._hash import hash as custom_hash


def _cmp(x, y):
    return 0 if x == y else 1 if x > y else -1


alias MINYEAR = 1
alias MAXYEAR = 9999
alias _MAXORDINAL = 3652059  # date.max.toordinal()

# Utility functions, adapted from Python's Demo/classes/Dates.py, which
# also assumes the current Gregorian calendar indefinitely extended in
# both directions.  Difference:  Dates.py calls January 1 of year 0 day
# number 1.  The code here calls January 1 of year 1 day number 1.  This is
# to match the definition of the "proleptic Gregorian" calendar in Dershowitz
# and Reingold's "Calendrical Calculations", where it's the base calendar
# for all computations.  See the book for algorithms for converting between
# proleptic Gregorian ordinals and many other calendar systems.

# -1 is a placeholder for indexing purposes.

# fn _get_days_in_month():


alias _DAYS_IN_MONTH = list[Int].from_values(
    -1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
)


fn _get_days_before_month() -> list[Int]:
    var result = list[Int]()
    result.append(-1)  # -1 is a placeholder for indexing purposes.
    var dbm = 0
    for i in range(1, len(_DAYS_IN_MONTH)):
        var dim = _DAYS_IN_MONTH.unchecked_get(i)
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
    return _DAYS_IN_MONTH.unchecked_get(month)


fn _bool_to_int(x: Bool) -> Int:
    """Remove when Bool is Intable"""
    if x:
        return 1
    else:
        return 0


fn _days_before_month(year: Int, month: Int) -> Int:
    "year, month -> number of days in year preceding first day of month."
    # assert 1 <= month <= 12, 'month must be in 1..12'
    return _DAYS_BEFORE_MONTH.unchecked_get(month) + _bool_to_int(
        month > 2 and _is_leap(year)
    )


fn _ymd2ord(year: Int, month: Int, day: Int) -> Int:
    "year, month, day -> ordinal, considering 01-Jan-0001 as day 1."
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


fn _ord2ymd(owned n: Int) -> Tuple[Int, Int, Int]:
    "ordinal -> (year, month, day), considering 01-Jan-0001 as day 1."
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
    var preceding = _DAYS_BEFORE_MONTH.unchecked_get(month) + _bool_to_int(
        month > 2 and leapyear
    )
    if preceding > n:  # estimate is too large
        month -= 1
        preceding -= _DAYS_IN_MONTH.unchecked_get(month) + _bool_to_int(
            month == 2 and leapyear
        )
    n -= preceding
    # assert 0 <= n < _days_in_month(year, month)
    # Now the year and month are correct, and n is the offset from the
    # start of that month:  we're done!
    return year, month, n + 1


# Month and day names.  For localized versions, see the calendar module.
alias _MONTHNAMES = list[String].from_values(
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
alias _DAYNAMES = list[String].from_values(
    "", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
)
#
#
# def _build_struct_time(y, m, d, hh, mm, ss, dstflag):
#    wday = (_ymd2ord(y, m, d) + 6) % 7
#    dnum = _days_before_month(y, m) + d
#    return _time.struct_time((y, m, d, hh, mm, ss, wday, dnum, dstflag))
#
# def _format_time(hh, mm, ss, us, timespec='auto'):
#    specs = {
#        'hours': '{:02d}',
#        'minutes': '{:02d}:{:02d}',
#        'seconds': '{:02d}:{:02d}:{:02d}',
#        'milliseconds': '{:02d}:{:02d}:{:02d}.{:03d}',
#        'microseconds': '{:02d}:{:02d}:{:02d}.{:06d}'
#    }
#
#    if timespec == 'auto':
#        # Skip trailing microseconds when us==0.
#        timespec = 'microseconds' if us else 'seconds'
#    elif timespec == 'milliseconds':
#        us //= 1000
#    try:
#        fmt = specs[timespec]
#    except KeyError:
#        raise ValueError('Unknown timespec value')
#    else:
#        return fmt.format(hh, mm, ss, us)
#
# def _format_offset(off, sep=':'):
#    s = ''
#    if off is not None:
#        if off.days < 0:
#            sign = "-"
#            off = -off
#        else:
#            sign = "+"
#        hh, mm = divmod(off, timedelta(hours=1))
#        mm, ss = divmod(mm, timedelta(minutes=1))
#        s += "%s%02d%s%02d" % (sign, hh, sep, mm)
#        if ss or ss.microseconds:
#            s += "%s%02d" % (sep, ss.seconds)
#
#            if ss.microseconds:
#                s += '.%06d' % ss.microseconds
#    return s
#
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
#    push = newformat.append
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
#                            push('%')
#                            push(ch)
#                            push(ch2)
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
#                    push('%')
#                    push(ch)
#            else:
#                push('%')
#        else:
#            push(ch)
#    newformat = "".join(newformat)
#    return _time.strftime(newformat, timetuple)
#
## Helpers for parsing the result of isoformat()
# def _is_ascii_digit(c):
#    return c in "0123456789"
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
# def _parse_isoformat_date(dtstr):
#    # It is assumed that this is an ASCII-only string of lengths 7, 8 or 10,
#    # see the comment on Modules/_datetimemodule.c:_find_isoformat_datetime_separator
#    assert len(dtstr) in (7, 8, 10)
#    year = int(dtstr[0:4])
#    has_sep = dtstr[4] == '-'
#
#    pos = 4 + has_sep
#    if dtstr[pos:pos + 1] == "W":
#        # YYYY-?Www-?D?
#        pos += 1
#        weekno = int(dtstr[pos:pos + 2])
#        pos += 2
#
#        dayno = 1
#        if len(dtstr) > pos:
#            if (dtstr[pos:pos + 1] == '-') != has_sep:
#                raise ValueError("Inconsistent use of dash separator")
#
#            pos += has_sep
#
#            dayno = int(dtstr[pos:pos + 1])
#
#        return list(_isoweek_to_gregorian(year, weekno, dayno))
#    else:
#        month = int(dtstr[pos:pos + 2])
#        pos += 2
#        if (dtstr[pos:pos + 1] == "-") != has_sep:
#            raise ValueError("Inconsistent use of dash separator")
#
#        pos += has_sep
#        day = int(dtstr[pos:pos + 2])
#
#        return [year, month, day]
#
#
alias _FRACTION_CORRECTION = list[Int].from_values(100000, 10000, 1000, 100, 10)


#
#
# def _parse_hh_mm_ss_ff(tstr):
#    # Parses things of the form HH[:?MM[:?SS[{.,}fff[fff]]]]
#    len_str = len(tstr)
#
#    time_comps = [0, 0, 0, 0]
#    pos = 0
#    for comp in range(0, 3):
#        if (len_str - pos) < 2:
#            raise ValueError("Incomplete time component")
#
#        time_comps[comp] = int(tstr[pos:pos+2])
#
#        pos += 2
#        next_char = tstr[pos:pos+1]
#
#        if comp == 0:
#            has_sep = next_char == ':'
#
#        if not next_char or comp >= 2:
#            break
#
#        if has_sep and next_char != ':':
#            raise ValueError("Invalid time separator: %c" % next_char)
#
#        pos += has_sep
#
#    if pos < len_str:
#        if tstr[pos] not in '.,':
#            raise ValueError("Invalid microsecond component")
#        else:
#            pos += 1
#
#            len_remainder = len_str - pos
#
#            if len_remainder >= 6:
#                to_parse = 6
#            else:
#                to_parse = len_remainder
#
#            time_comps[3] = int(tstr[pos:(pos+to_parse)])
#            if to_parse < 6:
#                time_comps[3] *= _FRACTION_CORRECTION[to_parse-1]
#            if (len_remainder > to_parse
#                    and not all(map(_is_ascii_digit, tstr[(pos+to_parse):]))):
#                raise ValueError("Non-digit values in unparsed fraction")
#
#    return time_comps
#
# def _parse_isoformat_time(tstr):
#    # Format supported is HH[:MM[:SS[.fff[fff]]]][+HH:MM[:SS[.ffffff]]]
#    len_str = len(tstr)
#    if len_str < 2:
#        raise ValueError("Isoformat time too short")
#
#    # This is equivalent to re.search('[+-Z]', tstr), but faster
#    tz_pos = (tstr.find('-') + 1 or tstr.find('+') + 1 or tstr.find('Z') + 1)
#    timestr = tstr[:tz_pos-1] if tz_pos > 0 else tstr
#
#    time_comps = _parse_hh_mm_ss_ff(timestr)
#
#    tzi = None
#    if tz_pos == len_str and tstr[-1] == 'Z':
#        tzi = timezone.utc
#    elif tz_pos > 0:
#        tzstr = tstr[tz_pos:]
#
#        # Valid time zone strings are:
#        # HH                  len: 2
#        # HHMM                len: 4
#        # HH:MM               len: 5
#        # HHMMSS              len: 6
#        # HHMMSS.f+           len: 7+
#        # HH:MM:SS            len: 8
#        # HH:MM:SS.f+         len: 10+
#
#        if len(tzstr) in (0, 1, 3):
#            raise ValueError("Malformed time zone string")
#
#        tz_comps = _parse_hh_mm_ss_ff(tzstr)
#
#        if all(x == 0 for x in tz_comps):
#            tzi = timezone.utc
#        else:
#            tzsign = -1 if tstr[tz_pos - 1] == '-' else 1
#
#            td = timedelta(hours=tz_comps[0], minutes=tz_comps[1],
#                           seconds=tz_comps[2], microseconds=tz_comps[3])
#
#            tzi = timezone(tzsign * td)
#
#    time_comps.append(tzi)
#
#    return time_comps
#
## tuple[int, int, int] -> tuple[int, int, int] version of date.fromisocalendar
# def _isoweek_to_gregorian(year, week, day):
#    # Year is bounded this way because 9999-12-31 is (9999, 52, 5)
#    if not MINYEAR <= year <= MAXYEAR:
#        raise ValueError(f"Year is out of range: {year}")
#
#    if not 0 < week < 53:
#        out_of_range = True
#
#        if week == 53:
#            # ISO years have 53 weeks in them on years starting with a
#            # Thursday and leap years starting on a Wednesday
#            first_weekday = _ymd2ord(year, 1, 1) % 7
#            if (first_weekday == 4 or (first_weekday == 3 and
#                                       _is_leap(year))):
#                out_of_range = False
#
#        if out_of_range:
#            raise ValueError(f"Invalid week: {week}")
#
#    if not 0 < day < 8:
#        raise ValueError(f"Invalid weekday: {day} (range is [1, 7])")
#
#    # Now compute the offset from (Y, 1, 1) in days:
#    day_offset = (week - 1) * 7 + (day - 1)
#
#    # Calculate the ordinal day for monday, week 1
#    day_1 = _isoweek1monday(year)
#    ord_day = day_1 + day_offset
#
#    return _ord2ymd(ord_day)
#
#
## Just raise TypeError if the arg isn't None or a string.
# def _check_tzname(name):
#    if name is not None and not isinstance(name, str):
#        raise TypeError("tzinfo.tzname() must return None or string, "
#                        "not '%s'" % type(name))
#
## name is the offset-producing method, "utcoffset" or "dst".
## offset is what it returned.
## If offset isn't None or timedelta, raises TypeError.
## If offset is None, returns None.
## Else offset is checked for being in range.
## If it is, its integer value is returned.  Else ValueError is raised.
# def _check_utc_offset(name, offset):
#    assert name in ("utcoffset", "dst")
#    if offset is None:
#        return
#    if not isinstance(offset, timedelta):
#        raise TypeError("tzinfo.%s() must return None "
#                        "or timedelta, not '%s'" % (name, type(offset)))
#    if not -timedelta(1) < offset < timedelta(1):
#        raise ValueError("%s()=%s, must be strictly between "
#                         "-timedelta(hours=24) and timedelta(hours=24)" %
#                         (name, offset))
#
# def _check_date_fields(year, month, day):
#    year = _index(year)
#    month = _index(month)
#    day = _index(day)
#    if not MINYEAR <= year <= MAXYEAR:
#        raise ValueError('year must be in %d..%d' % (MINYEAR, MAXYEAR), year)
#    if not 1 <= month <= 12:
#        raise ValueError('month must be in 1..12', month)
#    dim = _days_in_month(year, month)
#    if not 1 <= day <= dim:
#        raise ValueError('day must be in 1..%d' % dim, day)
#    return year, month, day
#
# def _check_time_fields(hour, minute, second, microsecond, fold):
#    hour = _index(hour)
#    minute = _index(minute)
#    second = _index(second)
#    microsecond = _index(microsecond)
#    if not 0 <= hour <= 23:
#        raise ValueError('hour must be in 0..23', hour)
#    if not 0 <= minute <= 59:
#        raise ValueError('minute must be in 0..59', minute)
#    if not 0 <= second <= 59:
#        raise ValueError('second must be in 0..59', second)
#    if not 0 <= microsecond <= 999999:
#        raise ValueError('microsecond must be in 0..999999', microsecond)
#    if fold not in (0, 1):
#        raise ValueError('fold must be either 0 or 1', fold)
#    return hour, minute, second, microsecond, fold
#
# def _check_tzinfo_arg(tz):
#    if tz is not None and not isinstance(tz, tzinfo):
#        raise TypeError("tzinfo argument must be None or of a tzinfo subclass")
#
# def _cmperror(x, y):
#    raise TypeError("can't compare '%s' to '%s'" % (
#                    type(x).__name__, type(y).__name__))
#
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
@value
struct timedelta(CollectionElement, Stringable):
    """Represent the difference between two datetime objects.

    Supported operators:

    - add, subtract timedelta
    - unary plus, minus, abs
    - compare to timedelta
    - multiply, divide by int

    In addition, datetime supports subtraction of two datetime objects
    returning a timedelta, and addition or subtraction of a datetime
    and a timedelta giving a datetime.

    Representation: (days, seconds, microseconds).
    """

    # The representation of (days, seconds, microseconds) was chosen
    # arbitrarily; the exact rationale originally specified in the docstring
    # was "Because I felt like it."

    var days: Int
    var seconds: Int
    var microseconds: Int
    var _hashcode: Int

    alias min = timedelta(-999999999)
    alias max = timedelta(
        days=999999999, hours=23, minutes=59, seconds=59, microseconds=999999
    )
    alias resolution = timedelta(microseconds=1)

    fn __init__(
        inout self,
        owned days: Int = 0,
        owned seconds: Int = 0,
        owned microseconds: Int = 0,
        milliseconds: Int = 0,
        minutes: Int = 0,
        hours: Int = 0,
        weeks: Int = 0,
    ):
        # Doing this efficiently and accurately in C is going to be difficult
        # and error-prone, due to ubiquitous overflow possibilities, and that
        # C double doesn't have enough bits of precision to represent
        # microseconds over 10K years faithfully.  The code here tries to make
        # explicit where go-fast assumptions can be relied on, in order to
        # guide the C implementation; it's way more convoluted than speed-
        # ignoring auto-overflow-to-long idiomatic Python could be.

        # XXX Check that all inputs are ints or floats.

        # Final values, all integer.
        # s and us fit in 32-bit signed ints; d isn't bounded.
        var d = 0
        var s = 0
        var us = 0

        # Normalize everything to days, seconds, microseconds.
        days += weeks * 7
        seconds += minutes * 60 + hours * 3600
        microseconds += milliseconds * 1000

        # Get rid of all fractions, and normalize s and us.
        # Take a deep breath <wink>.
        # if isinstance(days, float):
        #    dayfrac, days = _math.modf(days)
        #    daysecondsfrac, daysecondswhole = _math.modf(dayfrac * (24.*3600.))
        #    assert daysecondswhole == int(daysecondswhole)  # can't overflow
        #    s = int(daysecondswhole)
        #    assert days == int(days)
        #    d = int(days)
        # else:
        var daysecondsfrac = 0.0
        d = days
        # TODO: manage floats

        # assert isinstance(daysecondsfrac, float)
        # assert abs(daysecondsfrac) <= 1.0
        # assert isinstance(d, int)
        # assert abs(s) <= 24 * 3600
        # days isn't referenced again before redefinition

        # if isinstance(seconds, float):
        #    secondsfrac, seconds = _math.modf(seconds)
        #    assert seconds == int(seconds)
        #    seconds = int(seconds)
        #    secondsfrac += daysecondsfrac
        #    assert abs(secondsfrac) <= 2.0
        # else:
        var secondsfrac = daysecondsfrac
        # TODO: Manage floats

        # daysecondsfrac isn't referenced again
        # assert isinstance(secondsfrac, float)
        # assert abs(secondsfrac) <= 2.0

        # assert isinstance(seconds, int)
        days, seconds = divmod(seconds, 24 * 3600)
        d += days
        s += int(seconds)  # can't overflow
        # assert isinstance(s, int)
        # assert abs(s) <= 2 * 24 * 3600
        # seconds isn't referenced again before redefinition

        var usdouble = secondsfrac * 1e6
        # assert abs(usdouble) < 2.1e6    # exact value not critical
        # secondsfrac isn't referenced again

        # if isinstance(microseconds, float):
        #    microseconds = round(microseconds + usdouble)
        #    seconds, microseconds = divmod(microseconds, 1000000)
        #    days, seconds = divmod(seconds, 24*3600)
        #    d += days
        #    s += seconds
        # else:
        microseconds = int(microseconds)
        seconds, microseconds = divmod(microseconds, 1000000)
        days, seconds = divmod(seconds, 24 * 3600)
        d += days
        s += seconds
        microseconds = round(microseconds + usdouble)
        # TODO: Manage floats
        # assert isinstance(s, int)
        # assert isinstance(microseconds, int)
        # assert abs(s) <= 3 * 24 * 3600
        # assert abs(microseconds) < 3.1e6

        # Just a little bit of carrying possible for microseconds and seconds.
        seconds, us = divmod(microseconds, 1000000)
        s += seconds
        days, s = divmod(s, 24 * 3600)
        d += days

        # assert isinstance(d, int)
        # assert isinstance(s, int) and 0 <= s < 24 * 3600
        # assert isinstance(us, int) and 0 <= us < 1000000

        if abs(d) > 999999999:
            pass
            # raise OverflowError("timedelta # of days is too large: %d" % d)

        self.days = d
        self.seconds = s
        self.microseconds = us
        self._hashcode = -1

    fn __repr__(self) -> String:
        var args = list[String]()
        if self.days:
            args.append("days=" + str(self.days))
        if self.seconds:
            args.append("seconds=" + str(self.seconds))
        if self.microseconds:
            args.append("microseconds=" + str(self.microseconds))
        if len(args) == 0:
            args.append("0")
        try:
            return "datetime.timedelta(" + join(", ", args) + ")"
        except Error:
            # can never happen
            return "datetime.timedelta(BUG REPORT ME)"

    fn __str__(self) -> String:
        var mm: Int
        var ss: Int
        var hh: Int
        mm, ss = divmod(self.seconds, 60)
        hh, mm = divmod(mm, 60)
        var s = str(hh)
        try:
            s += ":" + rjust(str(mm), 2, "0")
            s += ":" + rjust(str(ss), 2, "0")
            if self.days:
                var plural: String = ""
                if abs(self.days) != 1:
                    plural = "s"
                s = str(self.days) + " day" + plural + ", " + s
            if self.microseconds:
                s = s + "." + rjust(str(self.microseconds), 6, "0")
            return s
        except Error:
            # can never happen
            return "timedelta __str__ error, report me."

    fn total_seconds(self) -> Int:
        """Total seconds in the duration."""
        return (
            (self.days * 86400 + self.seconds) * 10**6 + self.microseconds
        ) // 10**6

    fn __add__(self, other: timedelta) -> timedelta:
        return timedelta(
            self.days + other.days,
            self.seconds + other.seconds,
            self.microseconds + other.microseconds,
        )

    fn __sub__(self, other: timedelta) -> timedelta:
        return timedelta(
            self.days - other.days,
            self.seconds - other.seconds,
            self.microseconds - other.microseconds,
        )

    fn __neg__(self) -> timedelta:
        return timedelta(-self.days, -self.seconds, -self.microseconds)

    fn __pos__(self) -> timedelta:
        return self

    def __abs__(self) -> timedelta:
        if self.days < 0:
            return -self
        else:
            return self

    fn __mul__(self, other: Int) -> timedelta:
        return timedelta(
            self.days * other, self.seconds * other, self.microseconds * other
        )

    # TODO: support multiplying by a float

    fn _to_microseconds(self) -> Int64:
        # we return an Int64 because the result may overflow a 32-bit int
        return (self.days * (24 * 3600) + self.seconds) * 1000000 + self.microseconds

    fn __floordiv__(self, other: timedelta) -> Int64:
        return self._to_microseconds() // other._to_microseconds()

    fn __floordiv__(self, other: Int) -> timedelta:
        return timedelta(0, 0, (self._to_microseconds() // other).to_int())

    fn __truediv__(self, other: timedelta) -> Float64:
        return (
            self._to_microseconds().cast[DType.float64]()
            / other._to_microseconds().cast[DType.float64]()
        )

    #    if isinstance(other, int):
    #        return timedelta(0, 0, _divide_and_round(usec, other))
    #    if isinstance(other, float):
    #        a, b = other.as_integer_ratio()
    #        return timedelta(0, 0, _divide_and_round(b * usec, a))

    fn __mod__(self, other: timedelta) -> timedelta:
        var r = self._to_microseconds() % other._to_microseconds()
        return timedelta(0, 0, r.to_int())

    fn __divmod__(self, other: timedelta) -> Tuple[Int, timedelta]:
        var q: Int64
        var r: Int64
        q, r = divmod(self._to_microseconds(), other._to_microseconds())
        return q.to_int(), timedelta(0, 0, r.to_int())

    # Comparisons of timedelta objects with other.
    # functools.total_ordering would be useful here if available

    fn __eq__(self, other: timedelta) -> Bool:
        return (
            self.days == other.days
            and self.seconds == other.seconds
            and self.microseconds == other.microseconds
        )

    fn __le__(self, other: timedelta) -> Bool:
        return self._cmp(other) <= 0

    fn __lt__(self, other: timedelta) -> Bool:
        return self._cmp(other) < 0

    fn __ge__(self, other: timedelta) -> Bool:
        return self._cmp(other) >= 0

    fn __gt__(self, other: timedelta) -> Bool:
        return self._cmp(other) > 0

    fn _cmp(self, other: timedelta) -> Int:
        return _cmp_list(self._getstate(), other._getstate())

    fn __hash__(inout self) -> Int:
        if self._hashcode == -1:
            self._hashcode = custom_hash(self._getstate())
        return self._hashcode

    fn __bool__(self) -> Bool:
        return self.days != 0 or self.seconds != 0 or self.microseconds != 0

    # Pickle support.

    @always_inline
    fn _getstate(self) -> list[Int]:
        return list[Int].from_values(self.days, self.seconds, self.microseconds)


#    def __reduce__(self):
#        return (self.__class__, self._getstate())
#


struct date:
    """Concrete date type.

    Constructors:

    __new__()
    fromtimestamp()
    today()
    fromordinal()

    Operators:

    __repr__, __str__
    __eq__, __le__, __lt__, __ge__, __gt__, __hash__
    __add__, __radd__, __sub__ (add/radd only with timedelta arg)

    Methods:

    timetuple()
    toordinal()
    weekday()
    isoweekday(), isocalendar(), isoformat()
    ctime()
    strftime()

    Properties (readonly):
    year, month, day
    """

    alias min = date(1, 1, 1)
    alias max = date(9999, 12, 31)
    alias resolution = timedelta(days=1)

    var year: Int
    var month: Int
    var day: Int
    var _hashcode: Int

    fn __init__(inout self, year: Int, month: Int, day: Int):
        """Constructor.

        Arguments:

        year, month, day (required, base 1)
        """
        # year, month, day = _check_date_fields(year, month, day)

        self.year = year
        self.month = month
        self.day = day
        self._hashcode = -1

    # Additional constructors
    #
    #    @classmethod
    #    def fromtimestamp(cls, t):
    #        "Construct a date from a POSIX timestamp (like time.time())."
    #        y, m, d, hh, mm, ss, weekday, jday, dst = _time.localtime(t)
    #        return cls(y, m, d)
    #
    #    @classmethod
    #    def today(cls):
    #        "Construct a date from time.time()."
    #        t = _time.time()
    #        return cls.fromtimestamp(t)
    #
    #    @classmethod
    #    def fromordinal(cls, n):
    #        """Construct a date from a proleptic Gregorian ordinal.
    #
    #        January 1 of year 1 is day 1.  Only the year, month and day are
    #        non-zero in the result.
    #        """
    #        y, m, d = _ord2ymd(n)
    #        return cls(y, m, d)
    #
    #    @classmethod
    #    def fromisoformat(cls, date_string):
    #        """Construct a date from a string in ISO 8601 format."""
    #        if not isinstance(date_string, str):
    #            raise TypeError('fromisoformat: argument must be str')
    #
    #        if len(date_string) not in (7, 8, 10):
    #            raise ValueError(f'Invalid isoformat string: {date_string!r}')
    #
    #        try:
    #            return cls(*_parse_isoformat_date(date_string))
    #        except Exception:
    #            raise ValueError(f'Invalid isoformat string: {date_string!r}')
    #
    #    @classmethod
    #    def fromisocalendar(cls, year, week, day):
    #        """Construct a date from the ISO year, week number and weekday.
    #
    #        This is the inverse of the date.isocalendar() function"""
    #        return cls(*_isoweek_to_gregorian(year, week, day))
    #
    #    # Conversions to string
    fn __repr__(self) -> String:
        """Convert to formal string, for repr().

        >>> d = date(2010, 1, 1)
        >>> repr(d)
        'datetime.date(2010, 1, 1)'
        """
        return (
            "datetime.date("
            + str(self.year)
            + ", "
            + str(self.month)
            + ", "
            + str(self.day)
            + ")"
        )

    #    # XXX These shouldn't depend on time.localtime(), because that
    #    # clips the usable dates to [1970 .. 2038).  At least ctime() is
    #    # easily done without using strftime() -- that's better too because
    #    # strftime("%c", ...) is locale specific.
    #
    #
    #    def ctime(self):
    #        "Return ctime() style string."
    #        weekday = self.toordinal() % 7 or 7
    #        return "%s %s %2d 00:00:00 %04d" % (
    #            _DAYNAMES[weekday],
    #            _MONTHNAMES[self._month],
    #            self._day, self._year)
    #
    #    def strftime(self, format):
    #        """
    #        Format using strftime().
    #
    #        Example: "%d/%m/%Y, %H:%M:%S"
    #        """
    #        return _wrap_strftime(self, format, self.timetuple())
    #
    #    def __format__(self, fmt):
    #        if not isinstance(fmt, str):
    #            raise TypeError("must be str, not %s" % type(fmt).__name__)
    #        if len(fmt) != 0:
    #            return self.strftime(fmt)
    #        return str(self)
    #
    fn isoformat(self) -> String:
        """Return the date formatted according to ISO.

        This is 'YYYY-MM-DD'.

        References:
        - http://www.w3.org/TR/NOTE-datetime
        - http://www.cl.cam.ac.uk/~mgk25/iso-time.html
        """
        try:
            return (
                rjust(str(self.year), 4, "0")
                + "-"
                + rjust(str(self.month), 2, "0")
                + "-"
                + rjust(str(self.day), 2, "0")
            )
        except Error:
            # can never happen
            return "error in date.isoformat"

    fn __str__(self) -> String:
        """Convert to string, for str().

        >>> d = date(2010, 1, 1)
        >>> str(d)
        '2010-01-01'
        """
        return self.isoformat()

    #    # Standard conversions, __eq__, __le__, __lt__, __ge__, __gt__,
    #    # __hash__ (and helpers)
    #
    #    def timetuple(self):
    #        "Return local time tuple compatible with time.localtime()."
    #        return _build_struct_time(self._year, self._month, self._day,
    #                                  0, 0, 0, -1)
    #
    #    def toordinal(self):
    #        """Return proleptic Gregorian ordinal for the year, month and day.
    #
    #        January 1 of year 1 is day 1.  Only the year, month and day values
    #        contribute to the result.
    #        """
    #        return _ymd2ord(self._year, self._month, self._day)
    #
    def replace(
        self,
        owned year: Optional[Int] = None,
        owned month: Optional[Int] = None,
        owned day: Optional[Int] = None,
    ) -> date:
        """Return a new date with new values for the specified fields."""
        if year is None:
            year = self.year
        if month is None:
            month = self.month
        if day is None:
            day = self.day
        return date(year.value(), month.value(), day.value())

    #
    #    __replace__ = replace
    #
    #    # Comparisons of date objects with other.
    #
    #    def __eq__(self, other):
    #        if isinstance(other, date):
    #            return self._cmp(other) == 0
    #        return NotImplemented
    #
    #    def __le__(self, other):
    #        if isinstance(other, date):
    #            return self._cmp(other) <= 0
    #        return NotImplemented
    #
    #    def __lt__(self, other):
    #        if isinstance(other, date):
    #            return self._cmp(other) < 0
    #        return NotImplemented
    #
    #    def __ge__(self, other):
    #        if isinstance(other, date):
    #            return self._cmp(other) >= 0
    #        return NotImplemented
    #
    #    def __gt__(self, other):
    #        if isinstance(other, date):
    #            return self._cmp(other) > 0
    #        return NotImplemented
    #
    #    def _cmp(self, other):
    #        assert isinstance(other, date)
    #        y, m, d = self._year, self._month, self._day
    #        y2, m2, d2 = other._year, other._month, other._day
    #        return _cmp((y, m, d), (y2, m2, d2))
    #
    #    def __hash__(self):
    #        "Hash."
    #        if self._hashcode == -1:
    #            self._hashcode = hash(self._getstate())
    #        return self._hashcode
    #
    #    # Computations
    #
    #    def __add__(self, other):
    #        "Add a date to a timedelta."
    #        if isinstance(other, timedelta):
    #            o = self.toordinal() + other.days
    #            if 0 < o <= _MAXORDINAL:
    #                return type(self).fromordinal(o)
    #            raise OverflowError("result out of range")
    #        return NotImplemented
    #
    #    __radd__ = __add__
    #
    #    def __sub__(self, other):
    #        """Subtract two dates, or a date and a timedelta."""
    #        if isinstance(other, timedelta):
    #            return self + timedelta(-other.days)
    #        if isinstance(other, date):
    #            days1 = self.toordinal()
    #            days2 = other.toordinal()
    #            return timedelta(days1 - days2)
    #        return NotImplemented
    #
    #    def weekday(self):
    #        "Return day of the week, where Monday == 0 ... Sunday == 6."
    #        return (self.toordinal() + 6) % 7
    #
    #    # Day-of-the-week and week-of-the-year, according to ISO
    #
    #    def isoweekday(self):
    #        "Return day of the week, where Monday == 1 ... Sunday == 7."
    #        # 1-Jan-0001 is a Monday
    #        return self.toordinal() % 7 or 7
    #
    #    def isocalendar(self):
    #        """Return a named tuple containing ISO year, week number, and weekday.
    #
    #        The first ISO week of the year is the (Mon-Sun) week
    #        containing the year's first Thursday; everything else derives
    #        from that.
    #
    #        The first week is 1; Monday is 1 ... Sunday is 7.
    #
    #        ISO calendar algorithm taken from
    #        http://www.phys.uu.nl/~vgent/calendar/isocalendar.htm
    #        (used with permission)
    #        """
    #        year = self._year
    #        week1monday = _isoweek1monday(year)
    #        today = _ymd2ord(self._year, self._month, self._day)
    #        # Internally, week and day have origin 0
    #        week, day = divmod(today - week1monday, 7)
    #        if week < 0:
    #            year -= 1
    #            week1monday = _isoweek1monday(year)
    #            week, day = divmod(today - week1monday, 7)
    #        elif week >= 52:
    #            if today >= _isoweek1monday(year+1):
    #                year += 1
    #                week = 0
    #        return _IsoCalendarDate(year, week+1, day+1)
    #
    #    # Pickle support.
    #
    fn _getstate(self) -> bytes:
        var yhi: Int
        var ylo: Int
        yhi, ylo = divmod(self.year, 256)
        return bytes.from_values(yhi, ylo, self.month, self.day)


#    def __setstate(self, string):
#        yhi, ylo, self._month, self._day = string
#        self._year = yhi * 256 + ylo
#
#    def __reduce__(self):
#        return (self.__class__, self._getstate())


#
#
trait tzinfo(CollectionElement):
    """Abstract base class for time zone info classes.

    Subclasses must override the tzname(), utcoffset(), dst(), and fromutc() methods.
    """

    fn tzname(self, dt: datetime) -> String:
        """Name of time zone."""
        ...

    fn utcoffset(self, dt: datetime) -> timedelta:
        """Positive for east of UTC, negative for west of UTC."""
        ...

    fn dst(self, dt: datetime) -> timedelta:
        """From datetime -> DST offset as timedelta, positive for east of UTC.

        Return 0 if DST not in effect.  utcoffset() must include the DST
        offset.
        """
        ...

    # fn fromutc(self: Self, dt: datetime) -> datetime[Self]:
    #    # use the default function below
    #    ...


# def fromutc[T: tzinfo](self: T, dt: datetime[T]) -> datetime:
#    """From datetime in UTC to datetime in local time."""
#    if dt.tzinfo is not self:
#        raise ValueError("dt.tzinfo is not self")
#    dtoff = dt.utcoffset()
#    if dtoff is None:
#        raise ValueError("fromutc() requires a non-None utcoffset() "
#                         "result")
#    # See the long comment block at the end of this file for an
#    # explanation of this algorithm.
#    dtdst = dt.dst()
#    if dtdst is None:
#        raise ValueError("fromutc() requires a non-None dst() result")
#    delta = dtoff - dtdst
#    if delta:
#        dt += delta
#        dtdst = dt.dst()
#        if dtdst is None:
#            raise ValueError("fromutc(): dt.dst gave inconsistent "
#                             "results; cannot convert")
#    return dt + dtdst
#
#    # Pickle support.
#
#    def __reduce__(self):
#        getinitargs = getattr(self, "__getinitargs__", None)
#        if getinitargs:
#            args = getinitargs()
#        else:
#            args = ()
#        return (self.__class__, args, self.__getstate__())
#
#
@value
struct IsoCalendarDate:
    var year: Int
    var week: Int
    var weekday: Int

    fn __getitem__(self, index: Int) -> Int:
        if index == 0:
            return self.year
        elif index == 1:
            return self.week
        elif index == 2:
            return self.weekday
        else:
            # raise error here
            return 0

    fn __len__(self) -> Int:
        return 3

    # def __reduce__(self):
    #    # This code is intended to pickle the object without making the
    #    # class public. See https://bugs.python.org/msg352381
    #    return (tuple, (tuple(self),))

    def __repr__(self) -> String:
        return (
            "IsoCalendarDate(year="
            + str(self[0])
            + ", week="
            + str(self[1])
            + ", weekday="
            + str(self[2])
            + ")"
        )


# may be useless
alias _tzinfo_trait = tzinfo


struct time[T: _tzinfo_trait]:
    """Time with time zone.

    Constructors:

    __new__()

    Operators:

    __repr__, __str__
    __eq__, __le__, __lt__, __ge__, __gt__, __hash__

    Methods:

    strftime()
    isoformat()
    utcoffset()
    tzname()
    dst()

    Properties (readonly):
    hour, minute, second, microsecond, tzinfo, fold
    """

    var hour: Int
    var minute: Int
    var second: Int
    var microsecond: Int
    var tzinfo: Optional[T]
    var _hashcode: Int
    var fold: Int

    fn __init__(
        inout self,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        microsecond: Int = 0,
        tzinfo: Optional[T] = None,
        fold: Int = 0,
    ):
        """Constructor.

        Arguments:

        hour, minute (required)
        second, microsecond (default to zero)
        tzinfo (default to None)
        fold (keyword only, default to zero)
        """
        # hour, minute, second, microsecond, fold = _check_time_fields(
        #    hour, minute, second, microsecond, fold)
        # _check_tzinfo_arg(tzinfo)
        self.hour = hour
        self.minute = minute
        self.second = second
        self.microsecond = microsecond
        self.tzinfo = tzinfo
        self._hashcode = -1
        self.fold = fold

    #    # Standard conversions, __hash__ (and helpers)
    #
    #    # Comparisons of time objects with other.
    #
    #    def __eq__(self, other):
    #        if isinstance(other, time):
    #            return self._cmp(other, allow_mixed=True) == 0
    #        else:
    #            return NotImplemented
    #
    #    def __le__(self, other):
    #        if isinstance(other, time):
    #            return self._cmp(other) <= 0
    #        else:
    #            return NotImplemented
    #
    #    def __lt__(self, other):
    #        if isinstance(other, time):
    #            return self._cmp(other) < 0
    #        else:
    #            return NotImplemented
    #
    #    def __ge__(self, other):
    #        if isinstance(other, time):
    #            return self._cmp(other) >= 0
    #        else:
    #            return NotImplemented
    #
    #    def __gt__(self, other):
    #        if isinstance(other, time):
    #            return self._cmp(other) > 0
    #        else:
    #            return NotImplemented
    #
    #    def _cmp(self, other, allow_mixed=False):
    #        assert isinstance(other, time)
    #        mytz = self._tzinfo
    #        ottz = other._tzinfo
    #        myoff = otoff = None
    #
    #        if mytz is ottz:
    #            base_compare = True
    #        else:
    #            myoff = self.utcoffset()
    #            otoff = other.utcoffset()
    #            base_compare = myoff == otoff
    #
    #        if base_compare:
    #            return _cmp((self._hour, self._minute, self._second,
    #                         self._microsecond),
    #                        (other._hour, other._minute, other._second,
    #                         other._microsecond))
    #        if myoff is None or otoff is None:
    #            if allow_mixed:
    #                return 2 # arbitrary non-zero value
    #            else:
    #                raise TypeError("cannot compare naive and aware times")
    #        myhhmm = self._hour * 60 + self._minute - myoff//timedelta(minutes=1)
    #        othhmm = other._hour * 60 + other._minute - otoff//timedelta(minutes=1)
    #        return _cmp((myhhmm, self._second, self._microsecond),
    #                    (othhmm, other._second, other._microsecond))
    #
    #    def __hash__(self):
    #        """Hash."""
    #        if self._hashcode == -1:
    #            if self.fold:
    #                t = self.replace(fold=0)
    #            else:
    #                t = self
    #            tzoff = t.utcoffset()
    #            if not tzoff:  # zero or None
    #                self._hashcode = hash(t._getstate()[0])
    #            else:
    #                h, m = divmod(timedelta(hours=self.hour, minutes=self.minute) - tzoff,
    #                              timedelta(hours=1))
    #                assert not m % timedelta(minutes=1), "whole minute"
    #                m //= timedelta(minutes=1)
    #                if 0 <= h < 24:
    #                    self._hashcode = hash(time(h, m, self.second, self.microsecond))
    #                else:
    #                    self._hashcode = hash((h, m, self.second, self.microsecond))
    #        return self._hashcode
    #
    #    # Conversion to string
    #
    #    def _tzstr(self):
    #        """Return formatted timezone offset (+xx:xx) or an empty string."""
    #        off = self.utcoffset()
    #        return _format_offset(off)
    #
    #    def __repr__(self):
    #        """Convert to formal string, for repr()."""
    #        if self._microsecond != 0:
    #            s = ", %d, %d" % (self._second, self._microsecond)
    #        elif self._second != 0:
    #            s = ", %d" % self._second
    #        else:
    #            s = ""
    #        s= "%s.%s(%d, %d%s)" % (_get_class_module(self),
    #                                self.__class__.__qualname__,
    #                                self._hour, self._minute, s)
    #        if self._tzinfo is not None:
    #            assert s[-1:] == ")"
    #            s = s[:-1] + ", tzinfo=%r" % self._tzinfo + ")"
    #        if self._fold:
    #            assert s[-1:] == ")"
    #            s = s[:-1] + ", fold=1)"
    #        return s
    #
    #    def isoformat(self, timespec='auto'):
    #        """Return the time formatted according to ISO.
    #
    #        The full format is 'HH:MM:SS.mmmmmm+zz:zz'. By default, the fractional
    #        part is omitted if self.microsecond == 0.
    #
    #        The optional argument timespec specifies the number of additional
    #        terms of the time to include. Valid options are 'auto', 'hours',
    #        'minutes', 'seconds', 'milliseconds' and 'microseconds'.
    #        """
    #        s = _format_time(self._hour, self._minute, self._second,
    #                          self._microsecond, timespec)
    #        tz = self._tzstr()
    #        if tz:
    #            s += tz
    #        return s
    #
    #    __str__ = isoformat
    #
    #    @classmethod
    #    def fromisoformat(cls, time_string):
    #        """Construct a time from a string in one of the ISO 8601 formats."""
    #        if not isinstance(time_string, str):
    #            raise TypeError('fromisoformat: argument must be str')
    #
    #        # The spec actually requires that time-only ISO 8601 strings start with
    #        # T, but the extended format allows this to be omitted as long as there
    #        # is no ambiguity with date strings.
    #        time_string = time_string.removeprefix('T')
    #
    #        try:
    #            return cls(*_parse_isoformat_time(time_string))
    #        except Exception:
    #            raise ValueError(f'Invalid isoformat string: {time_string!r}')
    #
    #    def strftime(self, format):
    #        """Format using strftime().  The date part of the timestamp passed
    #        to underlying strftime should not be used.
    #        """
    #        # The year must be >= 1000 else Python's strftime implementation
    #        # can raise a bogus exception.
    #        timetuple = (1900, 1, 1,
    #                     self._hour, self._minute, self._second,
    #                     0, 1, -1)
    #        return _wrap_strftime(self, format, timetuple)
    #
    #    def __format__(self, fmt):
    #        if not isinstance(fmt, str):
    #            raise TypeError("must be str, not %s" % type(fmt).__name__)
    #        if len(fmt) != 0:
    #            return self.strftime(fmt)
    #        return str(self)
    #
    #    # Timezone functions
    #
    #    def utcoffset(self):
    #        """Return the timezone offset as timedelta, positive east of UTC
    #         (negative west of UTC)."""
    #        if self._tzinfo is None:
    #            return None
    #        offset = self._tzinfo.utcoffset(None)
    #        _check_utc_offset("utcoffset", offset)
    #        return offset
    #
    #    def tzname(self):
    #        """Return the timezone name.
    #
    #        Note that the name is 100% informational -- there's no requirement that
    #        it mean anything in particular. For example, "GMT", "UTC", "-500",
    #        "-5:00", "EDT", "US/Eastern", "America/New York" are all valid replies.
    #        """
    #        if self._tzinfo is None:
    #            return None
    #        name = self._tzinfo.tzname(None)
    #        _check_tzname(name)
    #        return name
    #
    #    def dst(self):
    #        """Return 0 if DST is not in effect, or the DST offset (as timedelta
    #        positive eastward) if DST is in effect.
    #
    #        This is purely informational; the DST offset has already been added to
    #        the UTC offset returned by utcoffset() if applicable, so there's no
    #        need to consult dst() unless you're interested in displaying the DST
    #        info.
    #        """
    #        if self._tzinfo is None:
    #            return None
    #        offset = self._tzinfo.dst(None)
    #        _check_utc_offset("dst", offset)
    #        return offset
    #
    # parser is crashing here for some reason
    # fn replace(
    #    self,
    #    owned hour: Optional[Int] = None,
    #    owned minute: Optional[Int] = None,
    #    owned second: Optional[Int] = None,
    #    owned microsecond: Optional[Int] = None,
    #    # tzinfo=True,
    #    owned fold: Optional[Int] = None,
    # ) -> time[T]:
    #    """Return a new time with new values for the specified fields."""
    #    if hour is None:
    #        hour = self.hour
    #    if minute is None:
    #        minute = self.minute
    #    if second is None:
    #        second = self.second
    #    if microsecond is None:
    #        microsecond = self.microsecond
    #    # if tzinfo is True:
    #    #    tzinfo = self.tzinfo
    #    if fold is None:
    #        fold = self.fold
    #    return time[T](
    #        hour=hour.value,
    #        minute=minute.value,
    #        second=second.value,
    #        microsecond=microsecond.value,
    #        tzinfo=self.tzinfo,
    #        fold=fold.value,
    #    )


#
#    __replace__ = replace
#
#    # Pickle support.
#
#    def _getstate(self, protocol=3):
#        us2, us3 = divmod(self._microsecond, 256)
#        us1, us2 = divmod(us2, 256)
#        h = self._hour
#        if self._fold and protocol > 3:
#            h += 128
#        basestate = bytes([h, self._minute, self._second,
#                           us1, us2, us3])
#        if self._tzinfo is None:
#            return (basestate,)
#        else:
#            return (basestate, self._tzinfo)
#
#    def __setstate(self, string, tzinfo):
#        if tzinfo is not None and not isinstance(tzinfo, _tzinfo_class):
#            raise TypeError("bad tzinfo state arg")
#        h, self._minute, self._second, us1, us2, us3 = string
#        if h > 127:
#            self._fold = 1
#            self._hour = h - 128
#        else:
#            self._fold = 0
#            self._hour = h
#        self._microsecond = (((us1 << 8) | us2) << 8) | us3
#        self._tzinfo = tzinfo
#
#    def __reduce_ex__(self, protocol):
#        return (self.__class__, self._getstate(protocol))
#
#    def __reduce__(self):
#        return self.__reduce_ex__(2)
#
# _time_class = time  # so functions w/ args named "time" can get at the class
#
# time.min = time(0, 0, 0)
# time.max = time(23, 59, 59, 999999)
# time.resolution = timedelta(microseconds=1)
#
#
@value
struct datetime(CollectionElement):
    #    """datetime(year, month, day[, hour[, minute[, second[, microsecond[,tzinfo]]]]])
    #
    #    The year, month and day arguments are required. tzinfo may be None, or an
    #    instance of a tzinfo subclass. The remaining arguments may be ints.
    #    """
    #    __slots__ = time.__slots__
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int
    var microsecond: Int
    # var tzinfo: Optional[T]

    #    def __new__(cls, year, month=None, day=None, hour=0, minute=0, second=0,
    #                microsecond=0, tzinfo=None, *, fold=0):
    #        if (isinstance(year, (bytes, str)) and len(year) == 10 and
    #            1 <= ord(year[2:3])&0x7F <= 12):
    #            # Pickle support
    #            if isinstance(year, str):
    #                try:
    #                    year = bytes(year, 'latin1')
    #                except UnicodeEncodeError:
    #                    # More informative error message.
    #                    raise ValueError(
    #                        "Failed to encode latin1 string when unpickling "
    #                        "a datetime object. "
    #                        "pickle.load(data, encoding='latin1') is assumed.")
    #            self = object.__new__(cls)
    #            self.__setstate(year, month)
    #            self._hashcode = -1
    #            return self
    #        year, month, day = _check_date_fields(year, month, day)
    #        hour, minute, second, microsecond, fold = _check_time_fields(
    #            hour, minute, second, microsecond, fold)
    #        _check_tzinfo_arg(tzinfo)
    #        self = object.__new__(cls)
    #        self._year = year
    #        self._month = month
    #        self._day = day
    #        self._hour = hour
    #        self._minute = minute
    #        self._second = second
    #        self._microsecond = microsecond
    #        self._tzinfo = tzinfo
    #        self._hashcode = -1
    #        self._fold = fold
    #        return self
    #
    #    # Read-only field accessors
    #    @property
    #    def hour(self):
    #        """hour (0-23)"""
    #        return self._hour
    #
    #    @property
    #    def minute(self):
    #        """minute (0-59)"""
    #        return self._minute
    #
    #    @property
    #    def second(self):
    #        """second (0-59)"""
    #        return self._second
    #
    #    @property
    #    def microsecond(self):
    #        """microsecond (0-999999)"""
    #        return self._microsecond
    #
    #    @property
    #    def tzinfo(self):
    #        """timezone info object"""
    #        return self._tzinfo
    #
    #    @property
    #    def fold(self):
    #        return self._fold
    #
    #    @classmethod
    #    def _fromtimestamp(cls, t, utc, tz):
    #        """Construct a datetime from a POSIX timestamp (like time.time()).
    #
    #        A timezone info object may be passed in as well.
    #        """
    #        frac, t = _math.modf(t)
    #        us = round(frac * 1e6)
    #        if us >= 1000000:
    #            t += 1
    #            us -= 1000000
    #        elif us < 0:
    #            t -= 1
    #            us += 1000000
    #
    #        converter = _time.gmtime if utc else _time.localtime
    #        y, m, d, hh, mm, ss, weekday, jday, dst = converter(t)
    #        ss = min(ss, 59)    # clamp out leap seconds if the platform has them
    #        result = cls(y, m, d, hh, mm, ss, us, tz)
    #        if tz is None and not utc:
    #            # As of version 2015f max fold in IANA database is
    #            # 23 hours at 1969-09-30 13:00:00 in Kwajalein.
    #            # Let's probe 24 hours in the past to detect a transition:
    #            max_fold_seconds = 24 * 3600
    #
    #            # On Windows localtime_s throws an OSError for negative values,
    #            # thus we can't perform fold detection for values of time less
    #            # than the max time fold. See comments in _datetimemodule's
    #            # version of this method for more details.
    #            if t < max_fold_seconds and sys.platform.startswith("win"):
    #                return result
    #
    #            y, m, d, hh, mm, ss = converter(t - max_fold_seconds)[:6]
    #            probe1 = cls(y, m, d, hh, mm, ss, us, tz)
    #            trans = result - probe1 - timedelta(0, max_fold_seconds)
    #            if trans.days < 0:
    #                y, m, d, hh, mm, ss = converter(t + trans // timedelta(0, 1))[:6]
    #                probe2 = cls(y, m, d, hh, mm, ss, us, tz)
    #                if probe2 == result:
    #                    result._fold = 1
    #        elif tz is not None:
    #            result = tz.fromutc(result)
    #        return result
    #
    #    @classmethod
    #    def fromtimestamp(cls, timestamp, tz=None):
    #        """Construct a datetime from a POSIX timestamp (like time.time()).
    #
    #        A timezone info object may be passed in as well.
    #        """
    #        _check_tzinfo_arg(tz)
    #
    #        return cls._fromtimestamp(timestamp, tz is not None, tz)
    #
    #
    #    @classmethod
    #    def now(cls, tz=None):
    #        "Construct a datetime from time.time() and optional time zone info."
    #        t = _time.time()
    #        return cls.fromtimestamp(t, tz)
    #
    # @staticmethod
    # fn combine[T: _tzinfo_trait](date: date, time: time[T]) -> datetime[T]:
    #    "Construct a datetime from a given date and a given time."
    #    return datetime(
    #        date.year,
    #        date.month,
    #        date.day,
    #        time.hour,
    #        time.minute,
    #        time.second,
    #        time.microsecond,
    #        time.tzinfo,
    #        fold=time.fold,
    #    )


#
#    @classmethod
#    def fromisoformat(cls, date_string):
#        """Construct a datetime from a string in one of the ISO 8601 formats."""
#        if not isinstance(date_string, str):
#            raise TypeError('fromisoformat: argument must be str')
#
#        if len(date_string) < 7:
#            raise ValueError(f'Invalid isoformat string: {date_string!r}')
#
#        # Split this at the separator
#        try:
#            separator_location = _find_isoformat_datetime_separator(date_string)
#            dstr = date_string[0:separator_location]
#            tstr = date_string[(separator_location+1):]
#
#            date_components = _parse_isoformat_date(dstr)
#        except ValueError:
#            raise ValueError(
#                f'Invalid isoformat string: {date_string!r}') from None
#
#        if tstr:
#            try:
#                time_components = _parse_isoformat_time(tstr)
#            except ValueError:
#                raise ValueError(
#                    f'Invalid isoformat string: {date_string!r}') from None
#        else:
#            time_components = [0, 0, 0, 0, None]
#
#        return cls(*(date_components + time_components))
#
#    def timetuple(self):
#        "Return local time tuple compatible with time.localtime()."
#        dst = self.dst()
#        if dst is None:
#            dst = -1
#        elif dst:
#            dst = 1
#        else:
#            dst = 0
#        return _build_struct_time(self.year, self.month, self.day,
#                                  self.hour, self.minute, self.second,
#                                  dst)
#
#    def _mktime(self):
#        """Return integer POSIX timestamp."""
#        epoch = datetime(1970, 1, 1)
#        max_fold_seconds = 24 * 3600
#        t = (self - epoch) // timedelta(0, 1)
#        def local(u):
#            y, m, d, hh, mm, ss = _time.localtime(u)[:6]
#            return (datetime(y, m, d, hh, mm, ss) - epoch) // timedelta(0, 1)
#
#        # Our goal is to solve t = local(u) for u.
#        a = local(t) - t
#        u1 = t - a
#        t1 = local(u1)
#        if t1 == t:
#            # We found one solution, but it may not be the one we need.
#            # Look for an earlier solution (if `fold` is 0), or a
#            # later one (if `fold` is 1).
#            u2 = u1 + (-max_fold_seconds, max_fold_seconds)[self.fold]
#            b = local(u2) - u2
#            if a == b:
#                return u1
#        else:
#            b = t1 - u1
#            assert a != b
#        u2 = t - b
#        t2 = local(u2)
#        if t2 == t:
#            return u2
#        if t1 == t:
#            return u1
#        # We have found both offsets a and b, but neither t - a nor t - b is
#        # a solution.  This means t is in the gap.
#        return (max, min)[self.fold](u1, u2)
#
#
#    def timestamp(self):
#        "Return POSIX timestamp as float"
#        if self._tzinfo is None:
#            s = self._mktime()
#            return s + self.microsecond / 1e6
#        else:
#            return (self - _EPOCH).total_seconds()
#
#    def utctimetuple(self):
#        "Return UTC time tuple compatible with time.gmtime()."
#        offset = self.utcoffset()
#        if offset:
#            self -= offset
#        y, m, d = self.year, self.month, self.day
#        hh, mm, ss = self.hour, self.minute, self.second
#        return _build_struct_time(y, m, d, hh, mm, ss, 0)
#
#    def date(self):
#        "Return the date part."
#        return date(self._year, self._month, self._day)
#
#    def time(self):
#        "Return the time part, with tzinfo None."
#        return time(self.hour, self.minute, self.second, self.microsecond, fold=self.fold)
#
#    def timetz(self):
#        "Return the time part, with same tzinfo."
#        return time(self.hour, self.minute, self.second, self.microsecond,
#                    self._tzinfo, fold=self.fold)
#
#    def replace(self, year=None, month=None, day=None, hour=None,
#                minute=None, second=None, microsecond=None, tzinfo=True,
#                *, fold=None):
#        """Return a new datetime with new values for the specified fields."""
#        if year is None:
#            year = self.year
#        if month is None:
#            month = self.month
#        if day is None:
#            day = self.day
#        if hour is None:
#            hour = self.hour
#        if minute is None:
#            minute = self.minute
#        if second is None:
#            second = self.second
#        if microsecond is None:
#            microsecond = self.microsecond
#        if tzinfo is True:
#            tzinfo = self.tzinfo
#        if fold is None:
#            fold = self.fold
#        return type(self)(year, month, day, hour, minute, second,
#                          microsecond, tzinfo, fold=fold)
#
#    __replace__ = replace
#
#    def _local_timezone(self):
#        if self.tzinfo is None:
#            ts = self._mktime()
#            # Detect gap
#            ts2 = self.replace(fold=1-self.fold)._mktime()
#            if ts2 != ts: # This happens in a gap or a fold
#                if (ts2 > ts) == self.fold:
#                    ts = ts2
#        else:
#            ts = (self - _EPOCH) // timedelta(seconds=1)
#        localtm = _time.localtime(ts)
#        local = datetime(*localtm[:6])
#        # Extract TZ data
#        gmtoff = localtm.tm_gmtoff
#        zone = localtm.tm_zone
#        return timezone(timedelta(seconds=gmtoff), zone)
#
#    def astimezone(self, tz=None):
#        if tz is None:
#            tz = self._local_timezone()
#        elif not isinstance(tz, tzinfo):
#            raise TypeError("tz argument must be an instance of tzinfo")
#
#        mytz = self.tzinfo
#        if mytz is None:
#            mytz = self._local_timezone()
#            myoffset = mytz.utcoffset(self)
#        else:
#            myoffset = mytz.utcoffset(self)
#            if myoffset is None:
#                mytz = self.replace(tzinfo=None)._local_timezone()
#                myoffset = mytz.utcoffset(self)
#
#        if tz is mytz:
#            return self
#
#        # Convert self to UTC, and attach the new time zone object.
#        utc = (self - myoffset).replace(tzinfo=tz)
#
#        # Convert from UTC to tz's local time.
#        return tz.fromutc(utc)
#
#    # Ways to produce a string.
#
#    def ctime(self):
#        "Return ctime() style string."
#        weekday = self.toordinal() % 7 or 7
#        return "%s %s %2d %02d:%02d:%02d %04d" % (
#            _DAYNAMES[weekday],
#            _MONTHNAMES[self._month],
#            self._day,
#            self._hour, self._minute, self._second,
#            self._year)
#
#    def isoformat(self, sep='T', timespec='auto'):
#        """Return the time formatted according to ISO.
#
#        The full format looks like 'YYYY-MM-DD HH:MM:SS.mmmmmm'.
#        By default, the fractional part is omitted if self.microsecond == 0.
#
#        If self.tzinfo is not None, the UTC offset is also attached, giving
#        giving a full format of 'YYYY-MM-DD HH:MM:SS.mmmmmm+HH:MM'.
#
#        Optional argument sep specifies the separator between date and
#        time, default 'T'.
#
#        The optional argument timespec specifies the number of additional
#        terms of the time to include. Valid options are 'auto', 'hours',
#        'minutes', 'seconds', 'milliseconds' and 'microseconds'.
#        """
#        s = ("%04d-%02d-%02d%c" % (self._year, self._month, self._day, sep) +
#             _format_time(self._hour, self._minute, self._second,
#                          self._microsecond, timespec))
#
#        off = self.utcoffset()
#        tz = _format_offset(off)
#        if tz:
#            s += tz
#
#        return s
#
#    def __repr__(self):
#        """Convert to formal string, for repr()."""
#        L = [self._year, self._month, self._day,  # These are never zero
#             self._hour, self._minute, self._second, self._microsecond]
#        if L[-1] == 0:
#            del L[-1]
#        if L[-1] == 0:
#            del L[-1]
#        s = "%s.%s(%s)" % (_get_class_module(self),
#                           self.__class__.__qualname__,
#                           ", ".join(map(str, L)))
#        if self._tzinfo is not None:
#            assert s[-1:] == ")"
#            s = s[:-1] + ", tzinfo=%r" % self._tzinfo + ")"
#        if self._fold:
#            assert s[-1:] == ")"
#            s = s[:-1] + ", fold=1)"
#        return s
#
#    def __str__(self):
#        "Convert to string, for str()."
#        return self.isoformat(sep=' ')
#
#    @classmethod
#    def strptime(cls, date_string, format):
#        'string, format -> new datetime parsed from a string (like time.strptime()).'
#        import _strptime
#        return _strptime._strptime_datetime(cls, date_string, format)
#
#    def utcoffset(self):
#        """Return the timezone offset as timedelta positive east of UTC (negative west of
#        UTC)."""
#        if self._tzinfo is None:
#            return None
#        offset = self._tzinfo.utcoffset(self)
#        _check_utc_offset("utcoffset", offset)
#        return offset
#
#    def tzname(self):
#        """Return the timezone name.
#
#        Note that the name is 100% informational -- there's no requirement that
#        it mean anything in particular. For example, "GMT", "UTC", "-500",
#        "-5:00", "EDT", "US/Eastern", "America/New York" are all valid replies.
#        """
#        if self._tzinfo is None:
#            return None
#        name = self._tzinfo.tzname(self)
#        _check_tzname(name)
#        return name
#
#    def dst(self):
#        """Return 0 if DST is not in effect, or the DST offset (as timedelta
#        positive eastward) if DST is in effect.
#
#        This is purely informational; the DST offset has already been added to
#        the UTC offset returned by utcoffset() if applicable, so there's no
#        need to consult dst() unless you're interested in displaying the DST
#        info.
#        """
#        if self._tzinfo is None:
#            return None
#        offset = self._tzinfo.dst(self)
#        _check_utc_offset("dst", offset)
#        return offset
#
#    # Comparisons of datetime objects with other.
#
#    def __eq__(self, other):
#        if isinstance(other, datetime):
#            return self._cmp(other, allow_mixed=True) == 0
#        elif not isinstance(other, date):
#            return NotImplemented
#        else:
#            return False
#
#    def __le__(self, other):
#        if isinstance(other, datetime):
#            return self._cmp(other) <= 0
#        elif not isinstance(other, date):
#            return NotImplemented
#        else:
#            _cmperror(self, other)
#
#    def __lt__(self, other):
#        if isinstance(other, datetime):
#            return self._cmp(other) < 0
#        elif not isinstance(other, date):
#            return NotImplemented
#        else:
#            _cmperror(self, other)
#
#    def __ge__(self, other):
#        if isinstance(other, datetime):
#            return self._cmp(other) >= 0
#        elif not isinstance(other, date):
#            return NotImplemented
#        else:
#            _cmperror(self, other)
#
#    def __gt__(self, other):
#        if isinstance(other, datetime):
#            return self._cmp(other) > 0
#        elif not isinstance(other, date):
#            return NotImplemented
#        else:
#            _cmperror(self, other)
#
#    def _cmp(self, other, allow_mixed=False):
#        assert isinstance(other, datetime)
#        mytz = self._tzinfo
#        ottz = other._tzinfo
#        myoff = otoff = None
#
#        if mytz is ottz:
#            base_compare = True
#        else:
#            myoff = self.utcoffset()
#            otoff = other.utcoffset()
#            # Assume that allow_mixed means that we are called from __eq__
#            if allow_mixed:
#                if myoff != self.replace(fold=not self.fold).utcoffset():
#                    return 2
#                if otoff != other.replace(fold=not other.fold).utcoffset():
#                    return 2
#            base_compare = myoff == otoff
#
#        if base_compare:
#            return _cmp((self._year, self._month, self._day,
#                         self._hour, self._minute, self._second,
#                         self._microsecond),
#                        (other._year, other._month, other._day,
#                         other._hour, other._minute, other._second,
#                         other._microsecond))
#        if myoff is None or otoff is None:
#            if allow_mixed:
#                return 2 # arbitrary non-zero value
#            else:
#                raise TypeError("cannot compare naive and aware datetimes")
#        # XXX What follows could be done more efficiently...
#        diff = self - other     # this will take offsets into account
#        if diff.days < 0:
#            return -1
#        return diff and 1 or 0
#
#    def __add__(self, other):
#        "Add a datetime and a timedelta."
#        if not isinstance(other, timedelta):
#            return NotImplemented
#        delta = timedelta(self.toordinal(),
#                          hours=self._hour,
#                          minutes=self._minute,
#                          seconds=self._second,
#                          microseconds=self._microsecond)
#        delta += other
#        hour, rem = divmod(delta.seconds, 3600)
#        minute, second = divmod(rem, 60)
#        if 0 < delta.days <= _MAXORDINAL:
#            return type(self).combine(date.fromordinal(delta.days),
#                                      time(hour, minute, second,
#                                           delta.microseconds,
#                                           tzinfo=self._tzinfo))
#        raise OverflowError("result out of range")
#
#    __radd__ = __add__
#
#    def __sub__(self, other):
#        "Subtract two datetimes, or a datetime and a timedelta."
#        if not isinstance(other, datetime):
#            if isinstance(other, timedelta):
#                return self + -other
#            return NotImplemented
#
#        days1 = self.toordinal()
#        days2 = other.toordinal()
#        secs1 = self._second + self._minute * 60 + self._hour * 3600
#        secs2 = other._second + other._minute * 60 + other._hour * 3600
#        base = timedelta(days1 - days2,
#                         secs1 - secs2,
#                         self._microsecond - other._microsecond)
#        if self._tzinfo is other._tzinfo:
#            return base
#        myoff = self.utcoffset()
#        otoff = other.utcoffset()
#        if myoff == otoff:
#            return base
#        if myoff is None or otoff is None:
#            raise TypeError("cannot mix naive and timezone-aware time")
#        return base + otoff - myoff
#
#    def __hash__(self):
#        if self._hashcode == -1:
#            if self.fold:
#                t = self.replace(fold=0)
#            else:
#                t = self
#            tzoff = t.utcoffset()
#            if tzoff is None:
#                self._hashcode = hash(t._getstate()[0])
#            else:
#                days = _ymd2ord(self.year, self.month, self.day)
#                seconds = self.hour * 3600 + self.minute * 60 + self.second
#                self._hashcode = hash(timedelta(days, seconds, self.microsecond) - tzoff)
#        return self._hashcode
#
#    # Pickle support.
#
#    def _getstate(self, protocol=3):
#        yhi, ylo = divmod(self._year, 256)
#        us2, us3 = divmod(self._microsecond, 256)
#        us1, us2 = divmod(us2, 256)
#        m = self._month
#        if self._fold and protocol > 3:
#            m += 128
#        basestate = bytes([yhi, ylo, m, self._day,
#                           self._hour, self._minute, self._second,
#                           us1, us2, us3])
#        if self._tzinfo is None:
#            return (basestate,)
#        else:
#            return (basestate, self._tzinfo)
#
#    def __setstate(self, string, tzinfo):
#        if tzinfo is not None and not isinstance(tzinfo, _tzinfo_class):
#            raise TypeError("bad tzinfo state arg")
#        (yhi, ylo, m, self._day, self._hour,
#         self._minute, self._second, us1, us2, us3) = string
#        if m > 127:
#            self._fold = 1
#            self._month = m - 128
#        else:
#            self._fold = 0
#            self._month = m
#        self._year = yhi * 256 + ylo
#        self._microsecond = (((us1 << 8) | us2) << 8) | us3
#        self._tzinfo = tzinfo
#
#    def __reduce_ex__(self, protocol):
#        return (self.__class__, self._getstate(protocol))
#
#    def __reduce__(self):
#        return self.__reduce_ex__(2)
#
#
# datetime.min = datetime(1, 1, 1)
# datetime.max = datetime(9999, 12, 31, 23, 59, 59, 999999)
# datetime.resolution = timedelta(microseconds=1)
#
#
# def _isoweek1monday(year):
#    # Helper to calculate the day number of the Monday starting week 1
#    # XXX This could be done more efficiently
#    THURSDAY = 3
#    firstday = _ymd2ord(year, 1, 1)
#    firstweekday = (firstday + 6) % 7  # See weekday() above
#    week1monday = firstday - firstweekday
#    if firstweekday > THURSDAY:
#        week1monday += 7
#    return week1monday
#
#
@value
struct timezone:
    var _offset: timedelta
    var _name: Optional[String]

    alias _maxoffset = timedelta(hours=24, microseconds=-1)
    alias _minoffset = -timezone._maxoffset
    alias utc = timezone(timedelta(0), None)

    # bpo-37642: These attributes are rounded to the nearest minute for backwards
    # compatibility, even though the constructor will accept a wider range of
    # values. This may change in the future.
    alias min = timezone(-timedelta(hours=23, minutes=59))
    alias max = timezone(timedelta(hours=23, minutes=59))

    fn __init__(inout self, offset: timedelta, name: Optional[String] = None):
        # if not cls._minoffset <= offset <= cls._maxoffset:
        #     raise ValueError("offset must be a timedelta "
        #                      "strictly between -timedelta(hours=24) and "
        #                      "timedelta(hours=24).")
        self._offset = offset
        self._name = name

    #    def __getinitargs__(self):
    #        """pickle support"""
    #        if self._name is None:
    #            return (self._offset,)
    #        return (self._offset, self._name)

    fn __eq__(self, other: timezone) -> Bool:
        return self._offset == other._offset

    # TODO: remove inout and make it Hashable
    fn __hash__(inout self) -> Int:
        return self._offset.__hash__()

    fn __repr__(self) -> String:
        """Convert to formal string, for repr().

        >>> tz = timezone.utc
        >>> repr(tz)
        'datetime.timezone.utc'
        >>> tz = timezone(timedelta(hours=-5), 'EST')
        >>> repr(tz)
        "datetime.timezone(datetime.timedelta(-1, 68400), 'EST')"
        """
        if self == timezone.utc:
            return "datetime.timezone.utc"

        var result: String = "datetime.timezone(" + self._offset.__repr__()
        if self._name is not None:
            result += ", " + self._name.value()
        return result + ")"

    fn __str__(self) -> String:
        return self.tzname(None)

    fn utcoffset(self, dt: Optional[datetime]) -> timedelta:
        return self._offset

    fn tzname(self, dt: Optional[datetime]) -> String:
        if self._name is None:
            return self._name_from_offset(self._offset)
        else:
            return self._name.value()

    fn dst(self, dt: Optional[datetime]) -> None:
        return None

    # fn fromutc(self, dt: datetime) -> datetime:
    #    #if dt.tzinfo is not self:
    #    #    raise ValueError("fromutc: dt.tzinfo "
    #    #                     "is not self")
    #    return dt + self._offset

    @staticmethod
    fn _name_from_offset(owned delta: timedelta) -> String:
        if not delta:
            return "UTC"
        var sign: String
        if delta < timedelta(0):
            sign = "-"
            delta = -delta
        else:
            sign = "+"
        # can use divmod later when we support non-register-passable for Tuple
        var hours = delta // timedelta(hours=1)
        var rest = delta % timedelta(hours=1)
        var minutes = rest // timedelta(minutes=1)
        rest = rest % timedelta(minutes=1)
        var seconds = rest.seconds
        var microseconds = rest.microseconds
        try:
            var result = "UTC" + sign + rjust(str(hours), 2, "0") + ":" + rjust(
                str(minutes), 2, "0"
            )
            if seconds or microseconds:
                result += ":" + rjust(str(seconds), 2, "0")
            if microseconds:
                result += "." + rjust(str(microseconds), 6, "0")
            return result
        except Error:
            # should never happen
            return "unknown error in _name_from_offset"


alias UTC = timezone.utc
# _EPOCH = datetime(1970, 1, 1, tzinfo=timezone.utc)
