class CreateEndnotes < ActiveRecord::Migration
  def self.up
    create_table :endnotes do |t|
      t.integer :size  # file size in bytes
      t.string :content_type   # mime type, ex: application/mp3
      t.string :filename   # sanitized filename
      t.string :uploaded_by
      t.timestamps
    end
  end

  def self.down
    drop_table :endnotes
  end
end
