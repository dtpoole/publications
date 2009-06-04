class InsertFcccInvestigators < ActiveRecord::Migration
  def self.up
    
    # Basic Science
    
    # Biomolecular Structure and Function
    investigators = %w( user1 )
  
    
    investigators.uniq!
     
    begin
      
      ldap = MyLDAP.new(CONFIG[:ldap])
    
      investigators.each do |username|
        if investigator = ldap.get_person(username)
            Investigator.create(
              :username => username, 
              :last_name => investigator["sn"], 
              :first_name => investigator["givenname"],
              :middle_name => investigator["initials"] ? investigator["initials"][/./] : '',
              :email => investigator["mail"].class.to_s == "Array" ? investigator["mail"].first : investigator["mail"]
            ) 
        else
          puts "#{username} was not found in LDAP."
        end
      end
      
		rescue Exception => ex
		  raise
		end
    
  end

  def self.down
    Investigator.delete_all
  end
end
