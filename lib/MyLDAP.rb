require 'ldap'

class MyLDAP
  
  @config = nil
  @connection = nil
  
  def initialize(config, authenticate_only = false)
    @config = config  
    self.connect unless authenticate_only
  end
      
  
  def person_exists?(username)
    self.person_get_attribute(username, 'uid') ? true : false
  end
  
  
  def person_terminated?(username)
    self.person_get_attribute(username, 'employeetype') == "terminated" ? true : false
	end


	def get_person(username)
		
		return nil unless @connection
		
		person = Hash.new
    		
		begin
		  		  
		  if @connection.bound?
  			result = @connection.search2(@config[:people_base], LDAP::LDAP_SCOPE_ONELEVEL, "(uid=#{username})", nil )
  		  
  		  if result.size == 1
  		    entry = result.first
  			  # downcase attribute names and convert to string value if attribute has a single value
  			  entry.each do |attribute,value|			 
  			    if entry[attribute].length == 1
  			      person[attribute.downcase] = entry[attribute].to_s
  			    else
  			      person[attribute.downcase] = entry[attribute]
  			    end
  			  end
  		  end
  			
  			return person.empty? ? nil : person
  	
  		end	
	  
	  rescue Exception => ex
	    raise
	  end
			
		nil
			
	end
	
	
	def person_get_attribute(username, attribute)
	  
	  return nil unless @connection
    	  
		begin

	    if @connection.bound?
	      
  			result = @connection.search2(@config[:people_base], LDAP::LDAP_SCOPE_ONELEVEL, "(uid=#{username})", [attribute])
  			
  			if result.size == 1
  			  entry = result.first
  			  
  			  if entry[attribute]
  			    # convert to attribute value to string if attribute has a single value
  			    unless entry[attribute].empty?
  			      return entry[attribute].length == 1 ? entry[attribute].to_s : entry[attribute]
  			    end
  			  end 
  			end
  		end	

	  rescue Exception => ex
	    raise
	  end
	  
	  nil
	  
	end
	

  def authenticate(username, password)

    # for some reason LDAP successfully bounds if password is blank
    return false if password.blank?
      
    begin
		
		  conn = LDAP::Conn.new( @config[:host] || 'localhost', @config[:port] || LDAP::LDAP_PORT )	
  		
  		if conn.bind( "uid=#{username}," + @config[:people_base], password )
  		  return true
  		end
  		  		
    rescue LDAP::ResultError => ex
        false
    ensure
      conn.unbind unless conn == nil
      conn = nil
    end

    false

  end
  
  
  def connected?
	  @connection.nil? ? false : true
	end
  
  
  def disconnect
    @connection.unbind unless @connection == nil
    @connection = nil
  end
  
  
  
  protected
  
   
   def connect
     
     begin	
      
   	  if @config[:ssl]
   	    @connection = LDAP::SSLConn.new( @config[:host] || 'localhost', @config[:port] || LDAP::LDAPS_PORT, true )
   	  else
   	    @connection = LDAP::Conn.new( @config[:host] || 'localhost', @config[:port] || LDAP::LDAP_PORT )
   	  end

      @connection.set_option( LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 )
      @connection.bind( @config[:bind_dn] || '', @config[:bind_password] || '' )
 	
      @connection.bound? ? true : false
      
    rescue LDAP::ResultError => ex
      raise
    
    rescue Exception => ex
     	raise
    end
    
  end
  
end

