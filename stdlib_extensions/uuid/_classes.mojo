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
        version: Int = -1,
        is_safe: Int = SafeUUID.unknown,
    ):
        hex = replace(hex, "urn:", "")
        hex = replace(hex, "uuid:", "")
        hex = strip(hex, "{}")
        hex = replace(hex, "-", "")

        # TODO: enable erroring when it's allowed to raise at compile time
        # if len(hex) != 32:
        #     raise Error("badly formed hexadecimal UUID string")
        self.__init__(bytes_.fromhex(hex), version, is_safe)

    fn __init__(
        inout self,
        owned bytes: bytes_,
        version: Int = -1,
        is_safe: Int = SafeUUID.unknown,
    ):
        # TODO: enable this when it's allowed to raise at compile time
        # if bytes.__len__() != 16:
        #    raise ValueError("bytes is not a 16-char string")
        if version != -1:
            # TODO: enable this when it's allowed at compile time
            # if not 1 <= version <= 5:
            #    raise ValueError("illegal version number")
            # Set the variant to RFC 4122.
            bytes[8] &= 0x3F

            bytes[8] |= 0x80

            bytes[6] &= 0x0F

            bytes[6] |= version << 4

        self.__int_as_bytes = bytes
        self.is_safe = is_safe

    fn __eq__(self, other: UUID) -> Bool:
        return self.__int_as_bytes == other.__int_as_bytes

    def __str__(self):
        hex = "%032x" % self.int
        return "%s-%s-%s-%s-%s" % (hex[:8], hex[8:12], hex[12:16], hex[16:20], hex[20:])

    @property
    def bytes(self):
        return self.int.to_bytes(16)  # big endian


def uuid4():
    """Generate a random UUID."""
    return UUID(bytes=urandom(16), version=4)
