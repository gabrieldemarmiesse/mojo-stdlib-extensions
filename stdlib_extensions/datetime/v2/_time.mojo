from ...builtins import Optional, ___eq__
from ._timezone import timezone
from utils.variant import Variant
from ...builtins._generic_list import _cmp_list
from ...builtins._hash import hash as custom_hash
from ...builtins import divmod, bool_to_int
from ...builtins.string import rjust, removeprefix


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

    fn _tzstr(self, sep: String = ":") -> String:
        """Return formatted timezone offset (+xx:xx) or an empty string."""
        return _format_optional_offset(self.utcoffset(), sep=sep)

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

    @staticmethod
    fn fromisoformat(owned time_string: String) raises -> time:
        """Construct a time from a string in one of the ISO 8601 formats."""

        # The spec actually requires that time-only ISO 8601 strings start with
        # T, but the extended format allows this to be omitted as long as there
        # is no ambiguity with date strings.
        time_string = removeprefix(time_string, "T")
        var r = _parse_isoformat_time(time_string)
        return time(r.hour, r.minute, r.second, r.microsecond, r.tzinfo)

    fn strftime(self, owned format: String) -> String:
        """
        Format using strftime().

        Example: "%d/%m/%Y, %H:%M:%S"
        """
        # this letter F is unused
        # if there are performance issues, there might be a way to avoid the replace()
        # but this solution is much easier to understand and read.
        format = format.replace("%:z", "%F")
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
            return "Mon"
        elif letter == "A":
            return "Monday"
        elif letter == "w":
            return "1"
        elif letter == "d":
            return "01"
        elif letter == "b":
            return "Jan"
        elif letter == "B":
            return "January"
        elif letter == "m":
            return "01"
        elif letter == "y":
            return "00"
        elif letter == "Y":
            return "1900"
        elif letter == "H":
            return rjust(str(self.hour), 2, "0")
        elif letter == "I":
            var modulo = self.hour % 12
            if modulo == 0:
                return "12"
            else:
                return rjust(str(modulo), 2, "0")
        elif letter == "p":
            if self.hour < 12:
                return "AM"
            else:
                return "PM"
        elif letter == "M":
            return rjust(str(self.minute), 2, "0")
        elif letter == "S":
            return rjust(str(self.second), 2, "0")
        elif letter == "f":
            return rjust(str(self.microsecond), 6, "0")
        elif letter == "z":
            return self._tzstr(sep="")
        elif letter == "Z":
            if self.tzinfo is None:
                return ""
            return self.tzinfo.value().tzname(None)
        elif letter == "j":
            return "001"
        elif letter == "U":
            return "00"
        elif letter == "W":
            return "01"
        elif letter == "c":
            return self.strftime("Mon Jan  1 %H:%M:%S 1900")
        elif letter == "x":
            return "01/01/00"
        elif letter == "X":
            return self.strftime("%H:%M:%S")
        elif letter == "G":
            return "1900"
        elif letter == "u":
            return "1"
        elif letter == "V":
            return "01"
        elif letter == "F":
            return self._tzstr(sep=":")
        else:
            custom_debug_assert(
                False, "strftime format string contains unknown format letter"
            )
            return ""

    def __format__(self, fmt: String) -> String:
        if len(fmt) != 0:
            return self.strftime(fmt)
        return str(self)

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


fn _format_optional_offset(off: Optional[timedelta], sep: String) -> String:
    if off is None:
        return ""
    else:
        return _format_offset(off.value(), sep)


fn _format_offset(owned off: timedelta, sep: String) -> String:
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


# TODO: use Tuple when https://github.com/modularml/mojo/issues/1817 is fixed
@value
struct IsoformatTimeResult:
    var hour: Int
    var minute: Int
    var second: Int
    var microsecond: Int
    var tzinfo: Optional[timezone]


