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

ActiveRecord::Schema.define(:version => 20130701124503) do

  create_table "api_keys", :force => true do |t|
    t.string   "access_token"
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "batch_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "batches", :force => true do |t|
    t.integer  "batch_type_id"
    t.integer  "server_id"
    t.string   "name"
    t.boolean  "oral_history",    :default => false
    t.boolean  "dark_archive",    :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "status_id"
    t.string   "discussion_link"
  end

  add_index "batches", ["batch_type_id"], :name => "index_batches_on_batch_type_id"
  add_index "batches", ["server_id"], :name => "index_batches_on_server_id"

  create_table "log_entries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "package_id"
    t.boolean  "approved"
    t.boolean  "automatic"
    t.string   "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "log_entries", ["package_id"], :name => "index_log_entries_on_package_id"
  add_index "log_entries", ["user_id"], :name => "index_log_entries_on_user_id"

  create_table "packages", :force => true do |t|
    t.integer  "batch_id"
    t.integer  "status_id"
    t.string   "sip_path"
    t.string   "aip_identifier"
    t.string   "dip_identifier"
    t.boolean  "oral_history",      :default => false
    t.boolean  "dark_archive",      :default => false
    t.boolean  "approved"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "requires_approval"
  end

  add_index "packages", ["batch_id"], :name => "index_packages_on_batch_id"
  add_index "packages", ["status_id"], :name => "index_packages_on_status_id"

  create_table "servers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tasks", :force => true do |t|
    t.integer  "package_id"
    t.integer  "type_id"
    t.integer  "status_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tasks", ["package_id"], :name => "index_tasks_on_package_id"
  add_index "tasks", ["status_id"], :name => "index_tasks_on_status_id"
  add_index "tasks", ["type_id"], :name => "index_tasks_on_type_id"

  create_table "types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "roles_mask"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
