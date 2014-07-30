# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.

# Although this is not needed for an api-only application, rails4 
# requires secret_key_base or secret_token to be defined, otherwise an 
# error is raised.
ContentStore::Application.config.secret_key_base = '17d18dc5ad73cad8c4dac0eb0e151ae8232b38ab9a388bd8078dc02a2966e8198be71ef0e08dc3d8a4eec81c72c3ae64f5d41dd3ecdefca9c30ad3c51a1c35b1'
