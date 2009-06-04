class InvestigatorProgram < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :program
  has_many :investigator_abstracts, :through => :investigator
  
  validates_uniqueness_of :investigator_id, :scope => "program_id"
end
