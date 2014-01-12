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

ActiveRecord::Schema.define(:version => 20090422220831) do

  create_table "member_interests", :force => true do |t|
    t.integer  "member_id"
    t.integer  "topic_id"
    t.boolean  "is_interested", :default => false
    t.boolean  "is_expert",     :default => false
    t.boolean  "will_speak",    :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "members", :force => true do |t|
    t.string   "first_name",        :limit => 50
    t.string   "last_name",         :limit => 50
    t.string   "email",             :limit => 50
    t.integer  "occupation_id"
    t.string   "url"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_email_visible",                 :default => true
    t.string   "bio",               :limit => 320
    t.string   "twitter",                          :default => ""
    t.string   "github",                           :default => ""
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count"
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "perishable_token",                 :default => "",   :null => false
  end

  add_index "members", ["email"], :name => "index_members_on_email"
  add_index "members", ["perishable_token"], :name => "index_members_on_perishable_token"

  create_table "occupations", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "topics", :force => true do |t|
    t.string   "name",           :default => "", :null => false
    t.integer  "interest_count", :default => 0
    t.integer  "expert_count",   :default => 0
    t.integer  "speaker_count",  :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

end
