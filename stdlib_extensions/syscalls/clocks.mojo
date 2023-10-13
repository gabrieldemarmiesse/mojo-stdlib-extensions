from memory.unsafe import Pointer
from .c_types import c_int

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

    let clockid_si32: c_int = _CLOCK_REALTIME

    external_call["clock_gettime", NoneType, c_int, Pointer[_CTimeSpec]](
        clockid_si32, ts_pointer
    )

    return ts
