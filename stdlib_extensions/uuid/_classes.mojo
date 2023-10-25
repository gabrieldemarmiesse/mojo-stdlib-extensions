from ..builtins.string import replace, strip
from ..builtins import bytes as bytes_
from ..os import urandom

from utils.static_tuple import StaticTuple
from memory import stack_allocation

alias RESERVED_NCS = "reserved for NCS compatibility"
alias RFC_4122 = "specified in RFC 4122"
alias RESERVED_MICROSOFT = "reserved for Microsoft compatibility"
alias RESERVED_FUTURE = "reserved for future definition"


struct SafeUUID:
    alias safe = 0
    alias unsafe = -1
    alias unknown = -2  # this is normally None but we don't have traits


struct UUID:
    # it would be much better to have something static and stack allocated
    # but I cannot find how to do it.
    var __int_as_bytes: bytes_
    var is_safe: Int

    fn __init__(
        inout self,
        owned hex: String,
        is_safe: Int = SafeUUID.unknown,
    ):
        hex = replace(hex, "urn:", "")
        hex = replace(hex, "uuid:", "")
        hex = strip(hex, "{}")
        hex = replace(hex, "-", "")

        # TODO: enable erroring when it's allowed to raise at compile time
        # if len(hex) != 32:
        #     raise Error("badly formed hexadecimal UUID string")
        self.__init__(bytes_.fromhex(hex), is_safe)

    fn __init__(
        inout self,
        owned bytes: bytes_,
        is_safe: Int = SafeUUID.unknown,
    ):
        self.__int_as_bytes = bytes
        self.is_safe = is_safe

    fn __eq__(self, other: UUID) -> Bool:
        return self.__int_as_bytes == other.__int_as_bytes

    fn __str__(self) -> String:
        let hex = self.__int_as_bytes.hex()
        return (
            hex[:8]
            + "-"
            + hex[8:12]
            + "-"
            + hex[12:16]
            + "-"
            + hex[16:20]
            + "-"
            + hex[20:]
        )

    fn __repr__(self) -> String:
        return "UUID('" + self.__str__() + "')"

    fn bytes(self) -> bytes_:
        return self.__int_as_bytes


# The following standard UUIDs are for use with uuid3() or uuid5().

alias NAMESPACE_DNS = UUID("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
alias NAMESPACE_URL = UUID("6ba7b811-9dad-11d1-80b4-00c04fd430c8")
alias NAMESPACE_OID = UUID("6ba7b812-9dad-11d1-80b4-00c04fd430c8")
alias NAMESPACE_X500 = UUID("6ba7b814-9dad-11d1-80b4-00c04fd430c8")
