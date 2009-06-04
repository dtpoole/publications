# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090403151429) do

  create_table "abstracts", :force => true do |t|
    t.text     "endnote_citation"
    t.text     "abstract"
    t.text     "authors"
    t.text     "full_authors"
    t.text     "title"
    t.string   "journal_abbreviation"
    t.string   "journal"
    t.string   "volume"
    t.string   "issue"
    t.string   "pages"
    t.string   "year"
    t.date     "publication_date"
    t.string   "publication_type"
    t.date     "electronic_publication_date"
    t.date     "deposited_date"
    t.string   "status"
    t.string   "publication_status"
    t.string   "pubmed"
    t.string   "url"
    t.text     "mesh"
    t.datetime "created_at"
    t.integer  "created_id"
    t.string   "created_ip"
    t.datetime "updated_at"
    t.integer  "updated_id"
    t.string   "updated_ip"
    t.datetime "deleted_at"
    t.integer  "deleted_id"
    t.string   "deleted_ip"
    t.string   "endnote_id"
    t.string   "accession"
    t.string   "pub_location"
    t.string   "publisher"
    t.string   "secondary_authors"
    t.string   "secondary_title"
    t.string   "date"
  end

  add_index "abstracts", ["updated_at"], :name => "idx_updated_at"
  add_index "abstracts", ["year"], :name => "idx_year"

  create_table "endnotes", :force => true do |t|
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.string   "uploaded_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "investigator_abstracts", :force => true do |t|
    t.integer "abstract_id",     :null => false
    t.integer "investigator_id", :null => false
  end

  add_index "investigator_abstracts", ["abstract_id"], :name => "idx_ia_abstracts"
  add_index "investigator_abstracts", ["investigator_id"], :name => "idx_ia_investigators"

  create_table "investigator_programs", :force => true do |t|
    t.integer "program_id",          :null => false
    t.integer "investigator_id",     :null => false
    t.string  "program_appointment"
    t.date    "start_date"
    t.date    "end_date"
  end

  add_index "investigator_programs", ["investigator_id"], :name => "idx_ip_investigators"
  add_index "investigator_programs", ["program_id"], :name => "idx_ip_program"

  create_table "investigators", :force => true do |t|
    t.string   "username",                                                       :null => false
    t.string   "last_name",                                                      :null => false
    t.string   "first_name",                                                     :null => false
    t.string   "middle_name"
    t.string   "pubmed_search_name"
    t.boolean  "pubmed_limit_to_institution", :default => false
    t.date     "last_pubmed_search"
    t.string   "title"
    t.string   "email"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",                  :default => '2008-10-17 13:10:52'
    t.integer  "created_id"
    t.string   "created_ip"
    t.datetime "updated_at"
    t.integer  "updated_id"
    t.string   "updated_ip"
    t.datetime "deleted_at"
    t.integer  "deleted_id"
    t.string   "deleted_ip"
  end

  add_index "investigators", ["last_name"], :name => "idx_last_name"

  create_table "programs", :force => true do |t|
    t.integer "program_number",   :null => false
    t.string  "program_abbrev"
    t.string  "program_title"
    t.string  "program_category"
    t.date    "start_date"
    t.date    "end_date"
  end

  add_index "programs", ["program_number"], :name => "idx_program_number"
  add_index "programs", ["program_title"], :name => "idx_program_title"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.integer "start_year",  :null => false
    t.integer "end_year",    :null => false
    t.date    "last_update", :null => false
  end

end
