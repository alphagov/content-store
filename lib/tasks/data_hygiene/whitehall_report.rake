require "tasks/data_hygiene/whitehall_report"

namespace :data_hygiene do
  desc "Report on content items from Whitehall data based on the publishing_export task in Whitehall"
  task whitehall_report: :environment do
    csv_path = ENV["CSV_PATH"]

    unless csv_path
      message = "You need to set the CSV_PATH environment variable"
      message << "\nYou can generate the CSV by running rake publishing_export in Whitehall"

      raise ArgumentError, message
    end

    WhitehallReport.run(csv_path)
  end
end
