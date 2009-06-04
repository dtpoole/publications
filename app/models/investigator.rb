class Investigator < ActiveRecord::Base
    has_many :investigator_abstracts, :dependent => :destroy
    has_many :abstracts, :through => :investigator_abstracts
    has_many :investigator_programs, :dependent => :destroy
    has_many :programs, :through => :investigator_programs, :source => :program do
      def program_members(program_id) 
        find :all, 
          :include => ["programs","investigator_programs"],
          :conditions => ['programs.id = :program_id  and investigator_programs.end_date is null or investigator_programs.end_date >= :now', 
             {:now => Date.today, :program_id => program_id }] 
      end 
    end

    has_many :current_programs, 
      :through => :investigator_programs, 
      :source => :program, 
      :conditions => ['investigator_programs.end_date is null or investigator_programs.end_date >= :now', {:now => Date.today }]

    validates_uniqueness_of :username
    validates_presence_of :first_name, :last_name
    
    
    
    named_scope :collaborators, lambda { |investigator|
      # get program ids for investigator 
      programs = InvestigatorProgram.find(:all, 
        :conditions => ['investigator_id = :id', {:id => investigator.id}],
        :select => "distinct(program_id) as program_id").collect(&:program_id)

      {:conditions => [" investigator_programs.program_id IN (:programs)", 
        {:programs => programs}],
        :include => [:investigator_programs] }
    }
    
    
    named_scope :username, lambda { |term|
      {:conditions => ['username = :term', {:term => "#{term}"}]}
    }
  

    def self.add_collaboration(collaborator,investigator_abstract)
      collaborator[investigator_abstract.investigator_id.to_s]=Array.new(0) if collaborator[investigator_abstract.investigator_id.to_s].nil?
      has_abstract = collaborator[investigator_abstract.investigator_id.to_s].find { |i| i == investigator_abstract.abstract_id }
      if has_abstract.blank?
         collaborator[investigator_abstract.investigator_id.to_s][collaborator[investigator_abstract.investigator_id.to_s].length]=investigator_abstract.abstract_id
      end
    end

    def self.add_collaboration_to_investigator(investigator_abstract, investigator, intra_program_investigators)
      if investigator.id.to_i != investigator_abstract.investigator_id.to_i
        internal_investigator = intra_program_investigators.find { |i| i.id == investigator_abstract.investigator_id }
        if internal_investigator.nil? 
          add_collaboration(investigator.external_collaborators,investigator_abstract )
        else 
          add_collaboration(investigator.internal_collaborators,investigator_abstract )
        end
      end
    end

    def self.add_collaborations_to_investigator(investigator_abstracts, investigator, intra_program_investigators ) 
      investigator_abstracts.each do |ia|
        add_collaboration_to_investigator(ia,investigator, intra_program_investigators)
      end 
    end 

    def self.add_collaboration_hash_to_investigator(investigator ) 
      if investigator["internal_collaborators"].nil?
        investigator["internal_collaborators"]=Hash.new()
        investigator["external_collaborators"]=Hash.new()
      end
    end 

    def self.add_collaboration_hash_to_investigators(investigators )
      investigators.each do |investigator|
        add_collaboration_hash_to_investigator(investigator)
      end
    end 

    def self.add_collaborations_to_investigators(investigator_abstracts, input_investigators ) 
      investigator_abstracts.each do |ia|
        investigator = input_investigators.find { |i| i.id == ia.investigator_id }
        if !investigator.nil?
          add_collaborations_to_investigator(investigator_abstracts, investigator, input_investigators)
        end
      end
    end 

    def self.get_connections(investigators, start_year = nil, end_year = nil)
      add_collaboration_hash_to_investigators(investigators)
      
      if start_year
 #       program_publications = Abstract.investigators(investigators).years(start_year, end_year)
        program_publications = Abstract.investigator_publications(investigators, start_year, end_year)
      else
        #program_publications = Abstract.investigators2(investigators)
        program_publications = Abstract.investigator_publications(investigators, start_year, end_year)
      end
      
      #iterate over all publications
      program_publications.each do |pub|
        if pub.investigator_abstracts.length > 1
          add_collaborations_to_investigators(pub.investigator_abstracts, investigators)
        end
      end
    end



    def self.get_investigator_connections(investigator, start_year = nil, end_year = nil)
      intra_program_investigators = Investigator.find(:all, 
          :include => ["abstracts","investigator_programs"],
          :conditions => [" investigator_programs.program_id IN (:program_ids)",
           {:program_ids => investigator.investigator_programs.collect(&:program_id).uniq}] )
      add_collaboration_hash_to_investigator(investigator)
      program_publications = Abstract.investigator_publications(investigator, start_year, end_year)
       #iterate over all publications
      program_publications.each do |pub|
        if pub.investigator_abstracts.length > 1
          add_collaborations_to_investigator(pub.investigator_abstracts, investigator, intra_program_investigators)
        end
      end
    end





    def self.get_investigator_connections_new(investigator, start_year = nil, end_year = nil)
      
      
      
      
 #     intra_program_investigators = Investigator.find(:all, 
 #         :include => ["abstracts","investigator_programs"],
#          :conditions => [" investigator_programs.program_id IN (:program_ids)",
#           {:program_ids => investigator.investigator_programs.collect(&:program_id).uniq}] )
           
#
Abstract.program

      intra_program_investigators = Investigator.collaborators(investigator)
           
      
           
           
      add_collaboration_hash_to_investigator(investigator)

       program_publications = Abstract.investigator_publications(investigator, start_year, end_year)
#      if start_year && end_year
#        program_publications = Abstract.investigators(investigator).years(start_year, end_year)
#      else
#        program_publications = Abstract.investigators(investigator)
#      end


       #iterate over all publications
      program_publications.each do |pub|
        
        if pub.investigator_abstracts.length > 1
        
          add_collaborations_to_investigator(pub.investigator_abstracts, investigator, intra_program_investigators)
        end
      end
    end

    def fullname(reverse = false)
      self.middle_name.blank? ? name = self.first_name : name = self.first_name + (' ') + self.middle_name + '.' 
      reverse ? self.last_name + ', ' + name : name + ' ' + self.last_name
    end
end
