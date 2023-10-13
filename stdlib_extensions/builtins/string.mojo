from stdlib_extensions.builtins import list


fn __string__mul__(input_string: String, n: Int) -> String:
    var result: String = ""
    for _ in range(n):
        result += input_string
    return result


fn rjust(input_string: String, width: Int, fillchar: String = " ") raises -> String:
    if len(fillchar) != 1:
        raise Error(" The fill character must be exactly one character long")
    let extra = width - len(input_string)
    return __string__mul__(fillchar, extra) + input_string


fn ljust(input_string: String, width: Int, fillchar: String = " ") raises -> String:
    if len(fillchar) != 1:
        raise Error(" The fill character must be exactly one character long")
    let extra = width - len(input_string)
    return input_string + __string__mul__(fillchar, extra)


fn endswith(
    input_string: String, suffix: String, start: Int = 0, owned end: Int = -1
) raises -> Bool:
    if end == -1:
        end = len(input_string)

    if end < start:
        raise Error("The end index must be greater than or equal to the start index")

    if end - start < len(suffix):
        return False

    return input_string[end - len(suffix) : end] == suffix


fn split(
    input_string: String, sep: String = " ", owned maxsplit: Int = -1
) raises -> list[String]:
    """The separator can be multiple characters long."""
    var result = list[String]()
    if maxsplit == 0:
        result.append(input_string)
        return result
    if maxsplit < 0:
        maxsplit = len(input_string)

    if not sep:
        return list[String](input_string)[0:maxsplit]

    var output = list[String]()
    var start = 0
    var split_count = 0

    for end in range(len(input_string) - len(sep) + 1):
        if input_string[end : end + len(sep)] == sep:
            output.append(input_string[start:end])
            start = end + len(sep)
            split_count += 1

            if maxsplit > 0 and split_count >= maxsplit:
                break

    output.append(input_string[start:])
    return output
