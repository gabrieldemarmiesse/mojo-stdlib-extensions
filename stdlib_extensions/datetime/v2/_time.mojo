from ._tzinfo import tzinfo
from ...builtins import Optional


struct time[T: tzinfo]:
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
