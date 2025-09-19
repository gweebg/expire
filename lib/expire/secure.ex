defmodule Expire.Secure do
  # 64KB chunks
  @chunk_size 64 * 1024

  def derive_key(password, salt) do
    # 32 bytes for AES-256
    :crypto.pbkdf2_hmac(:sha256, password, salt, 100_000, 32)
  end

  def encrypt_content(plaintext, password) do
    salt = :crypto.strong_rand_bytes(16)
    key = derive_key(password, salt)
    iv = :crypto.strong_rand_bytes(12)

    {ciphertext, tag} =
      :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, plaintext, "", true)

    %{ciphertext: ciphertext, iv: iv, tag: tag, salt: salt}
  end

  def decrypt_content(%{ciphertext: c, iv: iv, tag: tag, salt: salt}, password) do
    key = derive_key(password, salt)
    :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, c, "", tag, false)
  end

  def encrypt_file_chunked_gcm(input_path, output_path, password) do
    salt = :crypto.strong_rand_bytes(16)
    key = derive_key(password, salt)

    # Write salt as header
    File.write!(output_path, <<byte_size(salt)::32, salt::binary>>)

    input_path
    |> File.stream!(@chunk_size, [])
    |> Stream.with_index()
    |> Stream.map(fn {chunk, index} ->
      # Use index as part of IV to ensure uniqueness
      iv = :crypto.hash(:sha256, <<salt::binary, index::64>>) |> binary_part(0, 12)

      {ciphertext, tag} = :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, chunk, "", true)

      # Format: chunk_size(4) + iv(12) + tag(16) + ciphertext
      chunk_size = byte_size(ciphertext)
      <<chunk_size::32, iv::binary, tag::binary, ciphertext::binary>>
    end)
    |> Stream.into(File.stream!(output_path, [:append]))
    |> Stream.run()

    :ok
  end

  def decrypt_file_chunked_gcm(input_path, output_path, password) do
    # Read salt from the beginning of the file
    data = File.read!(input_path)
    <<_salt_size::32, salt::binary-size(16), rest::binary>> = data
    key = derive_key(password, salt)

    # Create empty output file
    File.write!(output_path, "")

    # Process remaining data in chunks
    decrypt_chunked_data(rest, key, output_path, 0)
  end

  defp decrypt_chunked_data(<<>>, _key, _output_path, _index), do: :ok

  defp decrypt_chunked_data(data, key, output_path, index) when byte_size(data) >= 32 do
    <<chunk_size::32, iv::12-binary, tag::16-binary, ciphertext::binary-size(chunk_size),
      rest::binary>> = data

    case :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, ciphertext, "", tag, false) do
      plaintext when is_binary(plaintext) ->
        File.write!(output_path, plaintext, [:append])
        decrypt_chunked_data(rest, key, output_path, index + 1)

      :error ->
        {:error, :decryption_failed}
    end
  end

  defp decrypt_chunked_data(_incomplete_data, _key, _output_path, _index) do
    {:error, :incomplete_chunk}
  end
end
