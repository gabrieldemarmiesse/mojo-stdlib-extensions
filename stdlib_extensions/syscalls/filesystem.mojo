from ..syscalls import c


fn rmdir(pathname: String) raises:
    with c.Str(pathname) as pathname_as_c_str:
        let output = external_call["rmdir", c.int, c.char_pointer](
            pathname_as_c_str.vector.data
        )
        if output == c.SUCCESS:
            return
        elif output == c.EACCES:
            raise Error(
                "Write access to the directory containing "
                + pathname
                + " was notallowed, or one of the directories in the path prefix of "
                + pathname
                + " did notallow search permission."
            )
        elif output == c.EBUSY:
            raise Error(
                pathname
                + " is currently in use by the system or some process"
                "that prevents its removal.  On Linux, this means "
                + pathname
                + " is currently"
                "used as a mount point or is the root directory of the calling process."
            )
        elif output == c.EFAULT:
            raise Error(pathname + " points outside your accessible address space.")
        elif output == c.EINVAL:
            raise Error(pathname + " has .  as last component.")
        elif output == c.ENOENT:
            raise Error(
                "A directory component in "
                + pathname
                + " does not exist or is adangling symbolic link."
            )
        elif output == c.ENOMEM:
            raise Error("Insufficient kernel memory was available.")
        elif output == c.ENOTDIR:
            raise Error(
                pathname
                + ", or a component used as a directory in "
                + pathname
                + ", is not, in fact, a directory."
            )
        elif output == c.EPERM:
            raise Error(
                "The filesystem containing "
                + pathname
                + " does not support the removal of directories."
            )
        elif output == c.EROFS:
            raise Error(pathname + " refers to a directory on a read-only filesystem.")
        else:
            raise Error("rmdir failed with unknown error code: " + String(output))
