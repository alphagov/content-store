namespace :data_hygiene do
  namespace :export_content_items do
    desc "Exports all content items to ./tmp as JSON, including separate timestamps"
    task all: [:environment] do
      File.open(Rails.root + "tmp/content_items_#{Time.zone.now.strftime('%Y-%m-%d_%H-%M-%S')}.json", "w") do |file|
        DataHygiene::ExportData.new(file, $stdout).export_all
      end
    end
  end
end
