from ..syscalls import clocks


fn time_ns() -> Int64:
    """Returns the number of nanoseconds since the epoch."""
    let time_struct = clocks.clock_gettime()

    return time_struct.tv_sec * 1_000_000_000 + time_struct.tv_nsec


fn time() -> Float64:
    """Returns the number of seconds since the epoch, in float."""
    let time_struct = clocks.clock_gettime()
    return (
        time_struct.tv_sec.cast[DType.float64]()
        + time_struct.tv_nsec.cast[DType.float64]() / 1_000_000_000
    )
