from .._utils import custom_debug_assert


fn list_to_str(input_list: List[String]) -> String:
    var result: String = "["
    for i in range(len(input_list)):
        var repr = "'" + str(input_list[i]) + "'"
        if i != len(input_list) - 1:
            result += repr + ", "
        else:
            result += repr
    return result + "]"


fn list_to_str(input_list: List[Int]) -> String:
    var result: String = "["
    for i in range(len(input_list)):
        var repr = str(input_list[i])
        if i != len(input_list) - 1:
            result += repr + ", "
        else:
            result += repr
    return result + "]"


fn _cmp_list(a: List[Int], b: List[Int]) -> Int:
    for i in range(len(a)):
        if i >= len(b):
            return 1

        if a[i] < b[i]:
            return -1
        elif a[i] == b[i]:
            continue
        else:
            return 1

    if len(a) < len(b):
        return -1
    else:
        return 0
