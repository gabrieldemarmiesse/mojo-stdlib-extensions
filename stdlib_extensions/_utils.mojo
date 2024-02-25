fn custom_debug_assert(condition: Bool, message: String):
    if not condition:
        print(message)
        print(
            "Should crash now, if the crash did not happen, you should enable the"
            " assertions with -D MOJO_ENABLE_ASSERTIONS"
        )
        debug_assert(condition, "Custom debug assert failed")


fn custom_debug_assert(message: String):
    print(message)
    print(
        "Should crash now, if the crash did not happen, you should enable the"
        " assertions with -D MOJO_ENABLE_ASSERTIONS"
    )
    debug_assert(False, "Custom debug assert failed")
