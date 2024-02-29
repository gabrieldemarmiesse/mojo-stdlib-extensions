from memory.unsafe import Pointer
from ..syscalls import c

alias _CLOCK_REALTIME = 0


@value
struct _CTimeSpec:
    var tv_sec: c.time_t
    var tv_nsec: c.long

    fn __init__(inout self):
        self.tv_sec = 0
        self.tv_nsec = 0


fn clock_gettime() -> _CTimeSpec:
    """Low-level call to the clock_gettime libc function."""

    var ts = _CTimeSpec()
    var ts_pointer = Pointer[_CTimeSpec].address_of(ts)

    var clockid_si32: c.int = _CLOCK_REALTIME

    external_call["clock_gettime", NoneType, c.int, Pointer[_CTimeSpec]](
        clockid_si32, ts_pointer
    )

    return ts
