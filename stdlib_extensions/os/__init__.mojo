from ..syscalls import process


fn getpid() -> Int:
    return process.getpid().to_int()
