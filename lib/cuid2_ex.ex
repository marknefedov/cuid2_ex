defmodule Cuid2Ex do
  @moduledoc """
  Implementation of the CUID2 (Collision-resistant Unique IDentifier) algorithm.

  CUID2 generates secure, collision-resistant ids optimized for horizontal scaling and performance.
  The generated ids are URL-safe, contain no special characters, and have a fixed length.

  ## Example

      iex> Cuid2Ex.create()
      "k0xpkry4lx8tl3qh8vry0f6m"

      iex> generator = Cuid2Ex.init(length: 32)
      iex> generator.()
      "k0xpkry4lx8tl3qh8vry0f6maabc1234"
  """

  @default_length 24
  @big_length 32
  @alphabet Enum.map(97..122, &<<&1::utf8>>)
  @initial_count_max 476_782_367

  @doc """
  Creates entropy string of specified length.

  ## Parameters
    * `length` - The desired length of the entropy string (default: 4)
    * `random` - Function that returns random float between 0 and 1 (default: `:rand.uniform/0`)
    * `entropy` - Initial entropy string (default: "")
  """
  def create_entropy(length \\ 4, random \\ &:rand.uniform/0, entropy \\ "") do
    if entropy > length do
      entropy
    else
      entropy <> ((random.() * 36) |> trunc |> Integer.to_string(36))
    end
  end

  @doc """
  Converts a binary buffer to a big integer.
  """
  def buf_to_big_int(buf) do
    buf
    |> :binary.bin_to_list()
    |> Enum.reduce(0, &(Bitwise.bsl(&2, 8) + &1))
  end

  @doc """
  Computes SHA3-512 hash of input and returns it as a big integer.
  """
  def sha3_512(input) do
    :sha3_512
    |> :crypto.hash(input)
    |> buf_to_big_int()
  end

  @doc """
  Creates a hash of the input string using SHA3-512 and converts it to base36.
  """
  def hash(input \\ "") do
    input
    |> sha3_512()
    |> Integer.to_string(36)
    |> String.downcase()
    |> String.slice(1..-1//-1)
  end

  @doc """
  Creates a fingerprint for the CUID generator.
  """
  def create_fingerprint(random \\ :rand.uniform() / 0) do
    create_entropy(@big_length, random)
    |> hash()
    |> String.slice(0, @big_length)
  end

  @doc """
  Creates a counter function that increments from the given starting count.
  """
  def create_counter(count) do
    fn -> count + 1 end
  end

  @doc """
  Initializes a CUID generator function with the given options.

  ## Options
    * `:length` - Length of generated ids (default: 24)
    * `:random` - Custom random number generator function
    * `:counter` - Custom counter function
    * `:fingerprint` - Custom fingerprint string

  Returns a function that generates CUID2 strings when called.
  """
  def init(opts \\ []) do
    random = Keyword.get(opts, :random, &:rand.uniform/0)

    counter =
      Keyword.get_lazy(opts, :counter, fn ->
        create_counter(trunc(random.() * @initial_count_max))
      end)

    length = Keyword.get(opts, :length, @default_length)
    fingerprint = Keyword.get_lazy(opts, :fingerprint, fn -> create_fingerprint(random) end)

    fn ->
      first_letter = Enum.random(@alphabet)
      time = DateTime.utc_now() |> DateTime.to_unix() |> Integer.to_string(36)
      count = counter.() |> Integer.to_string(36)
      salt = create_entropy(length, random)
      hash_input = time <> salt <> count <> fingerprint
      (first_letter <> hash(hash_input)) |> String.slice(1, length)
    end
  end

  @doc """
  Creates a new CUID2 string with the given options.

  See `init/1` for available options.
  """
  def create(opts \\ []) do
    init(opts).()
  end

  @doc """
  Validates if a given string is a valid Cuid2Ex.

  ## Options
    * `:min_length` - Minimum allowed length (default: 2)
    * `:max_length` - Maximum allowed length (default: 32)

  ## Examples

      iex> Cuid2Ex.cuid?("k0xpkry4lx8tl3qh8vry0f6m")
      true

      iex> Cuid2Ex.cuid?("invalid!")
      false
  """
  def cuid?(id, opts \\ [])

  def cuid?(id, opts) when is_binary(id) do
    min_length = Keyword.get(opts, :min_length, 2)
    max_length = Keyword.get(opts, :max_length, @big_length)
    length = String.length(id)
    regex = ~r/^[0-9a-z]+$/

    min_length <= length and length <= max_length and Regex.match?(regex, id)
  end

  def cuid?(_, _), do: false
end
