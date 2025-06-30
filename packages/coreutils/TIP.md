# TODO

*Create a custom target for Rust ("port Rust" to our OS), and then send a PR to <https://github.com/uutils/platform-info/blob/main/src/platform/unix.rs> to add support for our OS*

For now we will hardcode uname -o value to "rovelos" in the code.
This is a temporary solution until we have a custom target for Rust.
BTW: OS name not decided yet, so we will use "rovelos" for now.

Remove `custom_uname_o` from `meta.toml` file, if you don't want to apply the patch that allows to change the output of `uname -o` command to "rovelos".
