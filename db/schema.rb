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

ActiveRecord::Schema.define(:version => 20130625172304) do

  create_table "batch_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "batches", :force => true do |t|
    t.integer  "batch_type_id"
    t.integer  "server_id"
    t.string   "name"
    t.boolean  "oral_history"
    t.boolean  "dark_archive"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "status_id"
  end

  add_index "batches", ["batch_type_id"], :name => "index_batches_on_batch_type_id"
  add_index "batches", ["server_id"], :name => "index_batches_on_server_id"

  create_table "packages", :force => true do |t|
    t.integer  "batch_id"
    t.integer  "status_id"
    t.string   "sip_path"
    t.string   "aip_identifier"
    t.string   "dip_identifier"
    t.boolean  "oral_history"
    t.boolean  "dark_archive"
    t.boolean  "approved"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
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

end
