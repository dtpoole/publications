class AddSecondaryAuthors < ActiveRecord::Migration
  def self.up
     add_column :abstracts, "secondary_authors", :string
     add_column :abstracts, "secondary_title", :string
  end

  def self.down
     remove_column :abstracts, "secondary_authors"
     remove_column :abstracts, "secondary_title"
  end
end
