from ._timezone import timezone
from ._utils import ymd2ord, MAXORDINAL, _check_date_fields, _check_time_fields
from ...builtins import divmod
from ...builtins._types import Optional
from ..._utils import custom_debug_assert

# TODO: time methods must be transferred to datetime


@value
struct datetime(CollectionElement):
    #    """datetime(year, month, day[, hour[, minute[, second[, microsecond[,tzinfo]]]]])
    #
    #    The year, month and day arguments are required. tzinfo may be None, or an
    #    instance of a tzinfo subclass. The remaining arguments may be ints.
    #    """
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int
    var microsecond: Int
    # TODO: use the trait tzinfo instead.
    # traits are too strict right now to do what we want here.
    var tzinfo: Optional[timezone]
    var fold: Int

    # this is to avoid conflicting with the @value constructor
    # TODO: remove when https://github.com/modularml/mojo/issues/1705 is fixed
    var _dummy: Int

    alias min = datetime(1, 1, 1)
    alias max = datetime(9999, 12, 31, 23, 59, 59, 999999)
    alias resolution = timedelta(microseconds=1)

    fn __init__(
        inout self,
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        microsecond: Int = 0,
        tzinfo: Optional[timezone] = None,
        fold: Int = 0,
    ):
        # _check_date_fields(year, month, day)
        # _check_time_fields(hour, minute, second, microsecond, fold)
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.microsecond = microsecond
        self.tzinfo = tzinfo
        self.fold = fold
        # TODO: remove when https://github.com/modularml/mojo/issues/1705 is fixed
        self._dummy = 0

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
