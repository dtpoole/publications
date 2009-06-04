class AddDateToAbstracts < ActiveRecord::Migration
  def self.up
    add_column :abstracts, "date", :string
  end

  def self.down
    remove_column :abstracts, "date", :string
  end
end
