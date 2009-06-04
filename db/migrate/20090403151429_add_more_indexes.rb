class AddMoreIndexes < ActiveRecord::Migration
  def self.up
     add_index :abstracts, :year, :name => :idx_year
     add_index :abstracts, :updated_at, :name => :idx_updated_at
     add_index :investigators, :last_name, :name => :idx_last_name
     add_index :programs, :program_title, :name => :idx_program_title
     add_index :programs, :program_number, :name => :idx_program_number
  end

  def self.down
    remove_index :abstracts, :name => :idx_year
    remove_index :abstracts, :name => :idx_updated_at
    remove_index :investigators, :name => :idx_last_name
    remove_index :programs, :name => :idx_program_title
    remove_index :programs, :name => :idx_program_number
  end
end
