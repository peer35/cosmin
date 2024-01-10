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

ActiveRecord::Schema.define(version: 2021_10_20_111110) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_type"
    t.string "document_id"
    t.string "document_type"
    t.binary "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_bookmarks_on_document_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.text "cat"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "instruments", id: :serial, force: :cascade do |t|
    t.text "name"
    t.text "reference"
    t.text "doi"
    t.text "pmid"
    t.text "refurl"
    t.text "url1"
    t.text "url2"
    t.text "url3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "status"
  end

  create_table "instruments_records", id: false, force: :cascade do |t|
    t.integer "record_id"
    t.integer "instrument_id"
    t.index ["instrument_id", "record_id"], name: "by_instruments_and_records", unique: true
    t.index ["instrument_id"], name: "index_instruments_records_on_instrument_id"
    t.index ["record_id"], name: "index_instruments_records_on_record_id"
  end

  create_table "records", id: :serial, force: :cascade do |t|
    t.integer "cosmin_id"
    t.text "abstract"
    t.text "accnum"
    t.text "author"
    t.text "bpv"
    t.boolean "cu"
    t.text "disease"
    t.text "doi"
    t.text "fs"
    t.text "ghp"
    t.text "instrument"
    t.text "issn"
    t.text "issue"
    t.text "journal"
    t.text "oc"
    t.text "oql"
    t.text "pnp"
    t.text "age"
    t.integer "pubyear"
    t.text "ss"
    t.text "startpage"
    t.text "title"
    t.text "tmi"
    t.text "url"
    t.text "user_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "admin_notes"
    t.text "status"
    t.integer "endnum"
  end

  create_table "searches", id: :serial, force: :cascade do |t|
    t.binary "query_params"
    t.integer "user_id"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guest", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "instruments_records", "instruments"
  add_foreign_key "instruments_records", "records"
end
