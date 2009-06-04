require 'hpricot'

class EndnoteXML
  
  XMLFIELDS = %w[accession-num contributors/authors/author abstract pages volume number year periodical/full-title title 
    periodical/abbr-1 rec-number secondary-title pub-location publisher contributors/secondary-authors/author pub-dates/date]
  
  MAPPINGS = { 
    'periodical/full-title' => 'journal', 
    'accession-num' => 'accession',
    'number' => 'issue',
    'periodical/abbr-1' => 'journal_abbreviation',
    #'author' => 'authors',
    'rec-number' => 'endnote_id',
    'pub-location' => 'pub_location',
    'contributors/secondary-authors/author' => 'secondary_authors',
    'secondary-title' => 'secondary_title',
    'contributors/authors/author' => 'authors',
    'pub-dates/date' => 'date'
    
  }
  
  
  @filename
  @doc
  
  def initialize(filename = nil)
    raise "Filename is required." if filename.nil?
    
    @filename = filename
    openXML
  end
  
  
  def parse
    
    publications = Array.new
    
    (@doc/:record).each do |pub|
      publication = Hash.new
      for field in XMLFIELDS
        
        MAPPINGS[field] ? attr = MAPPINGS[field] : attr = field
        
        element = (pub/field.intern)
        if !element.empty?
          if element.size > 1
            publication[attr] = Array.new
            element.each do |ele|
              publication[attr] << clean(ele.innerHTML)
            end
          else
            publication[attr] = clean(element.first.innerHTML)
          end
        else
          publication[attr] = nil
        end
      end
      
      # get type of publication.
      if !(pub/:'ref-type').empty?
        publication['publication_type'] = (pub/:'ref-type').first['name']
      end
      
      # put authors in proper format
      if publication['authors'].class.to_s == "Array"
        publication['authors'] = publication['authors'].join("\n")
      end
      
      if publication['authors'] =~ /^---/
         publication['authors'].slice!(0,7)
         publication['authors'].chop!
         publication['authors'].gsub!("- ", "")
      end

      if publication['secondary_authors'].class.to_s == "Array"
        publication['secondary_authors'] = publication['secondary_authors'].join("\n")
      end
      
      if publication['secondary_authors'] =~ /^---/
         publication['secondary_authors'].slice!(0,7)
         publication['secondary_authors'].chop!
         publication['secondary_authors'].gsub!("- ", "")
      end
    
      
      if !publication['journal'].nil? and !publication['secondary_title'].nil?

        if publication['journal'] != publication['secondary_title']
          journal_size = publication['journal'].length
          secondary_title_size = publication['secondary_title'].length

          if secondary_title_size > journal_size
            publication['journal'] = publication['secondary_title']    
          elsif secondary_title_size == journal_size
            # handle modifications: Jama to JAMA
            publication['journal'] = publication['secondary_title']
          end
          publication.delete('secondary_title')
        end  

      elsif publication['journal'].nil? and !publication['secondary_title'].nil?
        publication['journal'] = publication['secondary_title']
        publication.delete('secondary_title')     
      end
     
      if publication['publication_type'] == 'Journal Article'
        publication.delete('secondary_title')     
      end
      
      publications << publication
      
    end
    publications
  
  end
  
  
  def record_count
    (@doc/:record).size
  end
  
  private
  
  def openXML
    begin
      @doc = Hpricot.XML(open(@filename))
    rescue
      raise "Error: Unable to read file. (#{@filename})"
    end
  end
  
  def clean(string)
    string.gsub(/<style[^>]*>/, '').gsub(/<\/style[^>]*>/, '').strip
  end

end
