require 'find'
require 'date'
require 'fileutils'
require 'bio' #require bioruby!
require 'utility'
require 'pubmedext' #my extensions to grab other dates and full author names
#require 'tasks/obo_parser'
#require 'tasks/tree_traversal'

require 'rubygems'

@AllInvestigators = nil
@AllAbstracts = nil
@all_entries = nil
@all_publications = Array.new
@debug = false
@verbose = true
@limit_to_institution = false
@number_years = 9


# simply for debugging - prints a slice of an array or any other object that supports 'each'
def printSlice (theslice)
  theIterator=0
  theslice.each do |the_entry|
    print the_entry.inspect, "; "
    break if theIterator > 10
    theIterator=theIterator+1
  end
end

# simply for debugging - prints (puts) an inspection of the object
def inspectObject (theObject)
  puts theObject.inspect
end

task :getInvestigators => :environment do
  # load all investigators
  @AllInvestigators = Investigator.find(:all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }])
  
#  @AllInvestigators = Investigator.find(:all, :conditions => "id=1")
  puts "count of all investigators is #{@AllInvestigators.length}" if @verbose
end

task :getAbstracts => :environment do
  # load all abstracts
  @AllAbstracts = Abstract.find(:all)
  puts "count of all abstracts is #{@AllAbstracts.length}" if @verbose
end

task :getPubmedIDs => :getInvestigators do
  #get the pubmed ids
   start = Time.now
   options = BuildSearchOptions(@number_years)
   pubsFound = FindPubMedIDs (@AllInvestigators, options, @number_years, @limit_to_institution, @debug)
   stop = Time.now
   elapsed_seconds = stop.to_f - start.to_f
   puts "number of publications found: #{pubsFound} in #{elapsed_seconds} seconds" if @verbose
end

task :getPIAbstracts => :getPubmedIDs do
  #get the abstracts
  theCnt = 0
  start = Time.now
  @AllInvestigators.each do |investigator|
    if investigator.entries.length > 0
      puts "looking up #{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name}" if @debug
      pubs = Bio::PubMed.efetch(investigator.entries)
      investigator["publications"] = pubs
      theCnt=theCnt+pubs.length
    else
      puts "no publications found for investigator #{investigator.first_name} #{investigator.last_name}"
      investigator["publications"] = nil
    end
  end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "number abstracts pulled: #{theCnt} in #{elapsed_seconds} seconds" if @verbose
end


task :insertAbstracts => :getPIAbstracts do
  # load the test data
  start = Time.now
  @AllInvestigators.each do |investigator|
    if !investigator.publications.nil? then
      investigator.publications.each do |publication|
        publication_id = InsertPublication(publication)
        if publication_id > 0 then
          InsertInvestigatorPublication( publication_id, investigator.id )
        end
      end
    end
  end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task insertAbstracts ran in #{elapsed_seconds} seconds" if @verbose
end

task :associateAbstractsWithInvestigators => [:getAbstracts, :getInvestigators] do
  # load the test data
  start = Time.now
  @AllAbstracts.each do |abstract|
    investigator_ids = MatchInvestigatorsInCitation(@AllInvestigators,abstract)
    AddInvestigatorToCitation(abstract.id, investigator_ids)
   end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task insertAbstracts ran in #{elapsed_seconds} seconds" if @verbose
end


task :getInstitutionalPubmedIDs => :environment do
  # get all pubmed IDs using the following keywords:
  start = Time.now
  keywords = InstitutionalSearchTerms()
  options = BuildSearchOptions(@number_years,50000)
  @all_entries = Bio::PubMed.esearch(keywords, options)
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "number of publications found: #{@all_entries.length} in #{elapsed_seconds} seconds" if @verbose
end

task :getInstitutionalPubmedIDsAbstracts => :getInstitutionalPubmedIDs do
  #get the abstracts
  theCnt = 0
  theSize = 499
  theEnd = 0
  start = Time.now
  puts "looking up #{@all_entries.length} pubs" if @debug
  puts "done"
  while theCnt < @all_entries.length do
    theEnd = theCnt+theSize
    theEnd = @all_entries.length-1 if theEnd > @all_entries.length-1 
    puts "Slicing all_entries from #{theCnt} to #{theEnd}" if @debug
    mySlice = @all_entries[theCnt..theEnd]
    puts "looking up #{mySlice.length} pubs from #{theCnt} to #{theEnd}" if @debug
    theCnt = theEnd+1
    printSlice(mySlice) if @debug
    pubs = Bio::PubMed.efetch(mySlice)
    inspectObject(pubs[0]) if @debug
    puts "found #{pubs.length} pubs" if @debug
    @all_publications =  @all_publications + pubs
  end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "number abstracts pulled: #{@all_publications.length} in #{elapsed_seconds} seconds" if @verbose
end

task :insertInstitutionalAbstracts => :getInstitutionalPubmedIDsAbstracts do
  # load the test data
  start = Time.now
  @all_publications.each do |publication|
      publication_id = InsertPublication(publication)
   end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task insertAbstracts ran in #{elapsed_seconds} seconds" if @verbose
end

