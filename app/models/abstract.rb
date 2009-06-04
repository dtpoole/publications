class Abstract < ActiveRecord::Base
  has_many :investigator_abstracts, :dependent => :destroy
  has_many :investigators, :through => :investigator_abstracts
  
  named_scope :containing, lambda { |term|
    { :conditions => ["lower(abstract) like :term OR lower(abstracts.title) like :term OR lower(journal) 
        like :term OR lower(authors) like :term",
      {:term => "%#{term.to_s.downcase}%"}],
      :include => [:investigator_abstracts, :investigators],
      :order => "year DESC, publication_date DESC" } 
  }

  named_scope :abstract, lambda { |term|
    {:conditions => ['lower(abstract) like :term', 
      {:term => "%#{term.to_s.downcase}%"}],
      :include => [:investigator_abstracts, :investigators],
      :order => "year DESC, publication_date DESC" } 
  }

  named_scope :author, lambda { |term|
    {:conditions => ['(lower(full_authors) like :term) OR (lower(authors) like :term)', 
      {:term => "%#{term.to_s.downcase}%"}],
      :include => [:investigator_abstracts, :investigators],
      :order => "year DESC, publication_date DESC" } 
  }  

  named_scope :title, lambda { |term|
    {:conditions => ['lower(abstracts.title) like :term', 
      {:term => "%#{term.to_s.downcase}%"}],
      :include => [:investigator_abstracts, :investigators],
      :order => "year DESC, publication_date DESC" } 
  }

  named_scope :journal, lambda { |term|
    {:conditions => ['lower(journal) like :term OR lower(journal_abbreviation) like :term', 
      {:term => "%#{term.to_s.downcase}%"}],
      :include => [:investigator_abstracts, :investigators],
      :order => "year DESC, publication_date DESC" } 
  }  

  named_scope :program, lambda { |program_id| 
    investigators = Program.find(program_id).investigators
    {:conditions => ['investigator_abstracts.investigator_id IN (?)', investigators],
      :include => [:investigator_abstracts, :investigators],
      :order => "year DESC, publication_date DESC" }
  }
  
  named_scope :programs, lambda { |programs| 
    investigators = Program.find(program_id).investigators
    {:conditions => ['investigator_abstracts.investigator_id IN (?)', investigators],
      :include => [:investigator_abstracts, :investigators],
      :order => "year DESC, publication_date DESC" }
  }
  
    
  named_scope :member, lambda { |member_id| 
    { :conditions => ['investigator_abstracts.investigator_id = ?', member_id], 
      :include => [:investigator_abstracts, :investigators],
      :order => "year DESC, publication_date DESC" }
  }  
  
  named_scope :years, lambda { |starting, ending| 
    { :conditions => ['year BETWEEN ? AND ?', starting, ending],
      :include => [:investigator_abstracts, :investigators],
      :order => "year DESC, publication_date DESC" }
  }
  
  
  named_scope :investigators2, lambda { |investigators| 
    { :conditions => ['investigator_abstracts.investigator_id IN (:investigators)',
      { :investigators => investigators}], 
      :include => [:investigator_abstracts, :investigators],
      :order => "year DESC, publication_date DESC" }
  }
  
  # TODO: Fix/Replace
  def associated_with?(investigator = Investigator.new)
    investigators.each do |existing_investigator|
      if investigator.id == existing_investigator.id
        return true
      end
    end
    false
  end
  
  # TODO: Fix/Replace  
  def self.investigator_publications( investigators, start_year = nil, end_year = nil)
    if start_year and end_year
      find(:all,
       :include => [:investigators, :investigator_abstracts],
       :conditions => [ 'investigator_abstracts.investigator_id IN (:investigators) and year BETWEEN :start_year AND :end_year',
        {:end_year => end_year, :start_year => start_year, :investigators => investigators }])
    else
      find(:all,
      :include => [:investigators, :investigator_abstracts],
      :conditions => ['investigator_abstracts.investigator_id IN (:investigators)', {:investigators => investigators }])
    end
  end
end
