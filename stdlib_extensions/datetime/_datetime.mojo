from .. import datetime as dt
from ._utils import ymd2ord, MAXORDINAL, _check_date_fields, _check_time_fields
from ..builtins import divmod
from ..builtins._types import Optional
from .._utils import custom_debug_assert
from ._utils import (
    _check_utc_offset,
    _check_time_fields,
    _build_struct_time,
)
from ..time import struct_time
from ..builtins.string import join
from utils.variant import Variant
from python import Python
from ..syscalls.clocks import clock_gettime
from ..builtins import custom_hash


# TODO: time methods must be transferred to datetime

alias _EPOCH = datetime(1970, 1, 1, tzinfo=dt.timezone(dt.timedelta(0)))


@value
struct datetime(CollectionElement, Stringable, Hashable):
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
    var tzinfo: Optional[dt.timezone]
    var fold: Int

    # this is to avoid conflicting with the @value constructor
    # TODO: remove when https://github.com/modularml/mojo/issues/1705 is fixed
    var _dummy: Int

    alias min = datetime(1, 1, 1)
    alias max = datetime(9999, 12, 31, 23, 59, 59, 999999)
    alias resolution = dt.timedelta(microseconds=1)

    fn __init__(
        inout self,
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        microsecond: Int = 0,
        tzinfo: Optional[dt.timezone] = None,
        fold: Int = 0,
    ):
        # _check_date_fields(year, month, day)
        _check_time_fields(hour, minute, second, microsecond, fold)
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
    #    def fromtimestamp(cls, timestamp, tz=None):
    #        """Construct a datetime from a POSIX timestamp (like time.time()).
    #
    #        A dt.timezone info object may be passed in as well.
    #        """
    #        return cls._fromtimestamp(timestamp, tz is not None, tz)
    #        var t = timestamp
    #        var utc = tz is not None
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
    #            trans = result - probe1 - dt.timedelta(0, max_fold_seconds)
    #            if trans.days < 0:
    #                y, m, d, hh, mm, ss = converter(t + trans // dt.timedelta(0, 1))[:6]
    #                probe2 = cls(y, m, d, hh, mm, ss, us, tz)
    #                if probe2 == result:
    #                    result._fold = 1
    #        elif tz is not None:
    #            result = tz.fromutc(result)
    #        return result

    @staticmethod
    fn now() -> datetime:
        var ctime_spec = clock_gettime()
        return datetime(1970, 1, 1) + dt.timedelta(
            seconds=ctime_spec.tv_sec.to_int(),
            microseconds=(ctime_spec.tv_nsec // 1_000).to_int(),
        )

    fn to_python(self) raises -> PythonObject:
        var python_datetime_module = Python.import_module("datetime")
        # dt.timezone not suppoted yet
        custom_debug_assert(
            self.tzinfo is None,
            "converting to python is not yet support if tzinfo is not None",
        )
        custom_debug_assert(
            self.fold == 0, "converting to python is not yet support if fold is not 0"
        )
        return python_datetime_module.datetime(
            self.year,
            self.month,
            self.day,
            self.hour,
            self.minute,
            self.second,
            self.microsecond,
        )

    @staticmethod
    fn combine(date: date, time: time) -> datetime:
        "Construct a datetime from a given date and a given time."
        return datetime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
            time.second,
            time.microsecond,
            time.tzinfo,
            fold=time.fold,
        )

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
    fn timetuple(self) -> struct_time:
        "Return local time tuple compatible with time.localtime()."
        var dst = self.dst()
        var dst_as_int: Int
        if dst is None:
            dst_as_int = -1
        elif dst.value() != dt.timedelta(0):
            dst_as_int = 1
        else:
            dst_as_int = 0
        return _build_struct_time(
            self.year,
            self.month,
            self.day,
            self.hour,
            self.minute,
            self.second,
            dst_as_int,
        )

    #
    #    def _mktime(self):
    #        """Return integer POSIX timestamp."""
    #        epoch = datetime(1970, 1, 1)
    #        max_fold_seconds = 24 * 3600
    #        t = (self - epoch) // dt.timedelta(0, 1)
    #        def local(u):
    #            y, m, d, hh, mm, ss = _time.localtime(u)[:6]
    #            return (datetime(y, m, d, hh, mm, ss) - epoch) // dt.timedelta(0, 1)
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
    fn date(self) -> date:
        "Return the date part."
        return date(self.year, self.month, self.day)

    fn time(self) -> time:
        "Return the time part, with tzinfo None."
        return time(
            self.hour, self.minute, self.second, self.microsecond, fold=self.fold
        )

    fn timetz(self) -> time:
        "Return the time part, with same tzinfo."
        return time(
            self.hour,
            self.minute,
            self.second,
            self.microsecond,
            self.tzinfo,
            fold=self.fold,
        )

    fn replace(
        self,
        owned year: Optional[Int] = None,
        owned month: Optional[Int] = None,
        owned day: Optional[Int] = None,
        owned hour: Optional[Int] = None,
        owned minute: Optional[Int] = None,
        owned second: Optional[Int] = None,
        owned microsecond: Optional[Int] = None,
        owned tzinfo: TzinfoReplacement = True,
        owned fold: Optional[Int] = None,
    ) -> datetime:
        """Return a new datetime with new values for the specified fields."""
        if year is None:
            year = self.year
        if month is None:
            month = self.month
        if day is None:
            day = self.day
        if hour is None:
            hour = self.hour
        if minute is None:
            minute = self.minute
        if second is None:
            second = self.second
        if microsecond is None:
            microsecond = self.microsecond
        var _tzinfo: Optional[dt.timezone]
        if tzinfo.is_bool():
            _tzinfo = self.tzinfo
        else:
            _tzinfo = tzinfo.get_tzinfo()
        if fold is None:
            fold = self.fold
        return datetime(
            year.value(),
            month.value(),
            day.value(),
            hour.value(),
            minute.value(),
            second.value(),
            microsecond.value(),
            _tzinfo,
            fold.value(),
        )

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
    #            ts = (self - _EPOCH) // dt.timedelta(seconds=1)
    #        localtm = _time.localtime(ts)
    #        local = datetime(*localtm[:6])
    #        # Extract TZ data
    #        gmtoff = localtm.tm_gmtoff
    #        zone = localtm.tm_zone
    #        return dt.timezone(dt.timedelta(seconds=gmtoff), zone)
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

    fn isoformat(self, sep: String = "T", timespec: String = "auto") -> String:
        """Return the time formatted according to ISO.

        The full format looks like 'YYYY-MM-DD HH:MM:SS.mmmmmm'.
        By default, the fractional part is omitted if self.microsecond == 0.

        If self.tzinfo is not None, the UTC offset is also attached, giving
        giving a full format of 'YYYY-MM-DD HH:MM:SS.mmmmmm+HH:MM'.

        Optional argument sep specifies the separator between date and
        time, default 'T'.

        The optional argument timespec specifies the number of additional
        terms of the time to include. Valid options are 'auto', 'hours',
        'minutes', 'seconds', 'milliseconds' and 'microseconds'.
        """
        return self.date().isoformat() + sep + self.timetz().isoformat(timespec)

    fn __repr__(self) -> String:
        """Convert to formal string, for repr()."""
        var result: String = "datetime.datetime("
        var components = List[String](
            str(self.year),
            str(self.month),
            str(self.day),
            str(self.hour),
            str(self.minute),
            str(self.second),
            str(self.microsecond),
        )
        for _ in range(2):
            if components[-1] == "0":
                components.pop_back()
        result += join(", ", components)
        if self.tzinfo is not None:
            result += ", tzinfo=" + self.tzinfo.value().__repr__()

        if self.fold:
            result += ", fold=1"
        result += ")"
        return result

    fn __str__(self) -> String:
        "Convert to string, for str()."
        return self.isoformat(sep=" ")

    #    @classmethod
    #    def strptime(cls, date_string, format):
    #        'string, format -> new datetime parsed from a string (like time.strptime()).'
    #        import _strptime
    #        return _strptime._strptime_datetime(cls, date_string, format)

    fn utcoffset(self) -> Optional[dt.timedelta]:
        """Return the timezone offset as dt.timedelta positive east of UTC (negative west of
        UTC)."""
        if self.tzinfo is None:
            return None
        var offset = self.tzinfo.value().utcoffset(self)
        _check_utc_offset("utcoffset", offset)
        return offset

    fn tzname(self) -> Optional[String]:
        """Return the timezone name.

        Note that the name is 100% informational -- there's no requirement that
        it mean anything in particular. For example, "GMT", "UTC", "-500",
        "-5:00", "EDT", "US/Eastern", "America/New York" are all valid replies.
        """
        if self.tzinfo is None:
            return None
        return self.tzinfo.value().tzname(self)

    fn dst(self) -> Optional[dt.timedelta]:
        """Return 0 if DST is not in effect, or the DST offset (as dt.timedelta
        positive eastward) if DST is in effect.

        This is purely informational; the DST offset has already been added to
        the UTC offset returned by utcoffset() if applicable, so there's no
        need to consult dst() unless you're interested in displaying the DST
        info.
        """
        if self.tzinfo is None:
            return None
        var offset = self.tzinfo.value().dst(self)
        _check_utc_offset("dst", offset)
        return offset

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
    fn __add__(self, other: dt.timedelta) -> datetime:
        "Add a datetime and a dt.timedelta."
        var delta = dt.timedelta(
            self.toordinal(),
            hours=self.hour,
            minutes=self.minute,
            seconds=self.second,
            microseconds=self.microsecond,
        )
        delta = delta + other
        var hour: Int
        var rem: Int
        var minute: Int
        var second: Int
        hour, rem = divmod(delta.seconds, 3600)
        minute, second = divmod(rem, 60)
        custom_debug_assert(0 < delta.days <= MAXORDINAL, "result out of range")
        return datetime.combine(
            date.fromordinal(delta.days),
            time(hour, minute, second, delta.microseconds, tzinfo=self.tzinfo),
        )

    fn toordinal(self) -> Int:
        """Return proleptic Gregorian ordinal for the year, month and day.

        January 1 of year 1 is day 1.  Only the year, month and day values
        contribute to the result.
        """
        return ymd2ord(self.year, self.month, self.day)

    #   mojo doesn't support __radd__ yet
    #    __radd__ = __add__

    fn __sub__(self, other: dt.timedelta) -> datetime:
        return self + (-other)

    fn __sub__(self, other: datetime) -> dt.timedelta:
        var days1 = self.toordinal()
        var days2 = other.toordinal()
        var secs1 = self.second + self.minute * 60 + self.hour * 3600
        var secs2 = other.second + other.minute * 60 + other.hour * 3600
        var base = dt.timedelta(
            days1 - days2, secs1 - secs2, self.microsecond - other.microsecond
        )
        if self.tzinfo is None and other.tzinfo is None:
            return base
        var myoff = self.utcoffset()
        var otoff = other.utcoffset()
        if optional_equal_timedelta(myoff, otoff):
            return base
        if myoff is None or otoff is None:
            custom_debug_assert("cannot mix naive and timezone-aware time")
        return base + otoff.value() - myoff.value()

    fn __hash__(self) -> Int:
        var t: datetime
        if self.fold:
            t = self.replace(fold=0)
        else:
            t = self
        var tzoff = t.utcoffset()
        if tzoff is None:
            return custom_hash(
                List[Int](
                    t.year, t.month, t.day, t.hour, t.minute, t.second, t.microsecond
                )
            )
        else:
            var days = ymd2ord(self.year, self.month, self.day)
            var seconds = self.hour * 3600 + self.minute * 60 + self.second
            return hash(dt.timedelta(days, seconds, self.microsecond) - tzoff.value())


@value
struct TzinfoReplacement:
    var _value: Variant[Optional[dt.timezone], Bool]

    fn __init__(inout self, value: Bool):
        self._value = value

    fn __init__(inout self, value: None):
        self._value = Optional[dt.timezone](value)

    fn __init__(inout self, value: dt.timezone):
        self._value = Optional[dt.timezone](value)

    fn get_tzinfo(self) -> Optional[dt.timezone]:
        return self._value.get[Optional[dt.timezone]]()[]

    fn is_bool(self) -> Bool:
        return self._value.isa[Bool]()


fn optional_equal_timedelta(
    a: Optional[dt.timedelta], b: Optional[dt.timedelta]
) -> Bool:
    # remove this when Optional supports __eq__
    if a is None:
        return b is None
    if b is None:
        return False
    return a.value() == b.value()
