from memory.unsafe import Pointer

alias SECONDS_TO_MICROSECONDS = 1000000
alias MINUTES_TO_MICROSECONDS = 60 * SECONDS_TO_MICROSECONDS
alias HOURS_TO_MICROSECONDS = 60 * MINUTES_TO_MICROSECONDS
alias DAYS_TO_MICROSECONDS = 24 * HOURS_TO_MICROSECONDS


fn _convert_periods_to_microseconds(
    days: Int = 0,
    hours: Int = 0,
    minutes: Int = 0,
    seconds: Int = 0,
    microseconds: Int = 0,
) -> Int64:
    """Note that here we start at 0 for year, month and day for easier computing"""
    return (
        days * DAYS_TO_MICROSECONDS
        + hours * HOURS_TO_MICROSECONDS
        + minutes * MINUTES_TO_MICROSECONDS
        + seconds * SECONDS_TO_MICROSECONDS
        + microseconds
    )


fn get_months_to_days_vector(is_leap_year: Bool = False) -> DynamicVector[Int]:
    var result = DynamicVector[Int]()
    result.push_back(31)  # january
    if is_leap_year:
        result.push_back(29)  # february
    else:
        result.push_back(28)  # february
    result.push_back(31)  # march
    result.push_back(30)  # april
    result.push_back(31)  # may
    result.push_back(30)  # june
    result.push_back(31)  # july
    result.push_back(31)  # august
    result.push_back(30)  # september
    result.push_back(31)  # october
    result.push_back(30)  # november
    result.push_back(
        31
    )  # december, in practice, this is never used since we jump one year instead of reading this value
    return result


fn is_leap_year(year: Int) -> Bool:
    return (year % 4 == 0 and year % 100 != 0) or year % 400 == 0


fn days_in_this_year(year: Int) -> Int:
    return 366 if is_leap_year(year) else 365


fn get_number_of_days_since_start_of_calendar(nb_years: Int) -> Int:
    # Years before the current year
    let years_before = nb_years - 1

    # Compute number of leap years before the given year
    let leap_years = (years_before // 4) - (years_before // 100) + (years_before // 400)

    # Total days is regular years + leap years
    return (365 * years_before) + leap_years


fn compute_years_from_days(number_of_days: Int) -> Int:
    # Estimate the year using average days per year considering leap years
    var estimated_year: Int = (number_of_days // 365.25).to_int() or 1

    # Calculate the days in the leap years up to the estimated year
    var leap_years = estimated_year // 4 - estimated_year // 100 + estimated_year // 400

    # Adjust the year considering leap years
    while number_of_days >= (estimated_year * 365 + leap_years):
        estimated_year += 1
        if estimated_year % 4 == 0 and (
            estimated_year % 100 != 0 or estimated_year % 400 == 0
        ):
            leap_years += 1

    return estimated_year


alias _CLOCK_REALTIME = 0


@value
struct _CTimeSpec:
    var tv_sec: Int
    var tv_nsec: Int

    fn __init__(inout self):
        self.tv_sec = 0
        self.tv_nsec = 0


fn clock_gettime() -> _CTimeSpec:
    """Low-level call to the clock_gettime libc function."""

    var ts = _CTimeSpec()
    let ts_pointer = Pointer[_CTimeSpec].address_of(ts)

    let clockid_si32: Int32 = _CLOCK_REALTIME

    external_call["clock_gettime", NoneType, Int32, Pointer[_CTimeSpec]](
        clockid_si32, ts_pointer
    )

    return ts
