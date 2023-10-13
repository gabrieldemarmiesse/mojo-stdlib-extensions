"""Everywhere, we assume that the year starts at 0 because it's easier to compute.
But when the user sees it (public api), the the year starts at 1.
Same for day and month.
"""
from stdlib_extensions.datetime.utils import (
    _convert_periods_to_microseconds,
    is_leap_year,
    compute_years_from_days,
    get_number_of_days_since_start_of_calendar,
    get_months_to_days_vector,
    SECONDS_TO_MICROSECONDS,
    MINUTES_TO_MICROSECONDS,
    HOURS_TO_MICROSECONDS,
    DAYS_TO_MICROSECONDS,
    clock_gettime,
)
from stdlib_extensions.builtins.string import rjust

from time import now


@value
struct timedelta:
    # replace by let when it's available because this struct is immutable
    var _microseconds: Int64

    fn __init__(
        inout self,
        days: Int = 0,
        seconds: Int = 0,
        microseconds: Int = 0,
        milliseconds: Int = 0,
        minutes: Int = 0,
        hours: Int = 0,
        weeks: Int = 0,
    ) raises:
        self._microseconds = _convert_periods_to_microseconds(
            days=days + weeks * 7,
            hours=hours,
            minutes=minutes,
            seconds=seconds,
            microseconds=microseconds,
        ).to_int()

    fn total_microseconds(self) -> Int:
        return self._microseconds.to_int()

    fn total_seconds(self) -> Int:
        return (self._microseconds // SECONDS_TO_MICROSECONDS).to_int()

    fn __add__(self, other: timedelta) raises -> timedelta:
        return timedelta(
            microseconds=(self._microseconds + other._microseconds).to_int()
        )

    fn __sub__(self, other: timedelta) raises -> timedelta:
        return timedelta(
            microseconds=(self._microseconds - other._microseconds).to_int()
        )


@value
struct datetime:
    # actually should be a let, this struct is immutable
    # this is not since epoch, this is since day 1 or year 1 (start of the Gregorian calendar)
    # we have to use 64 bits to be sure it's big enough.
    # 32 bits would be enough for 292 years only if my math is correct.
    var _microseconds: Int64

    fn __init__(
        inout self,
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        microsecond: Int = 0,
    ) raises:
        if not (1 <= year <= 9999):
            raise Error("year must be in the range 1-9999")

        if not (1 <= month <= 12):
            raise Error("month must be in the range 1-12")

        if not (1 <= day <= 31):
            # TODO: this check could be better
            raise Error("day must be in the range 1-31")

        if not (0 <= hour <= 23):
            raise Error("hour must be in the range 0-23")

        if not (0 <= minute <= 59):
            raise Error("minute must be in the range 0-59")

        if not (0 <= second <= 59):
            raise Error("second must be in the range 0-59")

        if not (0 <= microsecond <= 999999):
            raise Error("microsecond must be in the range 0-999999")

        let zero_based_year: Int = year - 1
        var days: Int = zero_based_year * 365 + zero_based_year // 4 - zero_based_year // 100 + zero_based_year // 400

        alias months_to_days_vector = get_months_to_days_vector()

        for i in range(month - 1):
            days += months_to_days_vector[i]

        if is_leap_year(year) and month >= 2:
            days += 1

        self._microseconds = _convert_periods_to_microseconds(
            (day - 1) + days, hour, minute, second, microsecond
        ).to_int()

    fn __init__(inout self, _microseconds: Int64):
        self._microseconds = _microseconds

    fn microsecond(self) -> Int:
        return (self._microseconds % SECONDS_TO_MICROSECONDS).to_int()

    fn second(self) -> Int:
        return (
            (self._microseconds % MINUTES_TO_MICROSECONDS) // SECONDS_TO_MICROSECONDS
        ).to_int()

    fn minute(self) -> Int:
        return (
            (self._microseconds % HOURS_TO_MICROSECONDS) // MINUTES_TO_MICROSECONDS
        ).to_int()

    fn hour(self) -> Int:
        return (
            (self._microseconds % DAYS_TO_MICROSECONDS) // HOURS_TO_MICROSECONDS
        ).to_int()

    fn day(self) -> Int:
        return self._months_and_days().get[1, Int]()

    fn month(self) -> Int:
        return self._months_and_days().get[0, Int]()

    fn year(self) -> Int:
        # the year starts at 1
        return compute_years_from_days(self._total_days())

    fn _months_and_days(self) -> Tuple[Int, Int]:
        let year = self.year()
        var days_left = self._total_days() - get_number_of_days_since_start_of_calendar(
            year
        ) + 1
        let months_to_days_vector = get_months_to_days_vector(is_leap_year(year))
        var days_this_month: Int = 0
        for month_to_try in range(1, 13):
            days_this_month = months_to_days_vector[month_to_try - 1]
            if days_left > days_this_month:
                days_left -= days_this_month
            else:
                return month_to_try, days_left
        return 0, 0  # this should never happen

    fn _total_days(self) -> Int:
        return (self._microseconds // DAYS_TO_MICROSECONDS).to_int()

    fn __add__(self, other: timedelta) raises -> datetime:
        return datetime(_microseconds=self._microseconds + other._microseconds)

    fn __sub__(self, other: datetime) raises -> timedelta:
        return timedelta(
            microseconds=(self._microseconds - other._microseconds).to_int()
        )

    fn __str__(self) raises -> String:
        var result: String = ""
        result += rjust(String(self.year()), 4, "0")
        result += "-" + rjust(String(self.month()), 2, "0")
        result += "-" + rjust(String(self.day()), 2, "0")
        result += " " + rjust(String(self.hour()), 2, "0")
        result += ":" + rjust(String(self.minute()), 2, "0")
        result += ":" + rjust(String(self.second()), 2, "0")

        if self.microsecond() != 0:
            result += "." + rjust(String(self.microsecond()), 6, "0")
        return result

    fn __repr__(self) -> String:
        var result = "datetime.datetime(" + String(self.year()) + ", " + String(
            self.month()
        ) + ", " + String(self.day()) + ", " + String(self.hour()) + ", " + String(
            self.minute()
        )
        let second = self.second()
        let microsecond = self.microsecond()

        if second or microsecond:
            result += ", " + String(second)

        if microsecond:
            result += ", " + String(microsecond)

        return result + ")"


fn datetime_now() raises -> datetime:
    let ctime_spec = clock_gettime()
    return datetime(1970, 1, 1) + timedelta(
        seconds=ctime_spec.tv_sec, microseconds=ctime_spec.tv_nsec // 1_000
    )


fn datetime_min() -> datetime:
    return datetime(_microseconds=0)


fn datetime_max() raises -> datetime:
    return datetime(9999, 12, 31, 23, 59, 59, 999999)
