class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :_id, :as => :base_path, :type => String
  field :title, :type => String
  field :description, :type => String
  field :format, :type => String
  field :need_ids, :type => Array, :default => []
  field :public_updated_at, :type => DateTime
  field :details, :type => Hash, :default => {}

  PUBLIC_ATTRIBUTES = %w(base_path title description format need_ids public_updated_at details).freeze

  validates :base_path, uniqueness: true, absolute_path: true
  validates :title, :format, :presence => true

  def as_json(options = nil)
    super(options).slice(*PUBLIC_ATTRIBUTES).tap do |hash|
      hash["base_path"] = self.base_path
      hash["errors"] = self.errors.as_json.stringify_keys if self.errors.any?
    end
  end
end
