from ..syscalls import clocks


fn time_ns() -> Int64:
    """Returns the number of nanoseconds since the epoch."""
    var time_struct = clocks.clock_gettime()

    return time_struct.tv_sec * 1_000_000_000 + time_struct.tv_nsec


fn time() -> Float64:
    """Returns the number of seconds since the epoch, in float."""
    var time_struct = clocks.clock_gettime()
    return (
        time_struct.tv_sec.cast[DType.float64]()
        + time_struct.tv_nsec.cast[DType.float64]() / 1_000_000_000
    )


@value
struct struct_time:
    var tm_year: Int
    var tm_mon: Int
    var tm_mday: Int
    var tm_hour: Int
    var tm_min: Int
    var tm_sec: Int
    var tm_wday: Int
    var tm_yday: Int
    var tm_isdst: Int

    fn __init__(inout self, values: Tuple[Int, Int, Int, Int, Int, Int, Int, Int, Int]):
        self.tm_year = values.get[0, Int]()
        self.tm_mon = values.get[1, Int]()
        self.tm_mday = values.get[2, Int]()
        self.tm_hour = values.get[3, Int]()
        self.tm_min = values.get[4, Int]()
        self.tm_sec = values.get[5, Int]()
        self.tm_wday = values.get[6, Int]()
        self.tm_yday = values.get[7, Int]()
        self.tm_isdst = values.get[8, Int]()

    fn __getitem__(self, index: Int) -> Int:
        if index == 0:
            return self.tm_year
        elif index == 1:
            return self.tm_mon
        elif index == 2:
            return self.tm_mday
        elif index == 3:
            return self.tm_hour
        elif index == 4:
            return self.tm_min
        elif index == 5:
            return self.tm_sec
        elif index == 6:
            return self.tm_wday
        elif index == 7:
            return self.tm_yday
        elif index == 8:
            return self.tm_isdst
        else:
            # TODO raise an error here
            return 0
