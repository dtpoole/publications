class CreatePrograms < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
       t.column :program_number, :integer, :null => false
       t.column :program_abbrev, :string
       t.column :program_title, :string 
       t.column :program_category, :string 
       t.column :start_date, :date
       t.column :end_date, :date
    end
  end

  def self.down
    drop_table :programs
  end
end

