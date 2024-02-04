from stdlib_extensions.builtins import list


alias _DAYS_IN_MONTH = list[Int].from_values(
    -1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
)

def run_each_module():
    a = _DAYS_IN_MONTH.__getitem__(0)


def main():
    run_each_module()
