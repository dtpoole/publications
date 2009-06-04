def elapsed_time(start)
  run_time = Time.now - start
  sprintf("%d.", run_time / 60) + sprintf("%d", run_time % 60)
end


namespace :testy do
    
  @verbose = true

  task :sax => :environment do
    
    start_time = Time.now
    
    filename = '/Users/dtpoole/xml/sax.xml'
    
    if system "sed -e 's/<style[^>]*>//g' #{filename} | sed -e 's/<\/style[^>]*>//g' > #{filename}"
      endnote = EndNote::Publications.parse(File.open(filename))      
    else
      raise "sed did not complete successfully."
    end
    
    run_time = Time.now - start_time

    puts "task :test_sax took #{elapsed_time(start_time)} minutes." if @verbose
    
  end
  
  task :old => :environment do
    
    start_time = Time.now
    
    filename = '/Users/dtpoole/xml/old.xml'
    
    if system "sed -e 's/<style[^>]*>//g' #{filename} | sed -e 's/<\/style[^>]*>//g' > #{filename}"
      endNote = EndnoteXML.new(@file)
      endNote.parse
    else
      raise "sed did not complete successfully."
    end
    
    run_time = Time.now - start_time

    puts "task :test_old took #{elapsed_time(start_time)} minutes." if @verbose
    
  end

end
