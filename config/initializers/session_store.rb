# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_hondana2_session',
  :secret      => 'd3139192725b971d6f11e3e42917a0328b7eeb65fdc4094bbb118c7cc1c1a89fe8267869228676f594ae87fa46d945fe3ac4d346b84666d3d3434c6fa0034f0a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
