# Cuid2Ex

Cuid2Ex is an Elixir implementation of the CUID2 (Collision-resistant Unique IDentifier) algorithm. It generates secure, collision-resistant IDs optimized for horizontal scaling and performance. The generated IDs are URL-safe, contain no special characters, and have a configurable fixed length.

## Features

- Secure, collision-resistant ID generation
- URL-safe output with no special characters
- Configurable ID length (default: 24 characters)
- Customizable random number generator and counter
- Input validation
- Zero dependencies (besides Erlang/OTP crypto)

## Installation

Add `cuid2_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cuid2_ex, "~> 0.1.0"}
  ]
end
```

## Usage

### Basic Usage

Generate a CUID2 with default settings (24 characters):

```elixir
Cuid2Ex.create()
# => "k0xpkry4lx8tl3qh8vry0f6m"
```

### Custom Length

Generate a longer CUID2 (32 characters):

```elixir
Cuid2Ex.create(length: 32)
# => "k0xpkry4lx8tl3qh8vry0f6maabc1234"
```

### Create a Generator

For better performance when generating multiple IDs, create a generator function:

```elixir
generator = Cuid2Ex.init(length: 24)
generator.()
# => "k0xpkry4lx8tl3qh8vry0f6m"
```

### Validation

Validate if a string is a valid CUID2:

```elixir
Cuid2Ex.cuid?("k0xpkry4lx8tl3qh8vry0f6m")
# => true

Cuid2Ex.cuid?("invalid!")
# => false
```

## Configuration Options

The `init/1` and `create/1` functions accept the following options:

- `:length` - Length of generated IDs (default: 24)
- `:random` - Custom random number generator function
- `:counter` - Custom counter function
- `:fingerprint` - Custom fingerprint string
