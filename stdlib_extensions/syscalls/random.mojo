from ..builtins import bytes
from ..syscalls import c


fn getrandom(size: c.size_t) raises -> bytes:
    # it's just let here to please the compiler
    # because it can't track writing directly to memory with pointers
    let result = bytes(size.to_int())
    let nb_bytes_written = external_call[
        "getrandom", c.ssize_t, Pointer[UInt8], c.size_t, c.uint
    ](result._vector.data, size, c.GRND_NONBLOCK.cast[DType.uint32]())
    if nb_bytes_written < 0:
        raise Error("getrandom failed")
    if nb_bytes_written != result.__len__():
        raise Error("getrandom didn't send enough bytes")
    return result
