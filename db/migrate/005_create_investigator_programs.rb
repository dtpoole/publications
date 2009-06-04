class CreateInvestigatorPrograms < ActiveRecord::Migration
  def self.up
    create_table :investigator_programs do |t|
      t.column :program_id, :integer, :null => false
      t.column :investigator_id, :integer, :null => false
      t.column :program_appointment, :string 
      t.column :start_date, :date
      t.column :end_date, :date
    end
  end

  def self.down
    drop_table :investigator_programs
  end
end

