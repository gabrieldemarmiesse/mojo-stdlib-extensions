from ..builtins.string import replace, strip
from ..builtins import bytes as bytes_, to_bytes
from ..os import urandom

from utils.static_tuple import StaticTuple
from memory import stack_allocation

alias RESERVED_NCS = "reserved for NCS compatibility"
alias RFC_4122 = "specified in RFC 4122"
alias RESERVED_MICROSOFT = "reserved for Microsoft compatibility"
alias RESERVED_FUTURE = "reserved for future definition"

alias UUIDBytes = SIMD[DType.uint8, 16]


struct SafeUUID:
    alias safe = 0
    alias unsafe = -1
    alias unknown = -2  # this is normally None but we don't have traits


fn uint8_simd_to_int[simd_size: Int](x: SIMD[DType.uint8, simd_size]) -> Int:
    # a bitcast would be better but we don't have that yet it seems
    var output = 0
    for i in range(simd_size):
        output += x[i].to_int() * ((2**8) ** (simd_size - i - 1))
    return output


@always_inline
fn get_bit(x: SIMD[DType.uint8, 1], i: Int) -> Bool:
    return ((x >> i) & 1).cast[DType.bool]()


struct UUID(Stringable):
    var __bytes: UUIDBytes
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
        bytes: bytes_,
        is_safe: Int = SafeUUID.unknown,
    ):
        self.__bytes = UUIDBytes(
            bytes[0],
            bytes[1],
            bytes[2],
            bytes[3],
            bytes[4],
            bytes[5],
            bytes[6],
            bytes[7],
            bytes[8],
            bytes[9],
            bytes[10],
            bytes[11],
            bytes[12],
            bytes[13],
            bytes[14],
            bytes[15],
        )
        self.is_safe = is_safe

    fn __eq__(self, other: UUID) -> Bool:
        return self.__bytes == other.__bytes

    fn __ne__(self, other: UUID) -> Bool:
        return self.__bytes != other.__bytes

    # TODO: Can we vectorize those methods?
    fn __lt__(self, other: UUID) -> Bool:
        for i in range(16):
            if self.__bytes[i] == other.__bytes[i]:
                continue
            return self.__bytes[i] < other.__bytes[i]
        return False

    fn __gt__(self, other: UUID) -> Bool:
        for i in range(16):
            if self.__bytes[i] == other.__bytes[i]:
                continue
            return self.__bytes[i] > other.__bytes[i]
        return False

    fn __le__(self, other: UUID) -> Bool:
        for i in range(16):
            if self.__bytes[i] == other.__bytes[i]:
                continue
            return self.__bytes[i] <= other.__bytes[i]
        return True

    fn __ge__(self, other: UUID) -> Bool:
        for i in range(16):
            if self.__bytes[i] == other.__bytes[i]:
                continue
            return self.__bytes[i] >= other.__bytes[i]
        return True

    fn __str__(self) -> String:
        let hex = self.bytes().hex()
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
        var output = bytes_()

        for i in range(16):
            try:
                output += to_bytes(self.__bytes[i].to_int())
            except:
                # cannot be over the limit
                pass

        return output

    fn time_low(self) -> Int:
        return uint8_simd_to_int(self.__bytes.slice[4](0))

    fn time_mid(self) -> Int:
        return uint8_simd_to_int(self.__bytes.slice[2](4))

    fn time_hi_version(self) -> Int:
        return uint8_simd_to_int(self.__bytes.slice[2](6))

    fn clock_seq_hi_variant(self) -> Int:
        return uint8_simd_to_int(self.__bytes.slice[1](8))

    fn clock_seq_low(self) -> Int:
        return uint8_simd_to_int(self.__bytes.slice[1](9))

    fn node(self) -> Int:
        return uint8_simd_to_int(self.__bytes.slice[6](10))

    fn urn(self) -> String:
        return "urn:uuid:" + str(self)

    fn variant(self) -> String:
        if not (self.__bytes[8] & 0x80).to_int():
            return RESERVED_NCS
        elif not (self.__bytes[8] & 0x40).to_int():
            return RFC_4122
        elif not (self.__bytes[8] & 0x20).to_int():
            return RESERVED_MICROSOFT
        else:
            return RESERVED_FUTURE

    fn version(self) -> Int:
        # The version bits are only meaningful for RFC 4122 UUIDs.
        if self.variant() == RFC_4122:
            return (self.__bytes[6] >> 4).to_int()
        else:
            # we should actually return None here but we don't have traits/unions
            return -1


# The following standard UUIDs are for use with uuid3() or uuid5().

alias NAMESPACE_DNS = UUID("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
alias NAMESPACE_URL = UUID("6ba7b811-9dad-11d1-80b4-00c04fd430c8")
alias NAMESPACE_OID = UUID("6ba7b812-9dad-11d1-80b4-00c04fd430c8")
alias NAMESPACE_X500 = UUID("6ba7b814-9dad-11d1-80b4-00c04fd430c8")
