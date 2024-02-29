from ..syscalls import c
from .._utils import custom_debug_assert


fn rmdir(pathname: String):
    with c.Str(pathname) as pathname_as_c_str:
        var output = external_call["rmdir", c.int, c.char_pointer](
            pathname_as_c_str.vector.data
        )
        if output == c.SUCCESS:
            return
        elif output == c.EACCES:
            custom_debug_assert(
                False,
                "Write access to the directory containing "
                + pathname
                + " was notallowed, or one of the directories in the path prefix of "
                + pathname
                + " did notallow search permission.",
            )
        elif output == c.EBUSY:
            custom_debug_assert(
                False,
                pathname
                + " is currently in use by the system or some process"
                "that prevents its removal.  On Linux, this means "
                + pathname
                + " is currently"
                "used as a mount point or is the root directory of the calling"
                " process.",
            )
        elif output == c.EFAULT:
            custom_debug_assert(
                False, pathname + " points outside your accessible address space."
            )
        elif output == c.EINVAL:
            custom_debug_assert(False, pathname + " has .  as last component.")
        elif output == c.ENOENT:
            custom_debug_assert(
                False,
                "A directory component in "
                + pathname
                + " does not exist or is adangling symbolic link.",
            )
        elif output == c.ENOMEM:
            custom_debug_assert(False, "Insufficient kernel memory was available.")
        elif output == c.ENOTDIR:
            custom_debug_assert(
                False,
                pathname
                + ", or a component used as a directory in "
                + pathname
                + ", is not, in fact, a directory.",
            )
        elif output == c.EPERM:
            custom_debug_assert(
                False,
                "The filesystem containing "
                + pathname
                + " does not support the removal of directories.",
            )
        elif output == c.EROFS:
            custom_debug_assert(
                False, pathname + " refers to a directory on a read-only filesystem."
            )
        else:
            custom_debug_assert(
                False, "rmdir failed with unknown error code: " + String(output)
            )


fn unlink(pathname: String):
    with c.Str(pathname) as pathname_as_c_str:
        var output = external_call["unlink", c.int, c.char_pointer](
            pathname_as_c_str.vector.data
        )
        if output == c.SUCCESS:
            return
        elif output == c.EACCES:
            custom_debug_assert(
                False,
                "Write permission is denied for the directory from which the file +"
                + pathname
                + " is to be removed, "
                "or the directory has the sticky bit set and you do not own the file.",
            )
        elif output == c.EBUSY:
            custom_debug_assert(
                False,
                "the file "
                + pathname
                + " is being used by the system in such a way thatit can’t be unlinked."
                " For example, you might see this error if the filename specifies the"
                " root directory or a mount point for a file system.",
            )
        elif output == c.ENOENT:
            custom_debug_assert(False, "he file " + pathname + " doesn’t exist.")
        elif output == c.EPERM:
            custom_debug_assert(
                False,
                (
                    "On some systems unlink cannot be used to delete the name of a"
                    " directory, or at least can only be used this way by a privileged"
                    " user."
                ),
            )
        elif output == c.EROFS:
            custom_debug_assert(
                False,
                pathname
                + " refers to a file on a read-only filesystem and thus cannot be"
                " removed.",
            )
        else:
            custom_debug_assert(
                False, "rmdir failed with unknown error code: " + String(output)
            )


fn read_string_from_fd(file_descriptor: c.int) -> String:
    alias buffer_size: Int = 2**13
    var buffer: c.Str
    with c.Str(size=buffer_size) as buffer:
        var read_count: c.ssize_t = external_call[
            "read", c.ssize_t, c.int, c.char_pointer, c.size_t
        ](file_descriptor, buffer.vector.data, buffer_size)
        if read_count == -1:
            custom_debug_assert(
                False, "Failed to read file descriptor" + String(file_descriptor)
            )

        # for stdin, stdout, stderr, we can do this approximation
        # normally we would decode to utf-8 as we go and check for \n, but we can't do that now because
        # we don't have easy to use utf-8 support.
        if read_count == buffer_size:
            custom_debug_assert(
                False,
                "You can only read up to "
                + String(buffer_size)
                + " bytes. "
                "Wait for UTF-8 support in Mojo for better handling of long inputs.",
            )

        return buffer.to_string(read_count)


fn read_from_stdin() -> String:
    return read_string_from_fd(c.FD_STDIN)
