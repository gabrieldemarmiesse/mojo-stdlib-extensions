from ..builtins import divmod, list, modf
from ..builtins.string import rjust, join
from ..builtins._generic_list import _cmp_list
from ..builtins import custom_hash
from utils.variant import Variant
from math import abs, round
from .._utils import custom_debug_assert


struct timedelta(CollectionElement, Stringable, Hashable):
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

    alias min = timedelta(-999999999)
    alias max = timedelta(
        days=999999999, hours=23, minutes=59, seconds=59, microseconds=999999
    )
    alias resolution = timedelta(microseconds=1)

    fn __init__(
        inout self,
        owned days: Float64 = 0,
        owned seconds: Float64 = 0,
        owned microseconds: Float64 = 0,
        owned milliseconds: Float64 = 0,
        owned minutes: Float64 = 0,
        owned hours: Float64 = 0,
        owned weeks: Float64 = 0,
        *,
        use_floats: Bool,
    ):
        """This is the datetime constructor which can be used to create it from floating point values.

        Since Mojo can't decide which constructor to take when there are unspecified arguments, we have
        to use the keyword arguments `use_floats=True` here to differentiate the two constructors.
        """
        # make sure weeks is a round number:
        var weeks_remainder: Float64
        weeks_remainder, weeks = modf(weeks)
        days += weeks_remainder * 7

        # make sure days is a round number:
        var days_remainder: Float64
        days_remainder, days = modf(days)
        hours += days_remainder * 24

        # make sure hours is a round number:
        var hours_remainder: Float64
        hours_remainder, hours = modf(hours)
        minutes += hours_remainder * 60

        # make sure minutes is a round number:
        var minutes_remainder: Float64
        minutes_remainder, minutes = modf(minutes)
        seconds += minutes_remainder * 60

        # make sure seconds is a round number:
        var seconds_remainder: Float64
        seconds_remainder, seconds = modf(seconds)
        milliseconds += seconds_remainder * 1000

        # make sure milliseconds is a round number:
        var milliseconds_remainder: Float64
        milliseconds_remainder, milliseconds = modf(milliseconds)
        microseconds += milliseconds_remainder * 1000

        # make sure microseconds is a round number:
        microseconds = round(microseconds)

        self.__init__(
            weeks=weeks.to_int(),
            days=days.to_int(),
            hours=hours.to_int(),
            minutes=minutes.to_int(),
            seconds=seconds.to_int(),
            milliseconds=milliseconds.to_int(),
            microseconds=microseconds.to_int(),
        )

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
        # We keep only days, seconds, microseconds
        microseconds += milliseconds * 1000
        seconds += minutes * 60 + hours * 3600
        days += weeks * 7
        self.__init__(days, seconds, microseconds, is_normalized=False)

    fn __init__(
        inout self,
        owned days: Int,
        owned seconds: Int,
        owned microseconds: Int,
        *,
        is_normalized: Bool,
    ):
        """Call this with is_normalized=True if you know the values are already in the correct range.
        """

        if not is_normalized:
            var extra_seconds: Int
            extra_seconds, microseconds = divmod(microseconds, 1000000)
            seconds += extra_seconds

            var extra_days: Int
            extra_days, seconds = divmod(seconds, 24 * 60 * 60)
            days += extra_days

        custom_debug_assert(
            0 <= microseconds < 1000000,
            "microseconds should be in the range [0, 1000000[",
        )
        custom_debug_assert(
            0 <= seconds < 24 * 60 * 60,
            "seconds should be in the range [0, 24 * 60 * 60[",
        )
        custom_debug_assert(
            -99999999 <= days <= 999999999,
            "days should be in the range -999999999 to 999999999",
        )

        self.days = days
        self.seconds = seconds
        self.microseconds = microseconds

    # use @value when https://github.com/modularml/mojo/issues/1705 is fixed
    fn __copyinit__(inout self, existing: Self):
        self.days = existing.days
        self.seconds = existing.seconds
        self.microseconds = existing.microseconds

    fn __moveinit__(inout self, owned existing: Self):
        self.days = existing.days
        self.seconds = existing.seconds
        self.microseconds = existing.microseconds

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
        return "datetime.timedelta(" + join(", ", args) + ")"

    fn __str__(self) -> String:
        var mm: Int
        var ss: Int
        var hh: Int
        mm, ss = divmod(self.seconds, 60)
        hh, mm = divmod(mm, 60)
        var s = str(hh)
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

    fn __truediv__(self, other: Int) -> timedelta:
        return timedelta(
            microseconds=(
                self._to_microseconds().cast[DType.float64]() / Float64(other)
            ).to_int()
        )

    # TODO: divide by a float
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

    fn __ne__(self, other: timedelta) -> Bool:
        return not (self == other)

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

    fn __hash__(self) -> Int:
        return custom_hash(self._getstate())

    fn __bool__(self) -> Bool:
        return self.days != 0 or self.seconds != 0 or self.microseconds != 0

    @always_inline
    fn _getstate(self) -> list[Int]:
        return list[Int].from_values(self.days, self.seconds, self.microseconds)
