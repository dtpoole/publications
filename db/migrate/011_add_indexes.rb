class AddIndexes < ActiveRecord::Migration
  def self.up
    
    # speeds up joins considerably.  specified name because defaults would be too long for Oracle.
    
    add_index :investigator_abstracts, :abstract_id, :name => :idx_ia_abstracts
    add_index :investigator_abstracts, :investigator_id, :name => :idx_ia_investigators
      
    add_index :investigator_programs, :program_id, :name => :idx_ip_program
    add_index :investigator_programs, :investigator_id, :name => :idx_ip_investigators
      
  end

  def self.down
    
    remove_index :investigator_abstracts, :name => :idx_ia_abstracts
    remove_index :investigator_abstracts, :name => :idx_ia_investigators
    
    remove_index :investigator_programs, :name => :idx_ip_program
    remove_index :investigator_programs, :name => :idx_ip_investigators
    
  end
end
