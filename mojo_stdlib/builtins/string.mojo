

fn ljust(input_string: String, width: Int, fillchar: String = " ") raises -> String:
    if len(fillchar) != 1:
        raise Error(" The fill character must be exactly one character long")
    let extra = width - len(input_string)

    var result: String = ""
    for _ in range(extra):
        result += fillchar

    return result + input_string
        
