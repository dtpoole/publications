## Endnote XML import tasks
#

def elapsed_time(start)
  run_time = Time.now - start
  sprintf("%d.", run_time / 60) + sprintf("%d", run_time % 60)
end



def is_author?(abstract, investigator)
  
  if abstract.authors
  
    if abstract.authors =~ /#{investigator.last_name},/

      abstract.authors.each do |author|
      
        if author =~ /#{investigator.first_name}.[ ]+#{investigator.middle_name}.[ ]*/
          puts "1:" + author + " - " + investigator.fullname
          return true
        elsif author =~ /#{investigator.first_name}[ ]+#{investigator.middle_name.at(0)}.[ ]*/
          puts "2:" + author+ " - " + investigator.fullname
          return true
        elsif author =~ /,[ ]+#{investigator.first_name}.[ ]+#{investigator.middle_name.at(0)}./
          puts "3:" + author + " - " + investigator.fullname
          return true        
        elsif author =~ /,[ ]+#{investigator.first_name.at(0)}.#{investigator.middle_name.at(0)}./
          puts "4:" + author + " - " + investigator.fullname
          return true
        elsif author =~ /,[ ]+#{investigator.first_name.at(0)}.[ ]+#{investigator.middle_name.at(0)}/
          puts "5:" + author + " - " + investigator.fullname    
          return true
        elsif author =~ /,[ ]+#{investigator.first_name.at(0)}#{investigator.middle_name.at(0)}/
          puts "6:" + author + " - " + investigator.fullname
          return true
        elsif author =~ /,[ ]+#{investigator.first_name.at(0)}.$/
          puts "7:" + author + " - " + investigator.fullname
          return true
        end
      end

    end
  end
   false
end


