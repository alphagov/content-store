require "rails_helper"

def postgres_listener(channel)
  queue = Queue.new

  Thread.new do
    conn = ActiveRecord::Base.lease_connection
    conn.execute("LISTEN #{channel}")
    loop do
      conn.raw_connection.wait_for_notify do |event, _id, _data|
        queue << event
      end
    end
  ensure
    conn.execute "UNLISTEN #{channel}"
  end

  # Wait for the thread to be ready to listen for nofitications
  sleep 0.1

  queue
end

describe "Postgres trigger", type: :request, skip_db_cleaner: true do
  before do
    # We need to use truncation instead of transaction to ensure the changes are commited and the trigger is fired
    DatabaseCleaner.clean
    DatabaseCleaner.strategy = :truncation
  end

  it "sends a notification when content item created" do
    listener = postgres_listener("route_changes")
    create(:content_item)

    expect(listener.pop).to eq("route_changes")
  end

  it "sends a notification when content item's routes are updated" do
    content_item = create(:content_item)

    listener = postgres_listener("route_changes")
    content_item.update!(
      routes: [{ "path" => content_item.base_path, "type" => "prefix" }],
    )

    expect(listener.pop).to eq("route_changes")
  end

  it "sends a notification when content item's redirects are updated" do
    content_item = create(:content_item)

    listener = postgres_listener("route_changes")
    content_item.update!(
      redirects: [{ "path" => content_item.base_path, "type" => "exact", "destination" => "/new" }],
    )

    expect(listener.pop).to eq("route_changes")
  end

  it "sends a notification when content item's schema name is updated" do
    content_item = create(:content_item)

    listener = postgres_listener("route_changes")
    content_item.update!(schema_name: "gone")

    expect(listener.pop).to eq("route_changes")
  end

  it "sends a notification when content item's rendering_app is updated" do
    content_item = create(:content_item)

    listener = postgres_listener("route_changes")
    content_item.update!(rendering_app: "new-frontend")

    expect(listener.pop).to eq("route_changes")
  end

  it "does not send a notification when content item's details are updated" do
    content_item = create(:content_item)

    listener = postgres_listener("route_changes")
    content_item.update!(details: { "body" => "change" })

    expect(listener).to be_empty
  end

  it "sends a notification when content item destroyed" do
    content_item = create(:content_item)
    listener = postgres_listener("route_changes")
    content_item.destroy!

    expect(listener.pop).to eq("route_changes")
  end

  it "sends a notification when publish intent created" do
    listener = postgres_listener("route_changes")
    create(:publish_intent)

    expect(listener.pop).to eq("route_changes")
  end

  it "sends a notification when publish intent updated" do
    publish_intent = create(:publish_intent)
    listener = postgres_listener("route_changes")
    publish_intent.update!(rendering_app: "updated")

    expect(listener.pop).to eq("route_changes")
  end

  it "sends a notification when publish intent destroyed" do
    publish_intent = create(:publish_intent)
    listener = postgres_listener("route_changes")
    publish_intent.destroy!

    expect(listener.pop).to eq("route_changes")
  end
end
