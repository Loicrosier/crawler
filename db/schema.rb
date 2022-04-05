# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_04_05_141326) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hxerrors", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.string "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["page_id"], name: "index_hxerrors_on_page_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "url"
    t.text "content"
    t.bigint "site_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "canonical", default: false
    t.string "meta_description"
    t.index ["site_id"], name: "index_pages_on_site_id"
  end

  create_table "seoerrors", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.string "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "ligne"
    t.index ["page_id"], name: "index_seoerrors_on_page_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "hxerrors", "pages"
  add_foreign_key "pages", "sites"
  add_foreign_key "seoerrors", "pages"
end
