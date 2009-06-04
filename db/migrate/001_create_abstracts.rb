class CreateAbstracts < ActiveRecord::Migration
  def self.up
    create_table :abstracts do |t|
      t.column :endnote_citation, :text
      t.column :abstract, :text
      t.column :authors, :text
      t.column :full_authors, :text
      t.column :title, :text 
      t.column :journal_abbreviation, :string 
      t.column :journal, :string 
      t.column :volume, :string 
      t.column :issue, :string 
      t.column :pages, :string 
      t.column :year, :string 
      t.column :publication_date, :date # DP: pubmed YYYY/MM/DD
      t.column :publication_type, :string # Journal Article, Book Chapter, etc
      t.column :electronic_publication_date, :date # DP: pubmed YYYY/MM/DD
      t.column :deposited_date, :date 
      t.column :status, :string 
      t.column :publication_status, :string 
      t.column :pubmed, :string, :unique => true 
      t.column :url, :string 
      t.column :mesh, :text 
      t.column :created_at, :timestamp
      t.column :created_id, :integer  
      t.column :created_ip, :string
      t.column :updated_at, :timestamp
      t.column :updated_id, :integer  
      t.column :updated_ip, :string
      t.column :deleted_at, :timestamp
      t.column :deleted_id, :integer  
      t.column :deleted_ip, :string
    end
  end

  def self.down
    drop_table :abstracts
  end
end
