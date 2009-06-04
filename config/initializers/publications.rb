# load application settings
begin
	CONFIG = YAML::load( File.open( "#{RAILS_ROOT}/config/publications.yml" ) )
rescue
	puts "Error: Unable to load configuration file (#{RAILS_ROOT}/config/publications.yml)."
	exit!
end

# check required libraries
begin
	require 'ldap'
rescue Exception => ex
	puts "ERROR: Unable to load LDAP library."
	exit!
end

# check LDAP configuration
begin	  
  require 'MyLDAP'
  ldap = MyLDAP.new(CONFIG[:ldap])
  ldap.disconnect
rescue Exception => ex
	puts "ERROR: #{ex}" 
	exit!
end


# setup ExceptionNotifier
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.perform_deliveries = true

ActionMailer::Base.smtp_settings = {
   :address  => 'mail.host.com',
   :port     => 25,
   :domain   => 'host.com'
}

ExceptionNotifier.exception_recipients = %w(publications@host.com)
ExceptionNotifier.email_prefix = "[publications] "