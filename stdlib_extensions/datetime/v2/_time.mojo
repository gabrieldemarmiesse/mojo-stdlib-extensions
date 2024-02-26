from ...builtins import Optional, ___eq__
from ._timezone import timezone
from utils.variant import Variant
from ...builtins._generic_list import _cmp_list
from ...builtins._hash import hash as custom_hash
from ...builtins import divmod


@value
struct time(CollectionElement, Hashable, Stringable):
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
    var tzinfo: Optional[timezone]
    var _hashcode: Int
    var fold: Int

    alias min = time(0, 0, 0)
    alias max = time(23, 59, 59, 999999)
    alias resolution = timedelta(microseconds=1)

    fn __init__(
        inout self,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        microsecond: Int = 0,
        tzinfo: Optional[timezone] = None,
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

    # Standard conversions, __hash__ (and helpers)
    # Comparisons of time objects with other.

    fn __eq__(self, other: time) -> Bool:
        return self._cmp(other, allow_mixed=True) == 0

    fn __ne__(self, other: time) -> Bool:
        return self._cmp(other, allow_mixed=True) != 0

    def __le__(self, other: time) -> Bool:
        return self._cmp(other) <= 0

    def __lt__(self, other: time) -> Bool:
        return self._cmp(other) < 0

    def __ge__(self, other: time) -> Bool:
        return self._cmp(other) >= 0

    def __gt__(self, other: time) -> Bool:
        return self._cmp(other) > 0

    fn _cmp(self, other: time, allow_mixed: Bool = False) -> Int:
        var mytz = self.tzinfo
        var ottz = other.tzinfo
        var myoff: Optional[timedelta] = None
        var otoff: Optional[timedelta] = None
        var base_compare: Bool
        if mytz is None and ottz is None:
            base_compare = True
        elif mytz is not None and ottz is not None and mytz.value() == ottz.value():
            base_compare = True
        else:
            myoff = self.utcoffset()
            otoff = other.utcoffset()
            base_compare = ___eq__(myoff, otoff)

        if base_compare:
            return _cmp_list(
                list[Int].from_values(
                    self.hour, self.minute, self.second, self.microsecond
                ),
                list[Int].from_values(
                    other.hour, other.minute, other.second, other.microsecond
                ),
            )
        if myoff is None or otoff is None:
            if allow_mixed:
                return 2  # arbitrary non-zero value
            else:
                custom_debug_assert("cannot compare naive and aware times")

        # is there a bug here? Does that mean that we cannot have a tzinfo with sub-minute resolution?
        # Anyway, this was in the CPython code, so I'm keeping it for now until someone has the answer.
        var myhhmm = self.hour * 60 + self.minute - myoff.value() // timedelta(
            minutes=1
        )
        var othhmm = other.hour * 60 + other.minute - otoff.value() // timedelta(
            minutes=1
        )
        return _cmp_list(
            list[Int].from_values(myhhmm.to_int(), self.second, self.microsecond),
            list[Int].from_values(othhmm.to_int(), other.second, other.microsecond),
        )

    fn __hash__(self) -> Int:
        """Hash."""
        var t: time
        if self.fold:
            t = self.replace(fold=0)
        else:
            t = self
        var tzoff = t.utcoffset()
        if tzoff is None or tzoff.value() == timedelta(0):
            return custom_hash(
                list[Int].from_values(t.hour, t.minute, t.second, t.microsecond)
            )
        else:
            var utctime = timedelta(
                hours=self.hour, minutes=self.minute
            ) - tzoff.value()
            var h = utctime // timedelta(hours=1)
            var m = utctime % timedelta(hours=1)
            # assert not m % timedelta(minutes=1), "whole minute"
            var minutes_int = (m // timedelta(minutes=1)).to_int()
            var h_int = h.to_int()
            return custom_hash(
                list[Int].from_values(h_int, minutes_int, self.second, self.microsecond)
            )

    # Conversion to string

    fn _tzstr(self) -> String:
        """Return formatted timezone offset (+xx:xx) or an empty string."""
        return _format_optional_offset(self.utcoffset())

    fn __repr__(self) -> String:
        """Convert to formal string, for repr()."""
        var result = "datetime.time(" + str(self.hour) + ", " + str(self.minute)
        if self.second != 0 or self.microsecond != 0:
            result += ", " + str(self.second)
        if self.microsecond != 0:
            result += ", " + str(self.microsecond)
        if self.tzinfo is not None:
            result += ", tzinfo=" + self.tzinfo.value().__repr__()
        if self.fold:
            result += ", fold=1"
        return result + ")"

    fn isoformat(self, timespec: String = "auto") -> String:
        """Return the time formatted according to ISO.

        The full format is 'HH:MM:SS.mmmmmm+zz:zz'. By default, the fractional
        part is omitted if self.microsecond == 0.

        The optional argument timespec specifies the number of additional
        terms of the time to include. Valid options are 'auto', 'hours',
        'minutes', 'seconds', 'milliseconds' and 'microseconds'.
        """
        var s = _format_time(
            self.hour, self.minute, self.second, self.microsecond, timespec
        )
        var tz = self._tzstr()
        if tz:
            s += tz
        return s

    fn __str__(self) -> String:
        return self.isoformat()

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

    # Timezone functions
    fn utcoffset(self) -> Optional[timedelta]:
        """Return the timezone offset as timedelta, positive east of UTC
        (negative west of UTC)."""
        if self.tzinfo is None:
            return None
        var offset = self.tzinfo.value().utcoffset(None)
        # _check_utc_offset("utcoffset", offset)
        return offset

    fn tzname(self) -> Optional[String]:
        """Return the timezone name.

        Note that the name is 100% informational -- there's no requirement that
        it mean anything in particular. For example, "GMT", "UTC", "-500",
        "-5:00", "EDT", "US/Eastern", "America/New York" are all valid replies.
        """
        if self.tzinfo is None:
            return None
        return self.tzinfo.value().tzname(None)

    fn dst(self) -> Optional[timedelta]:
        """Return 0 if DST is not in effect, or the DST offset (as timedelta
        positive eastward) if DST is in effect.

        This is purely informational; the DST offset has already been added to
        the UTC offset returned by utcoffset() if applicable, so there's no
        need to consult dst() unless you're interested in displaying the DST
        info.
        """
        if self.tzinfo is None:
            return None
        var offset = self.tzinfo.value().dst(None)
        # _check_utc_offset("dst", offset)
        return offset

    fn replace(
        self,
        owned hour: Optional[Int] = None,
        owned minute: Optional[Int] = None,
        owned second: Optional[Int] = None,
        owned microsecond: Optional[Int] = None,
        owned tzinfo: Variant[Optional[timezone], Bool] = Variant[
            Optional[timezone], Bool
        ](True),
        owned fold: Optional[Int] = None,
    ) -> time:
        """Return a new time with new values for the specified fields."""
        if hour is None:
            hour = self.hour
        if minute is None:
            minute = self.minute
        if second is None:
            second = self.second
        if microsecond is None:
            microsecond = self.microsecond
        if tzinfo.isa[Bool]() and tzinfo.get[Bool]() == True:
            tzinfo = self.tzinfo
        if fold is None:
            fold = self.fold
        return time(
            hour=hour.value(),
            minute=minute.value(),
            second=second.value(),
            microsecond=microsecond.value(),
            tzinfo=tzinfo.get[Optional[timezone]](),
            fold=fold.value(),
        )


fn _format_optional_offset(off: Optional[timedelta], sep: String = ":") -> String:
    if off is None:
        return ""
    else:
        return _format_offset(off.value(), sep)


fn _format_offset(owned off: timedelta, sep: String = ":") -> String:
    var s: String = ""
    var sign: String
    if off.days < 0:
        sign = "-"
        off = -off
    else:
        sign = "+"
    var hh = off // timedelta(hours=1)
    var mm = off % timedelta(hours=1)
    var mm_int = (mm // timedelta(minutes=1)).to_int()
    var ss = mm % timedelta(minutes=1)
    s += sign + rjust(str(hh), 2, "0") + sep + rjust(str(mm_int), 2, "0")
    if ss or ss.microseconds:
        s += sep + rjust(str(ss.seconds), 2, "0")
        if ss.microseconds:
            s += "." + rjust(str(ss.microseconds), 6, "0")
    return s


fn _format_time(
    hh: Int, mm: Int, ss: Int, owned us: Int, owned timespec: String = "auto"
) -> String:
    if timespec == "auto":
        # Skip trailing microseconds when us==0.
        timespec = "microseconds" if us else "seconds"

    if timespec == "hours":
        return format_hours(hh)
    elif timespec == "minutes":
        return format_minutes(hh, mm)
    elif timespec == "seconds":
        return format_seconds(hh, mm, ss)
    elif timespec == "milliseconds":
        return format_milliseconds(hh, mm, ss, us // 1000)
    elif timespec == "microseconds":
        return format_microseconds(hh, mm, ss, us)
    else:
        custom_debug_assert("Unknown timespec value")
        return "Wrong timespec value in _format_time()"


fn format_hours(hours: Int) -> String:
    return rjust(str(hours), 2, "0")


fn format_minutes(hours: Int, minutes: Int) -> String:
    return format_hours(hours) + ":" + rjust(str(minutes), 2, "0")


fn format_seconds(hours: Int, minutes: Int, seconds: Int) -> String:
    return format_minutes(hours, minutes) + ":" + rjust(str(seconds), 2, "0")


fn format_milliseconds(
    hours: Int, minutes: Int, seconds: Int, milliseconds: Int
) -> String:
    return (
        format_seconds(hours, minutes, seconds) + "." + rjust(str(milliseconds), 3, "0")
    )


fn format_microseconds(
    hours: Int, minutes: Int, seconds: Int, microseconds: Int
) -> String:
    return (
        format_seconds(hours, minutes, seconds) + "." + rjust(str(microseconds), 6, "0")
    )
