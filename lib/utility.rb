# -*- ruby -*-

def BuildSearch(pi, full_first_name=true, limit_to_institution=true)
  result = ""
  if !pi.pubmed_search_name.blank?  then
    result = pi.pubmed_search_name
  else 
    result = pi.last_name
    if full_first_name then
      result = result + ", " + pi.first_name
    else
      result = result + " " + pi.first_name[0,1]
    end
    if !pi.middle_name.nil? && pi.middle_name.length > 0 then
      result = result + " " + pi.middle_name[0,1]
    end
    result = result + '[auth]'
  end
  if pi.pubmed_limit_to_institution || limit_to_institution then
    result = LimitSearchToInstitution(result)
  end
  result
end

def InstitutionalSearchTerms
  return '( "Northwestern University"[affil] OR "Feinberg School"[affil] OR "Robert H. Lurie Comprehensive Cancer Center"[affil] OR "Northwestern Healthcare"[affil] OR "Children''s Memorial"[affil] OR "Northwestern Memorial"[affil] OR "Northwestern Medical"[affil])'
end

def LimitSearchToInstitution(term)
  # temporarily reverse logic limit by institution
  # term + " NOT " + InstitutionalSearchTerms()
  "(" + term + ") AND " + InstitutionalSearchTerms()
end

def BuildSearchOptions (number_years, max_num_records=500)
  {
   #   'mindate' => '2003/05/31',
   #   'maxdate' => '2003/05/31',
     'reldate' => (365*number_years).to_i,
     'retmax' => max_num_records,
  }
end

def FindPubMedIDs (all_investigators, options, number_years, limit_to_institution=true, debug=false, smart_filters=false)
   theCnt = 0
  expected_max_pubs_per_year = 30
  expected_pubs_per_year = 10
  all_investigators.each do |investigator|
#     puts "item = #{item}"
    keywords = BuildSearch(investigator, true, limit_to_institution)
    attempt=0
    begin
      entries = Bio::PubMed.esearch(keywords, options)
      if entries.length < 1 && smart_filters then
        keywords = BuildSearch(investigator,false, limit_to_institution)
        retry
      end
      if entries.length > (expected_max_pubs_per_year*number_years) && smart_filters then
        keywords = LimitSearchToInstitution(keywords)
        retry
      end
    rescue
      attempt+=1
      puts "Failed call with keywords: " + keywords.to_s + "; options: " + options.to_s + "; for investigator #{investigator.first_name} #{investigator.last_name}"
      retry if attempt < 3
      raise
    end
    investigator["entries"] = entries
    if entries.length < 1 then
      puts "no publications found for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords}"
    elsif entries.length > (expected_max_pubs_per_year*number_years) then
      puts "Too many hits??: #{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found"
    elsif entries.length > (expected_pubs_per_year*number_years) then
      puts "More than expected: #{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found"
    elsif entries.length < number_years then
      puts "Too few found: #{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found"
    else
      puts "#{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found" if debug
    end

    #puts "Done with investigator #{investigator.first_name} #{investigator.last_name}"
    theCnt=theCnt+entries.length
  end
  theCnt
end

def MatchInvestigatorsInAuthorString(all_investigators,authors)
  matched_ids=Array.new
  all_investigators.each do |investigator|
    # author string will look like: "Vorontsov, I. I.\nMinasov, G.\nBrunzelle, J. S.\nShuvalova, L.\nKiryukhina, O.\nCollart, F. R.\nAnderson, W. F."
    authors.split("\n").each do |author|
      if author =~ /^#{investigator.last_name}, #{investigator.first_name.at(0)}/i then
        matched_ids.push(investigator.id)
        # puts "found match in author string #{authors.gsub("\n","; ")} for investigator #{investigator.first_name} #{investigator.last_name}"
      end
    end
  end
  return matched_ids
end

def MatchInvestigatorsInFullAuthorString(all_investigators,authors)
  matched_ids=Array.new
  all_investigators.each do |investigator|
    # full_author string will look like: "Vorontsov, Ivan I\nMinasov, George\nBrunzelle, Joseph S\nShuvalova, Ludmilla\nKiryukhina, Olga\nCollart, Frank R\nAnderson, Wayne F"
    authors.split("\n").each do |author|
      if author =~ /^#{investigator.last_name}, #{investigator.first_name}/i then
        matched_ids.push(investigator.id)
        # puts "found match in full author string #{authors.gsub("\n","; ")} for investigator #{investigator.first_name} #{investigator.last_name}"
      end
    end
  end
  return matched_ids
end

