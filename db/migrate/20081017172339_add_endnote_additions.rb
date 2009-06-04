class AddEndnoteAdditions < ActiveRecord::Migration
  def self.up
     add_column :abstracts, "endnote_id", :string
     add_column :abstracts, "accession", :string
  end

  def self.down
    remove_column :abstracts, "endnote_id"
    remove_column :abstracts, "accession"
  end
end
