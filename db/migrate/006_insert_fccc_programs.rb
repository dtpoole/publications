class InsertFcccPrograms < ActiveRecord::Migration
  def self.up
    
    research = Hash.new
    
    research["Basic Science"] = Array.new    
    research["Basic Science"] << "Biomolecular Structure and Function"
    research["Basic Science"] << "Celluar and Developmental Biology"
    research["Basic Science"] << "Immunobiology"
    research["Basic Science"] << "Tumor Cell Biology"
    research["Basic Science"] << "Viral Pathogenesis"

    research["Medical Science"] = Array.new
    research["Medical Science"] << "Ovarian Cancer Program"
    research["Medical Science"] << "Hormone-Dependent Research"
    research["Medical Science"] << "Medical Oncology"
    research["Medical Science"] << "Nursing Research"
    research["Medical Science"] << "Pathology"
    research["Medical Science"] << "Therapeutic Radiology"
    research["Medical Science"] << "Surgical Oncology"
    
    research["Population Science"] = Array.new
    research["Population Science"] << "Cancer Prevention and Control - Behavioral Research"
    research["Population Science"] << "Cancer Prevention and Control - Cancer Risk Assessment"
    research["Population Science"] << "Cancer Prevention and Control - Chemoprevention"
    research["Population Science"] << "Epidemiology and Human Disease"   
    research["Population Science"] << "Human Genetics"
    research["Population Science"] << "Biomathematics and Biostatistics"
    
    count = 1

    research.each do |category, programs|
      programs.each do |program| 
        Program.create(
          :program_number => count, 
          :program_abbrev => "",   
          :program_title => program, 
          :program_category => category, 
          :start_date => "01-SEP-2007"
        )
        count += 1
      end
    end
    
  end

  def self.down
    Program.delete_all
  end
end
