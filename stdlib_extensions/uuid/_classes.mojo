from ..builtins import bytes
from utils.static_tuple import StaticTuple
from memory import stack_allocation
from ..os import urandom
from ..builtins.string import replace

alias RESERVED_NCS = "reserved for NCS compatibility"
alias RFC_4122 = "specified in RFC 4122"
alias RESERVED_MICROSOFT = "reserved for Microsoft compatibility"
alias RESERVED_FUTURE = "reserved for future definition"

alias int_ = Int  # The built-in int type
alias bytes_ = bytes  # The built-in bytes type


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
        hex = hex.strip("{}").replace("-", "")
        if len(hex) != 32:
            raise Error("badly formed hexadecimal UUID string")
        self.__init__(bytes_.fromhex(hex), version, is_safe)

    fn __init__(inout self, bytes: bytes, version=-1, is_safe=SafeUUID.unknown):
        if len(bytes) != 16:
            raise ValueError("bytes is not a 16-char string")
        assert isinstance(bytes, bytes_), repr(bytes)
        int = int_.from_bytes(bytes)
        if version != -1:
            if not 1 <= version <= 5:
                raise ValueError("illegal version number")
            # Set the variant to RFC 4122.
            int &= ~(0xC000 << 48)
            int |= 0x8000 << 48
            # Set the version number.
            int &= ~(0xF000 << 64)
            int |= version << 76

        self.__int_as_bytes = bytes
        self.is_safe = is_safe

    def __eq__(self, other):
        if isinstance(other, UUID):
            return self.int == other.int
        return NotImplemented

    # Q. What's the value of being able to sort UUIDs?
    # A. Use them as keys in a B-Tree or similar mapping.

    def __lt__(self, other):
        if isinstance(other, UUID):
            return self.int < other.int
        return NotImplemented

    def __gt__(self, other):
        if isinstance(other, UUID):
            return self.int > other.int
        return NotImplemented

    def __le__(self, other):
        if isinstance(other, UUID):
            return self.int <= other.int
        return NotImplemented

    def __ge__(self, other):
        if isinstance(other, UUID):
            return self.int >= other.int
        return NotImplemented

    def __hash__(self):
        return hash(self.int)

    def __int__(self):
        return self.int

    def __repr__(self):
        return "%s(%r)" % (self.__class__.__name__, str(self))

    def __setattr__(self, name, value):
        raise TypeError("UUID objects are immutable")

    def __str__(self):
        hex = "%032x" % self.int
        return "%s-%s-%s-%s-%s" % (hex[:8], hex[8:12], hex[12:16], hex[16:20], hex[20:])

    @property
    def bytes(self):
        return self.int.to_bytes(16)  # big endian

    @property
    def bytes_le(self):
        bytes = self.bytes
        return (
            bytes[4 - 1 :: -1]
            + bytes[6 - 1 : 4 - 1 : -1]
            + bytes[8 - 1 : 6 - 1 : -1]
            + bytes[8:]
        )

    @property
    def fields(self):
        return (
            self.time_low,
            self.time_mid,
            self.time_hi_version,
            self.clock_seq_hi_variant,
            self.clock_seq_low,
            self.node,
        )

    @property
    def time_low(self):
        return self.int >> 96

    @property
    def time_mid(self):
        return (self.int >> 80) & 0xFFFF

    @property
    def time_hi_version(self):
        return (self.int >> 64) & 0xFFFF

    @property
    def clock_seq_hi_variant(self):
        return (self.int >> 56) & 0xFF

    @property
    def clock_seq_low(self):
        return (self.int >> 48) & 0xFF

    @property
    def time(self):
        return (
            ((self.time_hi_version & 0x0FFF) << 48)
            | (self.time_mid << 32)
            | self.time_low
        )

    @property
    def clock_seq(self):
        return ((self.clock_seq_hi_variant & 0x3F) << 8) | self.clock_seq_low

    @property
    def node(self):
        return self.int & 0xFFFFFFFFFFFF

    @property
    def hex(self):
        return "%032x" % self.int

    @property
    def urn(self):
        return "urn:uuid:" + str(self)

    @property
    def variant(self):
        if not self.int & (0x8000 << 48):
            return RESERVED_NCS
        elif not self.int & (0x4000 << 48):
            return RFC_4122
        elif not self.int & (0x2000 << 48):
            return RESERVED_MICROSOFT
        else:
            return RESERVED_FUTURE

    @property
    def version(self):
        # The version bits are only meaningful for RFC 4122 UUIDs.
        if self.variant == RFC_4122:
            return int((self.int >> 76) & 0xF)


def uuid4():
    """Generate a random UUID."""
    return UUID(bytes=os.urandom(16), version=4)


# The following standard UUIDs are for use with uuid3() or uuid5().
alias NAMESPACE_DNS = UUID("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
alias NAMESPACE_URL = UUID("6ba7b811-9dad-11d1-80b4-00c04fd430c8")
alias NAMESPACE_OID = UUID("6ba7b812-9dad-11d1-80b4-00c04fd430c8")
alias NAMESPACE_X500 = UUID("6ba7b814-9dad-11d1-80b4-00c04fd430c8")
