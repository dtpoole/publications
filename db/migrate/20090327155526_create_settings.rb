class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
        t.integer :start_year, :null => false
        t.integer :end_year, :null => false
        t.date :last_update, :null => false
    end
    
    u = Abstract.find(:first, :order => "updated_at DESC", :select => 'updated_at').updated_at
    s = Abstract.find_by_sql('select min(year) as year from abstracts;').first.year
    e = Abstract.find_by_sql('select max(year) as year from abstracts;').first.year
    
    setting = Setting.new
    setting.start_year = s
    setting.end_year = e
    setting.last_update = u
    setting.save!
  end

  def self.down
    drop_table :settings
  end
end
