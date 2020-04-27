defmodule SimpWeb.Live.AuthHelper do
  def get_credentials(socket, signed_token) do
    conn = %Plug.Conn{secret_key_base: socket.endpoint.config(:secret_key_base)}
    store_config = [backend: Pow.Store.Backend.EtsCache]
    salt = Atom.to_string(Pow.Plug.Session)

    with {:ok, token} <- Pow.Plug.verify_token(conn, salt, signed_token, otp_app: :simp),
         {user, _metadata} <- Pow.Store.CredentialsCache.get(store_config, token) do
      user
    else
      _ -> nil
    end
  end
end
