class BackfillSchemaNameAndDocumentType < Mongoid::Migration
  def self.up
    js = <<-EOF
    db.content_items.find({"schema_name": null}).forEach( function (content_item) {
      content_item.schema_name = content_item.format;
      content_item.document_type = content_item.format;
      db.content_items.save(content_item);
    });
    EOF

    cmd = {
      "$eval" => js,
      "nolock" => true,
    }

    result = ContentItem.collection.database.command(cmd)
  end

  def self.down; end
end
