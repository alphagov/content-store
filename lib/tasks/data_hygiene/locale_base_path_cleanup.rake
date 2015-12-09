namespace :data_hygiene do
  namespace :locale_base_path_cleanup do
    def report(cleanup: false)

      ContentItem.where(:locale.nin => ["en", nil]).each do |item|

        unless item.locale == item.base_path.split(".").last
          puts "locale/base_path mismatch for locale #{item.locale}"
          puts "    #{item.base_path} will be set to #{base_path_with_locale(item)}"
          puts

          if cleanup
            cloned = item.clone
            cloned.base_path = base_path_with_locale(item)
            cloned.description = item.description
            cloned.save!
            item.destroy
          end
        end
      end
    end

    def base_path_with_locale(item)
      "#{item.base_path}.#{item.locale}"
    end

    desc "Report on content_id for items that mismatch with the given file"
    task report: [:environment] do
      report
    end

    desc "Clean the content_id for items that mismatch with the given file"
    task cleanup: [:environment] do
      report(cleanup: true)
    end
  end
end
