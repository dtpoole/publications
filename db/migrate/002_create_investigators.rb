class CreateInvestigators < ActiveRecord::Migration
  def self.up
    create_table :investigators do |t|
      t.column :username, :string, :null => false
      t.column :last_name, :string, :null => false
      t.column :first_name, :string, :null => false
      t.column :middle_name, :string
      t.column :pubmed_search_name, :string 
      t.column :pubmed_limit_to_institution, :boolean, :default => false 
      t.column :last_pubmed_search, :date
      t.column :title, :string 
      t.column :mailcode, :string 
      t.column :address1, :text 
      t.column :address2, :string 
      t.column :city, :string 
      t.column :state, :string 
      t.column :postal_code, :string 
      t.column :country, :string 
      t.column :business_phone, :string 
      t.column :home_phone, :string 
      t.column :lab_phone, :string 
      t.column :fax, :string 
      t.column :pager, :string 
      t.column :email, :string 
      t.column :ssn, :string, :limit => 9
      t.column :sex, :string, :limit => 1
      t.column :birth_date, :date 
      t.column :nu_start_date, :date 
      t.column :nu_employee_id, :integer 
      t.column :start_date, :date 
      t.column :end_date, :date 
      t.column :weekly_hours_min, :integer, :default => 35
      t.column :last_successful_login, :timestamp
      t.column :last_login_failure, :timestamp
      t.column :consecutive_login_failures, :integer, :default => 0
      t.column :password, :string
      t.column :password_changed_at, :timestamp
      t.column :password_changed_id, :integer  
      t.column :password_changed_ip, :string
      t.column :created_at, :timestamp, :default => Time.now
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
    drop_table :investigators
  end
end
