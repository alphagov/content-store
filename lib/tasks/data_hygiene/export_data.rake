require "tasks/data_hygiene/export_data"

namespace :data_hygiene do
  namespace :export_content_items do
    desc "Exports all content items to ./tmp as JSON, including separate timestamps"
    task all: [:environment] do
      File.open(Rails.root + "tmp/content_items_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.json", "w") do |file|
        Tasks::DataHygiene::ExportData.new(file, STDOUT).export_all
      end
    end
  end
end
