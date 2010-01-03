# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_geopinion_session',
  :secret      => '028c1e4f4fd7c41c1c9ed46c74f52170c7812d13d96eacaf90a60161da409126e3571355e669df4ca430c8d18559176710ea034a29949469c876c73402627b6e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
