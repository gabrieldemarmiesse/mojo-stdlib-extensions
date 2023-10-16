from ...pathlib import Path
from ..utils import assert_equal


def test_read_and_write_from_file():
    # TODO: change this when we can create directories
    # TemporaryDirectory() would be very helpful to ensure cleanup
    tmp_dir = Path("/tmp/")
    tmp_file = tmp_dir / "test_file.txt"
    assert_equal(tmp_file.__fspath__(), "/tmp/test_file.txt")
    tmp_file.write_text("Hello mojo 🔥")
    assert_equal(tmp_file.read_text(), "Hello mojo 🔥")
    tmp_file.unlink()


def run_tests():
    test_read_and_write_from_file()
