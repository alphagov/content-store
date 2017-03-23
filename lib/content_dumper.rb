require "csv"
require "zlib"

class ContentDumper
  FIELDS = %w(base_path content_id locale document_type schema_name rendering_app publishing_app updated_at).freeze

  def initialize(filename)
    @filename = filename
  end

  def dump
    Zlib::GzipWriter.open(filename) do |file|
      csv = CSV.new(file)
      csv << FIELDS
      ContentItem.each do |route|
        csv << FIELDS.map { |field| route.send(field) }
      end
    end
  end

private

  attr_reader :filename
end
