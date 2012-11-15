# This migration comes from another_uploader_engine (originally 20121115043827)
class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.integer :creator_id
      t.string :name
      t.string :caption, limit: 1000
      t.text :description
      t.boolean :is_public, default: true
      t.integer :uploadable_id
      t.string :uploadable_type
      t.string :width
      t.string :height
      t.string :local_file_name
      t.string :local_content_type
      t.integer :local_file_size
      t.datetime :local_updated_at
      t.string :local_fingerprint
      t.string :remote_file_name
      t.string :remote_content_type
      t.integer :remote_file_size
      t.datetime :remote_updated_at
      t.string :remote_fingerprint

      t.timestamps
    end
    add_index :uploads, :creator_id
    add_index :uploads, :uploadable_id
    add_index :uploads, :uploadable_type
    add_index :uploads, :local_file_name
  end
end
