from .c_types import c_int


fn getpid() -> c_int:
    return external_call["getpid", c_int]()
