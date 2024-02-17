from ._timedelta import timedelta
from ...builtins import Optional, bytes
from ...builtins import divmod
from ._utils import (
    ord2ymd,
    isoweek1monday,
    ymd2ord,
    _isoweek_to_gregorian,
    _build_struct_time,
    get_days_names,
    get_days_short_names,
    get_months_names,
    get_months_short_names,
)
from ._iso_calendar_date import IsoCalendarDate

from ...builtins._generic_list import _cmp_list
from ...builtins._hash import hash as custom_hash
from ...time import time, time_ns, struct_time


alias _EPOCH = date(1970, 1, 1)


@value
struct date(Hashable, Stringable):
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

    # Additional constructors
    @staticmethod
    def fromtimestamp(t: Int) -> date:
        "Construct a date from a POSIX timestamp (like time.time())."
        return _EPOCH + timedelta(seconds=t)

    @staticmethod
    def fromtimestamp(t: Float64) -> date:
        "Construct a date from a POSIX timestamp (like time.time())."
        return _EPOCH + timedelta(seconds=int(t))

    @staticmethod
    fn today() -> date:
        "Construct a date from time.time()."
        var t = time_ns()
        return _EPOCH + timedelta(microseconds=(t / 1_000).to_int())

    @staticmethod
    fn fromordinal(n: Int) -> date:
        """Construct a date from a proleptic Gregorian ordinal.

        January 1 of year 1 is day 1.  Only the year, month and day are
        non-zero in the result.
        """
        var y: Int
        var m: Int
        var d: Int
        y, m, d = ord2ymd(n)
        return date(y, m, d)

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
    #            return cls(*_parse_isoformat_date(date_strnig))
    #        except Exception:
    #            raise ValueError(f'Invalid isoformat string: {date_string!r}')
    #
    @staticmethod
    fn fromisocalendar(year: Int, week: Int, day: Int) -> date:
        """Construct a date from the ISO year, week number and weekday.

        This is the inverse of the date.isocalendar() function"""
        var gregorian_year: Int
        var gregorian_month: Int
        var gregorian_day: Int
        gregorian_year, gregorian_month, gregorian_day = _isoweek_to_gregorian(
            year, week, day
        )
        return date(gregorian_year, gregorian_month, gregorian_day)

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
    fn strftime(self, format: String) -> String:
        """
        Format using strftime().

        Example: "%d/%m/%Y, %H:%M:%S"
        """
        var result: String = ""
        var previous_was_percent = False
        for i in range(len(format)):
            var letter = format[i]
            if previous_was_percent:
                result += self._get_from_letter(letter)
                previous_was_percent = False
            elif letter == "%":
                previous_was_percent = True
            else:
                result += letter
        return result

    fn _get_from_letter(self, letter: String) -> String:
        """See https://docs.python.org/3/library/datetime.html#strftime-and-strptime-format-codes
        """
        if letter == "%":
            return "%"
        elif letter == "a":
            return get_days_short_names()[self.isoweekday()]
        elif letter == "A":
            return get_days_names()[self.isoweekday()]
        elif letter == "w":
            return str(self.weekday())
        elif letter == "d":
            return rjust(str(self.day), 2, "0")
        elif letter == "b":
            return get_months_short_names()[self.month]
        elif letter == "B":
            return get_months_names()[self.month]
        elif letter == "m":
            return rjust(str(self.month), 2, "0")
        elif letter == "y":
            return rjust(str(self.year)[-2:], 2, "0")
        elif letter == "Y":
            return rjust(str(self.year), 4, "0")
        elif letter == "H":
            return "00"
        elif letter == "I":
            return "12"
        elif letter == "p":
            return "AM"
        elif letter == "M":
            return "00"
        elif letter == "S":
            return "00"
        elif letter == "f":
            return "000000"
        elif letter == "z":
            return ""
        elif letter == "Z":
            return ""
        elif letter == "j":
            return (self - date(self.year, 1, 1)).days + 1
        elif letter == "U":
            custom_debug_assert(False, "Not implemented yet for %U")
            return ""
        elif letter == "W":
            custom_debug_assert(False, "Not implemented yet for %W")
            return ""
        elif letter == "c":
            return self.strftime("%a %b %d %H:%M:%S %Y")
        elif letter == "x":
            return self.strftime("%m/%d/%y")
        elif letter == "X":
            return self.strftime("%H:%M:%S")
        else:
            custom_debug_assert(
                False, "strptime format string contains unknown format letter"
            )
            return ""

    def __format__(self, fmt: String) -> String:
        if len(fmt) != 0:
            return self.strftime(fmt)
        return str(self)

    fn isoformat(self) -> String:
        """Return the date formatted according to ISO.

        This is 'YYYY-MM-DD'.

        References:
        - http://www.w3.org/TR/NOTE-datetime
        - http://www.cl.cam.ac.uk/~mgk25/iso-time.html
        """
        return (
            rjust(str(self.year), 4, "0")
            + "-"
            + rjust(str(self.month), 2, "0")
            + "-"
            + rjust(str(self.day), 2, "0")
        )

    fn __str__(self) -> String:
        """Convert to string, for str().

        >>> d = date(2010, 1, 1)
        >>> str(d)
        '2010-01-01'
        """
        return self.isoformat()

    # Standard conversions, __eq__, __le__, __lt__, __ge__, __gt__,
    # __hash__ (and helpers)

    def timetuple(self) -> struct_time:
        "Return local time tuple compatible with time.localtime()."
        return _build_struct_time(self.year, self.month, self.day, 0, 0, 0, -1)

    fn toordinal(self) -> Int:
        """Return proleptic Gregorian ordinal for the year, month and day.

        January 1 of year 1 is day 1.  Only the year, month and day values
        contribute to the result.
        """
        return ymd2ord(self.year, self.month, self.day)

    fn replace(
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

    # Comparisons of date objects with other.
    fn __eq__(self, other: date) -> Bool:
        return self._cmp(other) == 0

    def __le__(self, other: date) -> Bool:
        return self._cmp(other) <= 0

    def __lt__(self, other: date) -> Bool:
        return self._cmp(other) < 0

    fn __ge__(self, other: date) -> Bool:
        return self._cmp(other) >= 0

    fn __gt__(self, other: date) -> Bool:
        return self._cmp(other) > 0

    fn _cmp(self, other: date) -> Int:
        var list_1 = list[Int].from_values(self.year, self.month, self.day)
        var list_2 = list[Int].from_values(other.year, other.month, other.day)
        return _cmp_list(list_1, list_2)

    fn __hash__(self) -> Int:
        return custom_hash(str(self.year) + str(self.month) + str(self.day))

    # Computations
    fn __add__(self, other: timedelta) -> date:
        "Add a date to a timedelta."
        var o = self.toordinal() + other.days
        # if not (0 < o <= _MAXORDINAL):
        #    raise OverflowError("result out of range")
        return date.fromordinal(o)

    fn __sub__(self, other: timedelta) -> date:
        """Subtract two dates, or a date and a timedelta."""
        return self + timedelta(-other.days)

    fn __sub__(self, other: date) -> timedelta:
        var days1 = self.toordinal()
        var days2 = other.toordinal()
        return timedelta(days1 - days2)

    fn weekday(self) -> Int:
        "Return day of the week, where Monday == 0 ... Sunday == 6."
        return (self.toordinal() + 6) % 7

    # Day-of-the-week and week-of-the-year, according to ISO

    fn isoweekday(self) -> Int:
        "Return day of the week, where Monday == 1 ... Sunday == 7."
        # 1-Jan-0001 is a Monday
        return self.toordinal() % 7 or 7

    fn isocalendar(self) -> IsoCalendarDate:
        """Return a named tuple containing ISO year, week number, and weekday.

        The first ISO week of the year is the (Mon-Sun) week
        containing the year's first Thursday; everything else derives
        from that.

        The first week is 1; Monday is 1 ... Sunday is 7.

        ISO calendar algorithm taken from
        http://www.phys.uu.nl/~vgent/calendar/isocalendar.htm
        (used with permission)
        """
        var year = self.year
        var week1monday = isoweek1monday(year)
        var today = ymd2ord(self.year, self.month, self.day)
        # Internally, week and day have origin 0
        var week = (today - week1monday) // 7
        var day = (today - week1monday) % 7
        if week < 0:
            year -= 1
            week1monday = isoweek1monday(year)
            week, day = divmod(today - week1monday, 7)
        elif week >= 52:
            if today >= isoweek1monday(year + 1):
                year += 1
                week = 0
        return IsoCalendarDate(year, week + 1, day + 1)

    fn _getstate(self) -> bytes:
        var yhi: Int
        var ylo: Int
        yhi, ylo = divmod(self.year, 256)
        return bytes.from_values(yhi, ylo, self.month, self.day)