namespace :endnote do
    
  @verbose = true
   
  desc "list uploaded files that haven't been imported"
  task :pending => :environment do
   puts "Endnote files pending import:"
   Endnote.all.each do |file|
     puts "#{file.created_at.strftime("%m/%d/%Y %I:%M%p")} - #{file.uploaded_by} - #{file.full_filename}"
   end
  end
  
  desc "list uploaded files that haven't been imported"
  task :test => :environment do
    
    endNote = EndnoteXML.new('/Users/dtpoole/endnote-styles.xml')
     
    endNote.parse
     
    #puts "#{endNote.record_count} records exist."
    
  end

  desc 'check for uploaded files'
  task :get_file => :environment do
    
   @file = nil
   endnote = Endnote.first
   if !endnote
     puts "No files pending import." if @verbose
   else
     filename = endnote.full_filename
     puts "Importing #{filename}..." if @verbose
     raise "File does not exist. (#{filename})" unless File.stat(filename).file?
     @file = filename
   end
  
  end



  desc 'check for uploaded files'
  task :wee => :get_file do
    
    endNote = EndnoteXML.new("/Users/dtpoole/Downloads/test.xml")
    puts endNote.record_count
    
    endNote.parse.each do |pub|
      puts pub.to_yaml
      puts
    end
  
  end
  


  desc 'parse Endnote file'
  task :import => :get_file do |t, args|
    
   unless @file.nil?
     
     start_time = Time.now
    
     count = count_added = count_updated = 0
     
     begin
       endNote = EndnoteXML.new(@file)
   
       endNote.parse.each do |pub|
         count += 1
         if abstract = Abstract.find(:first, :conditions => { :endnote_id => pub['endnote_id'] })
            
              puts "\tUpdating... (#{pub['endnote_id']} - #{pub['title']})" if @verbose
              
              begin
                if abstract.authors != pub['authors']
                  puts "\t\tAuthors are different.  Removing investigator relations."
                  InvestigatorAbstract.delete_all "abstract_id = #{abstract.id}"
                end
         
                abstract.update_attributes!(pub)
                count_updated += 1
              rescue ActiveRecord::RecordInvalid => invalid
                 puts "\t\tERROR: " + invalid.record.errors.full_messages.join("\n")
              end

          else
            
            puts "\tAdding... (#{pub['endnote_id']} - #{pub['title']})" if @verbose
        
            abstract = Abstract.new(
              :authors => pub['authors'],
              :abstract => pub['abstract'],
    #          :publication_date => medline.publication_date,
    #          :electronic_publication_date => medline.electronic_publication_date,
    #          :deposited_date => medline.deposited_date,
    #          :status => medline.status,
    #          :publication_status => medline.publication_status,
              :title   => pub['title'],
              :publication_type => pub['publication_type'],
              :journal => pub['journal'],
              :journal_abbreviation => pub['journal_abbreviation'],
              :volume  => pub['volume'],
              :issue   => pub['issue'],
              :pages   => pub['pages'],
              :year    => pub['year'],
              :date    => pub['date'],
              :accession  => pub['accession'],
              :endnote_id => pub['endnote_id'],
              :pub_location => pub['pub_location'],
              :publisher => pub['publisher']
              #:url     => pub['url'],
            )
            
            begin
               abstract.save!
               count_added += 1
            rescue ActiveRecord::RecordInvalid => invalid
               puts "\t\tERROR: " + invalid.record.errors.full_messages.join("\n")
            end
          end
    
       end
   
     rescue Exception => ex
       raise
     end
 
     Endnote.first.destroy
          
     # update settings table
     setting = Setting.first
     setting.last_update = Abstract.find(:first, :order => "updated_at DESC", :select => 'updated_at').updated_at
     setting.start_year = Abstract.find_by_sql('select min(year) as year from abstracts;').first.year
     setting.end_year = Abstract.find_by_sql('select max(year) as year from abstracts;').first.year
     setting.save!
  
     run_time = Time.now - start_time
     
     puts "File successfully imported" if @verbose
     puts "Parsed #{count} records.  Added #{count_added}.  Updated #{count_updated}" if @verbose
     puts "task :import took #{elapsed_time(start_time)} minutes." if @verbose
    end
  end
  
  
  
  
    desc 'associate investigators with abstracts'
    task :associate_investigators => :environment do

       start_time = Time.now

       investigators = Investigator.find( :all,
       :select => 'id, username, first_name, last_name, middle_name',
       :conditions => ['end_date is null or end_date >= :now', {:now => Date.today}]
       )

       puts "Found #{investigators.length} investigators." if @verbose

       Abstract.find(:all, :select => "id, authors, full_authors").each do |abstract|

          associated_investigators = Array.new

          investigators.each do |investigator|

             if abstract.authors
               abstract.authors.each do |author|
                  if author =~ /^#{investigator.last_name}, #{investigator.first_name}/i or author =~ /^#{investigator.last_name}, #{investigator.first_name.at(0)
  }/i
                    if !abstract.associated_with?(investigator)
                      associated_investigators << investigator
                    end
                  end
               end
             end

             if abstract.full_authors
               abstract.full_authors.each do |author|
                   if author =~ /^#{investigator.last_name}, #{investigator.first_name}/i
                     if !abstract.associated_with?(investigator)
                       associated_investigators << investigator
                     end
                  end
               end
             end
          end

          if associated_investigators.length > 0

            puts "Abstract ID: #{abstract.id}" if @verbose

            associated_investigators.uniq!

            associated_investigators.each do |investigator|       
              begin
                 puts "\tAssociating #{investigator.fullname}" if @verbose
                 InvestigatorAbstract.create!(:abstract_id => abstract.id, :investigator_id => investigator.id)
              rescue ActiveRecord::RecordInvalid => invalid
                 puts "\tERROR: " + invalid.record.errors.full_messages.join("\n")
                 break
              end
            end
            puts "\n" if @verbose
          end   
       end

       puts "task :associate_investigators took #{elapsed_time(start_time)} minutes." if @verbose

    end

  
  
  
  
  desc 'associate investigators with abstracts'
  task :associate_investigators_new => :environment do
    
     start_time = Time.now

     investigators = Investigator.find( :all,
     :select => 'id, username, first_name, last_name, middle_name, pubmed_search_name',
     :conditions => ['end_date is null or end_date >= :now', {:now => Date.today}]
     )

     puts "Found #{investigators.length} investigators." if @verbose

     Abstract.find(:all, :select => "id, authors, full_authors").each do |abstract|
       
         #  puts abstract.authors if abstract.authors
       
        adds = Array.new
        removes = Array.new
       
        investigators.each do |investigator|
          
          author = is_author?(abstract, investigator)
          associated = abstract.associated_with?(investigator)
          
          if !associated and author
            #puts "add"
            adds << investigator
          elsif associated and !author
            #puts "remove"
            removes << investigator
          end 
        end

        if adds.length > 0
          puts "Abstract ID: #{abstract.id}" if @verbose
          adds.uniq!
          adds.each do |investigator|       
            begin
               puts "\tAssociating #{investigator.fullname}" if @verbose
              # InvestigatorAbstract.create!(:abstract_id => abstract.id, :investigator_id => investigator.id)
            rescue ActiveRecord::RecordInvalid => invalid
               puts "\tERROR: " + invalid.record.errors.full_messages.join("\n")
               break
            end
          end
          puts "\n" if @verbose
        end
        
        if removes.length > 0
          puts "Abstract ID: #{abstract.id}" if @verbose
          removes.uniq!
          removes.each do |investigator|       
            begin
               puts "\tRemoving #{investigator.fullname}" if @verbose
              # InvestigatorAbstract.delete_all("abstract_id = #{abstract.id} AND investigator_id = #{investigator.id}")
            rescue ActiveRecord::RecordInvalid => invalid
               puts "\tERROR: " + invalid.record.errors.full_messages.join("\n")
               break
            end
          end
          puts "\n" if @verbose
        end
     end
     
     puts "task :associate_investigators took #{elapsed_time(start_time)} minutes." if @verbose
  
  end

end
