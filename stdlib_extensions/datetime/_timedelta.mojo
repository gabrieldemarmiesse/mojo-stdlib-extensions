from ..builtins import divmod, list, modf
from ..builtins.string import rjust, join
from ..builtins._generic_list import _cmp_list
from ..builtins import custom_hash
from utils.variant import Variant
from math import abs, round
from .._utils import custom_debug_assert

# TODO: use this in the timedelta constructor
alias IntOrFloatVariant = Variant[Int, Float64]


struct IntOrFloat:
    """We define this to be able to do operation without worrying too much about type conversions.
    """

    var value: IntOrFloatVariant

    fn __init__(inout self, value: IntOrFloatVariant):
        self.value = value

    fn __init__(inout self, value: Int):
        self.value = value

    fn __init__(inout self, value: Float64):
        self.value = value

    fn __init__(inout self, value: Float32):
        self.value = IntOrFloatVariant(value.cast[DType.float64]())

    fn to_float(self) -> Float64:
        if self.value.isa[Int]():
            return Float64(self.value.get[Int]()[])
        else:
            return self.value.get[Float64]()[]

    fn to_int(self) -> Int:
        custom_debug_assert(self.value.isa[Int](), "We should have an int here")
        return self.value.get[Int]()[]

    fn isfloat(self) -> Bool:
        return self.value.isa[Float64]()

    fn isint(self) -> Bool:
        return self.value.isa[Int]()

    fn __mul__(self, other: Int) -> IntOrFloat:
        if self.value.isa[Int]():
            return IntOrFloat(self.value.get[Int]()[] * other)
        else:
            return IntOrFloat(self.value.get[Float64]()[] * Float64(other))

    fn __iadd__(inout self, other: IntOrFloat):
        if self.value.isa[Int]() and other.value.isa[Int]():
            self.value.set[Int](self.value.get[Int]()[] + other.value.get[Int]()[])
        else:
            # we upgrade to float
            self.value.set[Float64](self.to_float() + other.to_float())

    fn __add__(self, other: IntOrFloat) -> IntOrFloat:
        if self.value.isa[Int]() and other.value.isa[Int]():
            return IntOrFloat(self.value.get[Int]()[] + other.value.get[Int]()[])
        else:
            # we upgrade to float
            return IntOrFloat(self.to_float() + other.to_float())


@value
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
    var _dummy: Int  # remove when https://github.com/modularml/mojo/issues/1705 is fixed

    alias min = timedelta(-999999999)
    alias max = timedelta(
        days=999999999, hours=23, minutes=59, seconds=59, microseconds=999999
    )
    alias resolution = timedelta(microseconds=1)

    fn __init__(
        inout self,
        owned days: IntOrFloat = 0,
        owned seconds: IntOrFloat = 0,
        owned microseconds: IntOrFloat = 0,
        milliseconds: IntOrFloat = 0,
        minutes: IntOrFloat = 0,
        hours: IntOrFloat = 0,
        weeks: IntOrFloat = 0,
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
        var d: Int = 0
        var s: Int = 0
        var us: Int = 0

        # Normalize everything to days, seconds, microseconds.
        days += weeks * 7
        seconds += minutes * 60 + hours * 3600
        microseconds += milliseconds * 1000

        # Get rid of all fractions, and normalize s and us.
        # Take a deep breath <wink>.
        var daysecondsfrac: Float64
        if days.isfloat():
            var dayfrac: Float64
            var days_as_int_still_float: Float64
            dayfrac, days_as_int_still_float = modf(days.to_float())
            var daysecondswhole: Float64
            daysecondsfrac, daysecondswhole = modf(dayfrac * (24.0 * 3600.0))
            s = int(daysecondswhole)
            d = int(days_as_int_still_float)
        else:
            daysecondsfrac = 0.0
            d = days.to_int()

        custom_debug_assert(abs(daysecondsfrac) <= 1.0)
        custom_debug_assert(abs(s) <= 24 * 3600)
        # days isn't referenced again before redefinition
        var secondsfrac: Float64

        if seconds.isfloat():
            var seconds_as_int_still_float: Float64
            secondsfrac, seconds_as_int_still_float = modf(seconds.to_float())
            seconds = int(seconds_as_int_still_float)
            secondsfrac += daysecondsfrac
            custom_debug_assert(abs(secondsfrac) <= 2.0)
        else:
            secondsfrac = daysecondsfrac

        # daysecondsfrac isn't referenced again
        custom_debug_assert(abs(secondsfrac) <= 2.0)

        custom_debug_assert(seconds.isint())
        var additional_days: Int
        var additional_seconds: Int
        additional_days, additional_seconds = divmod(seconds.to_int(), 24 * 3600)
        d += additional_days
        s += additional_seconds  # can't overflow
        custom_debug_assert(abs(s) <= 2 * 24 * 3600)
        # seconds isn't referenced again before redefinition

        var usdouble = secondsfrac * 1e6
        custom_debug_assert(abs(usdouble) < 2.1e6)  # exact value not critical
        # secondsfrac isn't referenced again
        var additional_microseconds: Int
        if microseconds.isfloat():
            var microseconds_as_int = int(round(microseconds.to_float() + usdouble))
            var additional_seconds: Int
            var additional_days: Int
            additional_seconds, additional_microseconds = divmod(
                microseconds_as_int, 1000000
            )
            additional_days, additional_seconds = divmod(additional_seconds, 24 * 3600)
            d += additional_days
            s += additional_seconds
        else:
            var additional_seconds: Int
            var additional_days: Int
            additional_microseconds = microseconds.to_int()
            additional_seconds, additional_microseconds = divmod(
                additional_microseconds, 1000000
            )
            additional_days, additional_seconds = divmod(additional_seconds, 24 * 3600)
            d += additional_days
            s += additional_seconds
            additional_microseconds = round(additional_microseconds + usdouble).to_int()
        # TODO: Manage floats
        custom_debug_assert(abs(s) <= 3 * 24 * 3600)
        custom_debug_assert(abs(additional_microseconds) < 3100000)

        # Just a little bit of carrying possible for microseconds and seconds.
        var additional_seconds2: Int
        additional_seconds2, us = divmod(additional_microseconds, 1000000)
        s += additional_seconds2
        var additional_days2: Int
        additional_days2, s = divmod(s, 24 * 3600)
        d += additional_days2

        custom_debug_assert(0 <= s < 24 * 3600)
        custom_debug_assert(0 <= us < 1000000)

        custom_debug_assert(
            abs(d) < 999999999, "timedelta # of days is too large: " + str(d)
        )
        self.days = d
        self.seconds = s
        self.microseconds = us
        self._dummy = -1

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
