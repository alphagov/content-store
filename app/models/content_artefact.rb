 class ContentArtefact
  include Mongoid::Document

  field :base_path,   type: String # Full URL path, e.g /government/thing
  field :title,       type: String
  field :description, type: String
  field :format,      type: String
  field :need_ids,    type: Array
  field :updated_at,  type: DateTime
  field :details,     type: Hash

  index({:base_path => 1}, :unique => true)

  validates :base_path, uniqueness: true, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :format, presence: true
  validates :need_ids, presence: true
  validates :updated_at, presence: true

  def self.find_by_base_path(base_path)
    where(base_path: base_path).first
  end

  def as_json(options={})
    # We don't want to reveal the MongoDB internals
    super(options).except('_id')
  end
end
