# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121115045630) do

  create_table "password_recoveries", :force => true do |t|
    t.integer  "user_id"
    t.string   "reset_link"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "password_recoveries", ["reset_link"], :name => "index_password_recoveries_on_reset_link", :unique => true
  add_index "password_recoveries", ["user_id"], :name => "index_password_recoveries_on_user_id", :unique => true

  create_table "uploads", :force => true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.string   "caption",             :limit => 1000
    t.text     "description"
    t.boolean  "is_public",                           :default => true
    t.integer  "uploadable_id"
    t.string   "uploadable_type"
    t.string   "width"
    t.string   "height"
    t.string   "local_file_name"
    t.string   "local_content_type"
    t.integer  "local_file_size"
    t.datetime "local_updated_at"
    t.string   "local_fingerprint"
    t.string   "remote_file_name"
    t.string   "remote_content_type"
    t.integer  "remote_file_size"
    t.datetime "remote_updated_at"
    t.string   "remote_fingerprint"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  add_index "uploads", ["creator_id"], :name => "index_uploads_on_creator_id"
  add_index "uploads", ["local_file_name"], :name => "index_uploads_on_local_file_name"
  add_index "uploads", ["uploadable_id"], :name => "index_uploads_on_uploadable_id"
  add_index "uploads", ["uploadable_type"], :name => "index_uploads_on_uploadable_type"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.boolean  "admin"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
