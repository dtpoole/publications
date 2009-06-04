class Endnote < ActiveRecord::Base
    has_attachment :storage      => :file_system,
                   :max_size     => 50.megabytes,
                   :path_prefix  => 'public/uploads'

  #  :content_type => 'text/xml', 

    validates_as_attachment
end
