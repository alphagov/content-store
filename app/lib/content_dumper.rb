require "csv"
require "zlib"

class ContentDumper
  FIELDS = %w[base_path content_id locale document_type schema_name rendering_app publishing_app updated_at].freeze
  HASH_FIELDS = %w[details expanded_links routes redirects].freeze

  def initialize(filename)
    @filename = filename
  end

  def dump
    Zlib::GzipWriter.open(filename) do |file|
      csv = CSV.new(file)
      csv << csv_field_names
      ContentItem.each do |row|
        csv << csv_fields(row)
      end
    end
  end

private

  attr_reader :filename

  def csv_field_names
    FIELDS + HASH_FIELDS.map { |field| "#{field}_hash".to_sym }
  end

  def csv_fields(item)
    FIELDS.map { |field| item.send(field) } + HASH_FIELDS.map { |field| hash_field(item.send(field)) }
  end

  def hash_field(object)
    Digest::SHA1.hexdigest(
      JSON.generate(object),
    )
  end
end
