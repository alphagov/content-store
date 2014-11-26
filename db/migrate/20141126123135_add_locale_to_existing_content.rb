class AddLocaleToExistingContent < Mongoid::Migration
  def self.up
    ContentItem.renderable_content.update_all(locale: I18n.default_locale.to_s)
  end

  def self.down
    ContentItem.renderable_content.unset(:locale)
  end
end
