namespace :data_hygiene do
  def write_file(report_path, content_items)
    File.open(report_path, "w") do |file|
      file.puts "content_id,public_updated_at,publishing_app,base_path"
      file.puts content_items.join("\n")
    end

    puts "#{content_items.size} missing values assigned."
    puts "Details written to #{report_path}"
  end

  desc "Generates a content_id for content items that do not have one"
  task generate_content_id: :environment do
    content_items = []

    ContentItem.where(content_id: nil).each do |item|
      item.set(content_id: SecureRandom.uuid)

      content_items << "#{item.content_id},#{item.public_updated_at},#{item.publishing_app},#{item.base_path}"
    end

    write_file("./tmp/generated_content_ids.txt", content_items)
  end

  desc "Generate a content_id where missing, but reuse where possible from IMPORT_PATH"
  task reuse_content_id: :environment do
    import_path = ENV.fetch("IMPORT_PATH")
    lines = File.read(import_path).split("\n")
    lines = lines[1..-1]

    hash = lines.each.with_object({}) do |line, memo|
      content_id, _, _, base_path = line.split(",")
      memo[base_path] = content_id
    end

    content_items = []

    ContentItem.where(content_id: nil).each do |item|
      content_id = hash[item.base_path]

      item.set(content_id: content_id || SecureRandom.uuid)

      content_items << "#{item.content_id},#{item.public_updated_at},#{item.publishing_app},#{item.base_path}"
    end

    write_file("./tmp/reused_content_ids.txt", content_items)
  end

  desc "Assigns a public_updated_at for content items that do not have one"
  task assign_public_updated_at: :environment do
    content_items = []

    ContentItem.where(public_updated_at: nil).each do |item|
      item.set(public_updated_at: item.updated_at)

      content_items << "#{item.content_id},#{item.public_updated_at},#{item.publishing_app},#{item.base_path}"
    end

    write_file("./tmp/assigned_public_updated_at.txt", content_items)
  end
end
