module AbstractsHelper
  def total_found(plain=false)
     if @total_found
        text = "Found #{pluralize(@total_found, 'publication')}."
        plain ? text : content_tag('h3', text)
     end
  end

  def print_view_link
     if request.request_uri =~ /\?/
        request.request_uri + '&print=1'
     else
        request.request_uri + '?print=1'
     end
  end



  def nlm_page_format(pages)

     pages.gsub!(/\./, "")

     display = pages

     if pages =~ /^[0-9]+\-[0-9]+$/

        parts = pages.split('-')

        return parts[0] if parts[0] == parts[1]

        if parts[0].length == parts[1].length
           display = parts[0] + "-"

           a = parts[0].split(//)
           b = parts[1].split(//)

           for i in (0..b.length)
              if a[i] != b[i]
                 display += b[i..b.length].to_s
                 break
              end
           end
        end
     end
     display

  end


  def format_authors(authors)
     display = Array.new

     authors.split("\n").each do |author|
        formatted = ""

        author.strip!
        author.gsub!('&apos;', "'")

        author.chop! if author =~ /,$/

        name = author.split(',')

        formatted = name[0] + " "

        # max 2 inititals
        given_name = name[1].to_s.split[0..1]

        if given_name.length == 1 and given_name[0] =~ /\./
           formatted += given_name[0].gsub(/\./, "")
        else
           given_name.each do |part|
              formatted += part.to_s[0,1]
           end
        end

        display << formatted.gsub(/\./, "").strip
     end
     display.join(", ")
  end


  def format_journal(pub, html=true, omit_title=false)
     display = ""
     
     if !omit_title
       display = format_authors(pub.authors) + ". "

       if html
          display += link_to(pub.title, :action => 'show', :id => pub)
       else
          display += pub.title
       end

       display += "." if pub.title !~ /\.$/
       display += " "
     end

     journal = pub.journal_abbreviation ? pub.journal_abbreviation : pub.journal

     if journal
        display += journal.gsub(/\./, "") + ". "
     end

     if pub.year and pub.date
       display += pub.year + " " + pub.date + ";"
     elsif pub.year and !pub.date
       display += pub.year + ";"       
     end

     display += pub.volume if pub.volume
     display += "(#{pub.issue})" if pub.issue

     display += ":" + nlm_page_format(pub.pages) if pub.pages and pub.pages.length > 0

     display += "."
  end


  def format_book_section(pub, html=true, omit_title=false)
    display = ""
    
    if !omit_title
     display = format_authors(pub.authors) + ". "

     if html
        display += link_to(pub.title, :action => 'show', :id => pub)
     else
        display += pub.title
     end
    

     display += "." if pub.title !~ /\.$/
     display += " "

   end

     display += "In: "

     if pub.secondary_authors
        display += format_authors(pub.secondary_authors) + ", "
        if pub.secondary_authors =~ /\n/
           display += 'editors. '
        else
           display += 'editor. '
        end
     end

     journal = pub.journal_abbreviation ? pub.journal_abbreviation : pub.journal

     if journal
        display += journal.gsub(/\./, "") + ". "
     end

     display += pub.pub_location + ": " if pub.pub_location
     display += pub.publisher + "; " if pub.publisher

     display += pub.year + ". " if pub.year

     display += "p. " + nlm_page_format(pub.pages) + ". " if pub.pages

     display
  end


  def format_book(pub, html=true, omit_title=false)
    
    display = ""
    
    if !omit_title
      display = format_authors(pub.authors) + ". "
  
     if html
        display += link_to(pub.title, :action => 'show', :id => pub)
     else
        display += pub.title
     end

     display += "." if pub.title !~ /\.$/
     display += " "

   end

     if pub.secondary_authors
        display += format_authors(pub.secondary_authors) + ", "
        if pub.secondary_authors =~ /\n/
           display += 'editors. '
        else
           display += 'editor. '
        end
     end

     display += pub.pub_location + ": " if pub.pub_location
     display += pub.publisher + "; " if pub.publisher

     display += pub.year + ". " if pub.year

     display
  end
  
end
