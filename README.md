# RRule

RRule is a wrapper around the Rust based library [rrule](https://github.com/fmeringdal/rust-rrule).

To consume it in your projects, you'll need to have a Rust compiler [installed](https://www.rust-lang.org/en-US/install.html).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rrule` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rrule, "~> 0.1.0"}
  ]
end
```

## Release Process

1. Make the sure correct version of rust_rrule is being referenced. See `native/rrule/Cargo.toml` for more details.

2. Update the mix version `mix.exs`

3. Commit change and tag version

    ```bash
    git commit -m "updated version"
    git tag 0.15.4
    git push --tags
    ```

4. Get updated checksums

    Wait for github build action to complete

    ```bash
    mix compile # seems to be needed to update the version number ??
    mix rustler_precompiled.download RRule --all --no-config

    # verify test, add any to verify the update
    mix test
    ```

5. Publish to hex

```bash
mix hex.publish
```
