from ._timedelta import timedelta
from ...builtins import Optional, bytes
from ...builtins import divmod


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
