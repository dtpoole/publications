class RemoveNonFcccColumns < ActiveRecord::Migration
  def self.up
  
    # Remove unnecessary columns from Investigators. 
    remove_column :investigators, :mailcode 
    remove_column :investigators, :address1
    remove_column :investigators, :address2
    remove_column :investigators, :city
    remove_column :investigators, :state
    remove_column :investigators, :postal_code
    remove_column :investigators, :country
    remove_column :investigators, :business_phone
    remove_column :investigators, :home_phone
    remove_column :investigators, :lab_phone
    remove_column :investigators, :fax
    remove_column :investigators, :pager
    remove_column :investigators, :ssn
    remove_column :investigators, :sex
    remove_column :investigators, :birth_date
    remove_column :investigators, :nu_start_date
    remove_column :investigators, :nu_employee_id
    #remove_column :investigators, :start_date
    #remove_column :investigators, :end_date
    remove_column :investigators, :weekly_hours_min
    remove_column :investigators, :last_successful_login
    remove_column :investigators, :last_login_failure
    remove_column :investigators, :consecutive_login_failures
    remove_column :investigators, :password
    remove_column :investigators, :password_changed_at
    remove_column :investigators, :password_changed_id
    remove_column :investigators, :password_changed_ip
  
  end

  def self.down
    
    add_column :investigators, :mailcode, :string 
    add_column :investigators, :address1, :text 
    add_column :investigators, :address2, :string 
    add_column :investigators, :city, :string 
    add_column :investigators, :state, :string 
    add_column :investigators, :postal_code, :string 
    add_column :investigators, :country, :string 
    add_column :investigators, :business_phone, :string 
    add_column :investigators, :home_phone, :string 
    add_column :investigators, :lab_phone, :string 
    add_column :investigators, :fax, :string 
    add_column :investigators, :pager, :string
    add_column :investigators, :ssn, :string, :limit => 9
    add_column :investigators, :sex, :string, :limit => 1
    add_column :investigators, :birth_date, :date 
    add_column :investigators, :nu_start_date, :date 
    add_column :investigators, :nu_employee_id, :integer 
    add_column :investigators, :weekly_hours_min, :integer, :default => 35
    add_column :investigators, :last_successful_login, :timestamp
    add_column :investigators, :last_login_failure, :timestamp
    add_column :investigators, :consecutive_login_failures, :integer, :default => 0
    add_column :investigators, :password, :string
    add_column :investigators, :password_changed_at, :timestamp
    add_column :investigators, :password_changed_id, :integer  
    add_column :investigators, :password_changed_ip, :string
    
  end
end
