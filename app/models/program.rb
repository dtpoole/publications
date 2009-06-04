class Program < ActiveRecord::Base
  has_many :investigator_programs,
    :conditions => ['investigator_programs.end_date is null or investigator_programs.end_date >= :now', {:now => Date.today }],
    :dependent => :destroy
  has_many :investigators, :through => :investigator_programs
end
