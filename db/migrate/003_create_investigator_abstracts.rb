class CreateInvestigatorAbstracts < ActiveRecord::Migration
  def self.up
    create_table :investigator_abstracts do |t|
      t.column :abstract_id, :integer, :null => false
      t.column :investigator_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :investigator_abstracts
  end
end