def MatchInvestigatorsInCitation(all_investigators,abstract)
  if abstract.full_authors.blank?
    MatchInvestigatorsInAuthorString(all_investigators,abstract.authors)
  else
    MatchInvestigatorsInFullAuthorString(all_investigators,abstract.full_authors)
  end
end

def InsertPublication (publication)
  puts "InsertPublication: this shouldn't happen - publication was nil" if publication.nil?
  raise "InsertPublication: this shouldn't happen - publication was nil" if publication.nil?
  thePub = nil
  medline = Bio::MEDLINE.new(publication)
  reference = medline.reference
  thePub = Abstract.find_by_pubmed(reference.pubmed)
  begin 
    if thePub.nil? || thePub.id < 1 then
      thePub = Abstract.create! (
        :endnote_citation => reference.endnote, 
        :abstract => reference.abstract,
        :authors => reference.authors.join("\n"),
        :full_authors => medline.full_authors,
        :publication_date => medline.publication_date,
        :electronic_publication_date => medline.electronic_publication_date,
        :deposited_date => medline.deposited_date,
        :status => medline.status,
        :publication_status => medline.publication_status,
        :title   => reference.title,
        :publication_type => medline.publication_type[0],
        :journal => medline.full_journal,
        :journal_abbreviation => medline.ta, #journal Title Abbreviation
         :volume  => reference.volume,
        :issue   => reference.issue,
        :pages   => reference.pages,
        :year    => reference.year,
        :pubmed  => reference.pubmed,
        :url     => reference.url,
        :mesh    => reference.mesh.join(";\n")
      )
    else
      if thePub.publication_date != medline.publication_date || thePub.status != medline.status || thePub.publication_status != medline.publication_status then
          thePub.endnote_citation = reference.endnote
          thePub.publication_date = medline.publication_date
          thePub.electronic_publication_date = medline.electronic_publication_date
          thePub.deposited_date = medline.deposited_date
          thePub.publication_status = medline.publication_status
          thePub.status  = medline.status
          thePub.volume  = reference.volume
          thePub.issue   = reference.issue
          thePub.pages   = reference.pages
          thePub.year    = reference.year
          thePub.pubmed  = reference.pubmed
          thePub.url     = reference.url
          thePub.mesh    = reference.mesh.join(";\n")
          thePub.save!
        end
    end
  rescue ActiveRecord::RecordInvalid
     if thePub.nil? then # something bad happened
      puts "InsertPublication: unable to find or insert reference with the pubmed id of '#{reference.pubmed}"
      raise "InsertPublication: unable to find or insert reference with the pubmed id of  '#{reference.pubmed}"
    end
  end 
  thePub.id
end

def InsertInvestigatorPublication (abstract_id, investigator_id)
  puts "InsertInvestigatorPublication: this shouldn't happen - abstract_id was nil" if abstract_id.nil?
  return if abstract_id.nil?
  puts "InsertInvestigatorPublication: this shouldn't happen - investigator_id was nil" if investigator_id.nil?
  return if investigator_id.nil?
  thePIPub = nil
  begin 
     thePIPub = InvestigatorAbstract.create! (
       :abstract_id     => abstract_id,
       :investigator_id => investigator_id
     )
   rescue ActiveRecord::RecordInvalid
     thePIPub = InvestigatorAbstract.find(:first, 
              :conditions => ["abstract_id = :abstract_id and investigator_id = :investigator_id", {:abstract_id => abstract_id, :investigator_id => investigator_id} ] )
     if thePIPub.nil? then # something bad happened
       puts "InsertInvestigatorPublication: unable to either insert or find a reference with the abstract_id '#{abstract_id}' and the investigator_id '#{investigator_id}'"
       return 
     end
   end 
   thePIPub.id
  
end

def AddInvestigatorToCitation(abstract_id, investigator_ids)
  puts "AddInvestigatorToCitation: this shouldn't happen - abstract_id was nil" if abstract_id.nil?
  return if abstract_id.nil?
  puts "AddInvestigatorToCitation: this shouldn't happen - investigator_ids was nil" if investigator_ids.nil?
  return if investigator_ids.nil?
  return if investigator_ids.length < 1
  investigator_ids.each do |investigator_id|
    if InvestigatorAbstract.find :first,
      :conditions => [" abstract_id = :abstract_id AND investigator_id = :investigator_id",
          {:investigator_id => investigator_id, :abstract_id => abstract_id}]
      # puts "found investigator/abstract pair"
    else
      puts "adding new investigator/abstract pair"
      InsertInvestigatorPublication (abstract_id, investigator_id)
    end
  end
end