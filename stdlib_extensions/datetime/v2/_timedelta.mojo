from ...builtins import divmod, round, abs
from ...builtins._generic_list import _cmp_list
from ...builtins._hash import hash as custom_hash
from utils.variant import Variant


# TODO: use this in the timedelta constructor
alias IntOrFloat = Variant[Int, Float64]


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

    # Pickle support.

    @always_inline
    fn _getstate(self) -> list[Int]:
        return list[Int].from_values(self.days, self.seconds, self.microseconds)


#    def __reduce__(self):
#        return (self.__class__, self._getstate())
#
