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

ActiveRecord::Schema.define(version: 20160203000057) do

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
    t.integer  "slot_id"
  end

  add_index "cards", ["slot_id"], name: "index_cards_on_slot_id"

  create_table "cards_slots", id: false, force: :cascade do |t|
    t.integer "slot_id", null: false
    t.integer "card_id", null: false
  end

  add_index "cards_slots", ["card_id", "slot_id"], name: "index_cards_slots_on_card_id_and_slot_id"
  add_index "cards_slots", ["slot_id", "card_id"], name: "index_cards_slots_on_slot_id_and_card_id"

  create_table "slots", force: :cascade do |t|
    t.integer  "card_id"
    t.string   "queries"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "slots", ["card_id"], name: "index_slots_on_card_id"

  create_table "trigrams", force: :cascade do |t|
    t.string  "trigram",     limit: 3
    t.integer "score",       limit: 2
    t.integer "owner_id"
    t.string  "owner_type"
    t.string  "fuzzy_field"
  end

  add_index "trigrams", ["owner_id", "owner_type", "fuzzy_field", "trigram", "score"], name: "index_for_match"
  add_index "trigrams", ["owner_id", "owner_type"], name: "index_by_owner"

end