fn _parse_isoformat_time(
    tstr: String,
) raises -> IsoformatTimeResult:
    # Format supported is HH[:MM[:SS[.fff[fff]]]][+HH:MM[:SS[.ffffff]]]
    var len_str = len(tstr)
    if len_str < 2:
        raise Error("Isoformat time too short")
    # This is equivalent to re.search('[+-Z]', tstr), but faster
    var tz_pos = (tstr.find("-") + 1 or tstr.find("+") + 1 or tstr.find("Z") + 1)
    var timestr = tstr[: tz_pos - 1] if tz_pos > 0 else tstr
    var time_components = _parse_hh_mm_ss_ff(timestr)
    var tzi: Optional[timezone] = None
    if tz_pos == len_str and tstr[-1] == "Z":
        tzi = timezone.utc
    elif tz_pos > 0:
        var tzstr = tstr[tz_pos:]
        # Valid time zone strings are:
        # HH                  len: 2
        # HHMM                len: 4
        # HH:MM               len: 5
        # HHMMSS              len: 6
        # HHMMSS.f+           len: 7+
        # HH:MM:SS            len: 8
        # HH:MM:SS.f+         len: 10+
        if len(tzstr) == 0 or len(tzstr) == 1 or len(tzstr) == 3:
            raise Error("Malformed time zone string")
        var tz_comps = _parse_hh_mm_ss_ff(tzstr)
        if is_all_zeros(tz_comps):
            tzi = timezone(timedelta(0))
        else:
            var tzsign = -1 if tstr[tz_pos - 1] == "-" else 1
            var td = timedelta(
                hours=tz_comps[0],
                minutes=tz_comps[1],
                seconds=tz_comps[2],
                microseconds=tz_comps[3],
            )
            tzi = timezone(td * tzsign)
    return IsoformatTimeResult(
        time_components[0],
        time_components[1],
        time_components[2],
        time_components[3],
        tzi,
    )


fn _parse_hh_mm_ss_ff(tstr: String) raises -> list[Int]:
    # Parses things of the form HH[:?MM[:?SS[{.,}fff[fff]]]]
    var time_comps = list[Int].from_values(0, 0, 0, 0)
    var pos = 0
    var has_sep = False
    var next_char: String
    for comp in range(0, 3):
        if (len(tstr) - pos) < 2:
            raise Error("Incomplete time component")

        time_comps[comp] = atol(tstr[pos : pos + 2])

        pos += 2
        next_char = tstr[pos]

        if comp == 0:
            has_sep = next_char == ":"

        if not next_char or comp >= 2:
            break

        if has_sep and next_char != ":":
            raise Error("Invalid time separator: " + next_char)

        pos += bool_to_int(has_sep)

    if pos < len(tstr):
        if tstr[pos] == "." or tstr[pos] == ",":
            raise Error("Invalid microsecond component")
        else:
            pos += 1

            var len_remainder = len(tstr) - pos
            var to_parse: Int
            if len_remainder >= 6:
                to_parse = 6
            else:
                to_parse = len_remainder

            time_comps[3] = atol(tstr[pos : (pos + to_parse)])
            if to_parse < 6:
                time_comps[3] *= list[Int].from_values(100000, 10000, 1000, 100, 10)[
                    to_parse - 1
                ]
            if len_remainder > to_parse and not all(
                map_input_str(_is_ascii_digit, tstr[(pos + to_parse) :])
            ):
                raise Error("Non-digit values in unparsed fraction")

    return time_comps


fn all(iterable: list[Bool]) -> Bool:
    for element in iterable:
        if not element:
            return False
    return True


fn map_input_str(funct: fn (String) -> Bool, s: String) -> list[Bool]:
    var result = list[Bool]()
    for i in range(len(s)):
        result.append(funct(s[i]))
    return result


fn _is_ascii_digit(c: String) -> Bool:
    alias my_str: String = "0123456789"
    for i in range(len(my_str)):
        if c == my_str[i]:
            return True
    return False


fn is_all_zeros(input_list: list[Int]) -> Bool:
    for i in range(len(input_list)):
        if input_list[i] != 0:
            return False
    return True
