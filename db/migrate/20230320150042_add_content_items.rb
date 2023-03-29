class AddContentItems < ActiveRecord::Migration[7.0]
  def change
    create_table :content_items, id: :uuid do |t|
      t.string    :base_path, unique: true
      t.string    :content_id
      t.string    :title
      t.jsonb     :description, default: { "value" => nil }
      t.string    :document_type

      # Supertypes are deprecated, but are still sent by the publishing-api.
      t.string    :content_purpose_document_supertype, default: ""
      t.string    :content_purpose_subgroup, default: ""
      t.string    :content_purpose_supergroup, default: ""
      t.string    :email_document_supertype, default: ""
      t.string    :government_document_supertype, default: ""
      t.string    :navigation_document_supertype, default: ""
      t.string    :search_user_need_document_supertype, default: ""
      t.string    :user_journey_document_supertype, default: ""

      t.string    :schema_name
      t.string    :locale, default: I18n.default_locale.to_s
      t.datetime  :first_published_at
      t.datetime  :public_updated_at
      t.datetime  :publishing_scheduled_at
      t.integer   :scheduled_publishing_delay_seconds
      t.jsonb     :details, default: {}
      t.string    :publishing_app
      t.string    :rendering_app
      t.string    :routes, array: true, default: []
      t.string    :redirects, array: true, default: []
      t.jsonb     :expanded_links, default: {}
      t.jsonb     :access_limited, default: {}
      t.string    :auth_bypass_ids, array: true, default: []
      t.string    :phase, default: "live"
      t.string    :analytics_identifier
      t.integer   :payload_version
      t.jsonb     :withdrawn_notice, default: {}
      t.string    :publishing_request_id, null: true, default: nil

      t.timestamps
    end

    add_index :content_items, :base_path, unique: true
    add_index :content_items, :content_id
    add_index :content_items, :created_at
    add_index :content_items, :updated_at
  end
end
