from ..builtins import bytes
from ..syscalls import c
from .._utils import custom_debug_assert


fn getrandom(size: c.size_t) -> bytes:
    var result = bytes(size.to_int())
    var nb_bytes_written = external_call[
        "getrandom", c.ssize_t, AnyPointer[UInt8], c.size_t, c.uint
    ](result._vector.data, size, c.GRND_NONBLOCK.cast[DType.uint32]())
    if nb_bytes_written < 0:
        custom_debug_assert(False, "getrandom failed")
    if nb_bytes_written != result.__len__():
        custom_debug_assert(False, "getrandom didn't send enough bytes")
    return result
