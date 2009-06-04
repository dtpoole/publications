# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_publications_session',
  :secret      => '68fb483398b49ebb8385d8348097e5a8b1c7d9cf84dad2eb6d347b59669641ffd95aceaeb3c07d517118b1560bc52b88d2f227284c6a1b52693fe37fa8fbbdb0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
