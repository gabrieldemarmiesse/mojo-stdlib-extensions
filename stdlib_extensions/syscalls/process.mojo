from ..syscalls import c


fn getpid() -> c.int:
    return external_call["getpid", c.int]()
