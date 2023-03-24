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

ActiveRecord::Schema[7.0].define(version: 2023_03_20_150042) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "content_items", id: false, force: :cascade do |t|
    t.string "base_path"
    t.string "content_id"
    t.string "title"
    t.jsonb "description", default: {"value"=>nil}
    t.string "document_type"
    t.string "content_purpose_document_supertype", default: ""
    t.string "content_purpose_subgroup", default: ""
    t.string "content_purpose_supergroup", default: ""
    t.string "email_document_supertype", default: ""
    t.string "government_document_supertype", default: ""
    t.string "navigation_document_supertype", default: ""
    t.string "search_user_need_document_supertype", default: ""
    t.string "user_journey_document_supertype", default: ""
    t.string "schema_name"
    t.string "locale", default: "en"
    t.datetime "first_published_at"
    t.datetime "public_updated_at"
    t.datetime "publishing_scheduled_at"
    t.integer "scheduled_publishing_delay_seconds"
    t.jsonb "details", default: {}
    t.string "publishing_app"
    t.string "rendering_app"
    t.string "routes", default: [], array: true
    t.string "redirects", default: [], array: true
    t.jsonb "expanded_links", default: {}
    t.jsonb "access_limited", default: {}
    t.string "auth_bypass_ids", default: [], array: true
    t.string "phase", default: "live"
    t.string "analytics_identifier"
    t.integer "payload_version"
    t.jsonb "withdrawn_notice", default: {}
    t.string "publishing_request_id"
    t.index ["base_path"], name: "index_content_items_on_base_path", unique: true
    t.index ["content_id"], name: "index_content_items_on_content_id"
  end

end
