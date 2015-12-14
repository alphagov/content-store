class AddOrganisationToContactLinks < Mongoid::Migration
  def self.up
    ContentItem.where(format: "contact").each do |contact|
      organisation_title = contact.details["organisation"]["title"]
      contact.links[:organisations] = [content_store_organisation(organisation_title).content_id]
      contact.save!
    end
  end

  def self.down
  end

  def self.content_store_organisation(organisation_title)
    content_store_organisations.select { |org| org.title == organisation_title }.last
  end

  def self.content_store_organisations
    @_content_store_organisations ||= ContentItem.where(format: 'placeholder_organisation')
  end
end
