def update_hmrc_manual_section_titles(dry_run: false)
  ContentItem.where(document_type: "").each do |ci|
    manual_content_id = GdsApi.publishing_api.lookup_content_id(ci.details["manual"]["base_path"])
    if content_id
      manual_content_id = GdsApi.publishing_api.get_live_content(manual_content_id)
      ci.details["manual"]["title"] = manual_content_id["title"]
      puts("Updating HMRC Manual Section #{ci.content_id} to set manual title to #{ci.details["manual"]["title"]}")
      ci.save unless dry_run
    else
      put("ERROR: Couldn't find manual content item for path #{ci.details["manual"]["base_path"]}")
    end
  end
end

namespace :update_hmrc_manual_sections do
  desc "Show hmrc_manual_section items that will be updated with the title of the containing manual"
  task dry_run: :environment do
    puts("DRY RUN (no actual changes will be saved)")
    update_hmrc_manual_section_titles(dry_run: true)
  end

  desc "Update hmrc_manual_section items with the title of the containing manual"
  task go: :environment do
    update_hmrc_manual_section_titles
  end
end
