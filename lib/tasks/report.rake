require "csv"

namespace :report do
  desc "Run a publication delay report of the last week"
  task publication_delay_report: :environment do
    PublicationDelayReport.call($stdout)
  end

  desc "Find all references to search term"
  task :find_specific_term_references, %i[term] => [:environment] do |_, args|
    FindSpecificTerm.call(args[:term])
  end

  desc "Find all references to search term excluding document types"
  task :find_specific_term_references_excluding_types, %i[term exclude_types] => [:environment] do |_, args|
    raise "Missing excluded document types parameter" unless args[:exclude_types]

    exclude_types = args[:exclude_types].split(" ")
    FindSpecificTerm.call(args[:term], exclude_types)
  end

  desc "Finds all references to a word being used across full details' fields - pass in comma separated list of words"
  task word_usages: :environment do |_, args|
    checked = 0
    total = ContentItem.count
    found = []
    words = args.extras.to_a.uniq

    ContentItem.order_by([:base_path, :asc]).each_slice(1000) do |group|
      group.each do |item|
        to_check = "#{item.title} #{item.description} #{item.details.to_s}"
        matches = []
        # find where search term is either the start/end of a string or surrounded by non-alphnamumeric characters
        words.each { |word| matches << word if to_check.match?(/((?:\A|\W)#{word}(?:\W|\Z))/i) }

        if matches.any?
          found << {
            title: item.title,
            url: ("https://www.gov.uk#{item.base_path}" if item.base_path),
            content_api_url: ("https://www.gov.uk/api/content#{item.base_path}" if item.base_path),
            words: matches.join(","),
            publishing_app: item.publishing_app,
            primary_publishing_organisation:  item.expanded_links.dig(:primary_publishing_organisation, 0, :title),
            document_type: item.document_type,
            content_id: item.content_id
          }
        end

        checked += 1
      end

      puts "checked #{checked}/#{total}"
    end

    puts "Completed search, found #{found.size} matches"

    next unless found.any?

    puts "Outputting matches CSV"

    csv_string = CSV.generate do |csv|
      csv << found.first.keys
      found.each do |item|
        csv << item.values
      end
    end

    puts csv_string
  end
end
