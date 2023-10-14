set -ex

cp ./dist/stdlib_extensions.mojopkg /tmp/stdlib_extensions.mojopkg
cd /tmp

cat <<EOF > /tmp/test_import.mojo
from stdlib_extensions.builtins.string import endswith

def main():
    print(endswith("hello world", "world"))
    print("Success!")
EOF

mojo /tmp/test_import.mojo

mojo build /tmp/test_import.mojo

./test_import
