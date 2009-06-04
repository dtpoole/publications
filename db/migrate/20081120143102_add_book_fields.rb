class AddBookFields < ActiveRecord::Migration
  def self.up
     add_column :abstracts, "pub_location", :string
     add_column :abstracts, "publisher", :string
  end

  def self.down
    remove_column :abstracts, "pub_location"
    remove_column :abstracts, "publisher"
  end
end
