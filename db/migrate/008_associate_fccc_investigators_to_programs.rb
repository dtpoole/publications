class AssociateFcccInvestigatorsToPrograms < ActiveRecord::Migration
  def self.up
      
    research = Hash.new
    
    # Basic Science
    research["Biomolecular Structure and Function"] = %w( user1 )

      
    research.each do |program_title, investigators|
      
      program = Program.find(:first, :conditions => ['program_title = ?', program_title], :select => "id")
      
      investigators.each do |username|  
        
        pi = Investigator.find_by_username(username, :select => "id")
      
        InvestigatorProgram.create(
          :program_id => program.id, 
          :investigator_id => pi.id, 
          :program_appointment => 'member', 
          :start_date => '01-SEP-2007'
        )
        
      end
    end
    
  end

  def self.down
    InvestigatorProgram.delete_all
  end
end
