# Types aliases
alias c_void = UInt8
alias c_char = UInt8
alias c_schar = Int8
alias c_uchar = UInt8
alias c_short = Int16
alias c_ushort = UInt16
alias c_int = Int32
alias c_uint = UInt32
alias c_long = Int64
alias c_ulong = UInt64
alias c_float = Float32
alias c_double = Float64

alias c_size_t = Int
alias c_ssize_t = Int

alias ptrdiff_t = Int64
alias intptr_t = Int64
alias uintptr_t = UInt64


# --- ( error.h Constants )-----------------------------------------------------
alias EPERM = 1
alias ENOENT = 2
alias ESRCH = 3
alias EINTR = 4
alias EIO = 5
alias ENXIO = 6
alias E2BIG = 7
alias ENOEXEC = 8
alias EBADF = 9
alias ECHILD = 10
alias EAGAIN = 11
alias ENOMEM = 12
alias EACCES = 13
alias EFAULT = 14
alias ENOTBLK = 15
alias EBUSY = 16
alias EEXIST = 17
alias EXDEV = 18
alias ENODEV = 19
alias ENOTDIR = 20
alias EISDIR = 21
alias EINVAL = 22
alias ENFILE = 23
alias EMFILE = 24
alias ENOTTY = 25
alias ETXTBSY = 26
alias EFBIG = 27
alias ENOSPC = 28
alias ESPIPE = 29
alias EROFS = 30
alias EMLINK = 31
alias EPIPE = 32
alias EDOM = 33
alias ERANGE = 34
alias EWOULDBLOCK = EAGAIN


fn to_char_ptr(s: String) -> Pointer[c_char]:
    """Only ASCII-based strings."""
    let ptr = Pointer[c_char]().alloc(len(s))
    for i in range(len(s)):
        ptr.store(i, ord(s[i]))
    return ptr


fn c_charptr_to_string(s: Pointer[c_char]) -> String:
    return String(s.bitcast[Int8](), strlen(s))


fn strlen(s: Pointer[c_char]) -> c_size_t:
    """Libc POSIX `strlen` function.
    Reference: https://man7.org/linux/man-pages/man3/strlen.3p.html
    Fn signature: size_t strlen(const char *s).
    """
    return external_call["strlen", c_size_t, Pointer[c_char]](s)
