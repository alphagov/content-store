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

ActiveRecord::Schema[7.0].define(version: 2023_03_28_141957) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "content_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_path"], name: "index_content_items_on_base_path", unique: true
    t.index ["content_id"], name: "index_content_items_on_content_id"
    t.index ["created_at"], name: "index_content_items_on_created_at"
    t.index ["redirects"], name: "index_content_items_on_redirects", using: :gin
    t.index ["routes"], name: "index_content_items_on_routes", using: :gin
    t.index ["updated_at"], name: "index_content_items_on_updated_at"
  end

  create_table "publish_intents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "base_path"
    t.date "publish_time"
    t.string "publishing_app"
    t.string "rendering_app"
    t.string "routes", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_path"], name: "index_publish_intents_on_base_path", unique: true
    t.index ["created_at"], name: "index_publish_intents_on_created_at"
    t.index ["publish_time"], name: "index_publish_intents_on_publish_time"
    t.index ["routes"], name: "index_publish_intents_on_routes", using: :gin
    t.index ["updated_at"], name: "index_publish_intents_on_updated_at"
  end

  create_table "scheduled_publishing_log_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "base_path"
    t.string "document_type"
    t.datetime "scheduled_publication_time"
    t.bigint "delay_in_milliseconds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_path"], name: "ix_scheduled_pub_log_base_path"
    t.index ["created_at"], name: "ix_scheduled_pub_log_created"
    t.index ["scheduled_publication_time"], name: "ix_scheduled_pub_log_time"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "uid"
    t.string "email"
    t.string "permissions", array: true
    t.boolean "remotely_signed_out", default: false
    t.string "organisation_slug"
    t.boolean "disabled", default: false
    t.string "organisation_content_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["disabled"], name: "index_users_on_disabled"
    t.index ["email"], name: "index_users_on_email"
    t.index ["name"], name: "index_users_on_name"
    t.index ["organisation_content_id"], name: "index_users_on_organisation_content_id"
    t.index ["organisation_slug"], name: "index_users_on_organisation_slug"
    t.index ["uid"], name: "index_users_on_uid", unique: true
    t.index ["updated_at"], name: "index_users_on_updated_at"
  end

end
