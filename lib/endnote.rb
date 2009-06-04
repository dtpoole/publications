require 'sax-machine'

module EndNote
  # sed -e 's/<style[^>]*>//g' endnote-latest-sample.xml | sed -e 's/<\/style[^>]*>//g' > go.xml
  
  class Dates
    include SAXMachine
    elements :date
  end

  class Authors
    include SAXMachine
    elements :author, :as => :authors
  end

  class Contributers
    include SAXMachine
    elements 'secondary-authors', :as => :secondary_authors, :class => Authors
    elements :authors, :as => :authors, :class => Authors
  end

  class Periodical
    include SAXMachine
    element 'full-title', :as => :journal
    element 'abbr-1', :as => :journal_abbr
  end

  class Publication
    include SAXMachine
    element 'accession-num', :as => :accession
    element 'rec-number', :as => :endnote_id
    element :abstract
    element 'accession-num', :as => :accession
    element 'pub-location', :as => :pub_location
    elements :periodical, :as => :periodical, :class => Periodical
    elements :contributors, :as => :contributors, :class => Contributers
    element :publisher
    element :pages
    element :volume
    element :number, :as => :issue
    elements 'pub-dates', :as => :pub_dates, :class => Dates
    element :year
  end

  class Publications
    include SAXMachine
    elements :record, :as => :publications, :class => Publication
  end
  
end
