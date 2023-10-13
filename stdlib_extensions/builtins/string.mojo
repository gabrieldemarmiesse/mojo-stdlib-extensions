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


fn endswith(input_string: String, suffix: String, start: Int = 0, end: Int = -1) raises -> Bool:
    var new_end = end
    if end == -1:
        new_end = len(input_string)

    if new_end < start:
        raise Error("The end index must be greater than or equal to the start index")

    if new_end - start < len(suffix):
        return False

    return input_string[new_end - len(suffix):new_end] == suffix

