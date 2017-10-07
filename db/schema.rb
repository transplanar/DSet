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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171007011113) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.string   "name"
    t.string   "image_url"
    t.integer  "cost"
    t.string   "types"
    t.string   "category"
    t.string   "expansion"
    t.string   "strategy"
    t.string   "terminality"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "cards_slots", id: false, force: :cascade do |t|
    t.integer "slot_id", null: false
    t.integer "card_id", null: false
  end

  add_index "cards_slots", ["card_id", "slot_id"], name: "index_cards_slots_on_card_id_and_slot_id", using: :btree
  add_index "cards_slots", ["slot_id", "card_id"], name: "index_cards_slots_on_slot_id_and_card_id", using: :btree

  create_table "keywords", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "type"
    t.integer  "card_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "keywords", ["card_id"], name: "index_keywords_on_card_id", using: :btree

  create_table "slots", force: :cascade do |t|
    t.string   "queries"
    t.string   "image_url"
    t.string   "sql_prepend"
    t.string   "filters_humanized"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_foreign_key "keywords", "cards"
end
