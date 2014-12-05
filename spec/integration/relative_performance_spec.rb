require 'rails_helper'
require 'benchmark'

describe "relative performance", :type => :request do

  it "does not significantly slow down when expanding links" do
    item1 = create(:content_item, :with_content_id)
    baseline_item = create(:content_item, :with_content_id, :base_path => "/no-links", :links => {"related" => [item1.content_id]})

    test_item = build(:content_item, :with_content_id, :base_path => "/lots-of-links", :links => {"testing" => []})
    100.times do |n|
      item = create(:content_item, :with_content_id)
      test_item.links["testing"] << item.content_id
    end
    test_item.save!

    baseline = Benchmark.realtime { get "/content/no-links" }
    actual = Benchmark.realtime { get "/content/lots-of-links" }

    # FIXME: remove puts once we're sure the threshold is tuned correctly
    puts "\nlinks times - baseline: #{baseline}, actual: #{actual}\n"
    expect(actual).to be_within(4 * baseline).of(baseline)
  end

  it "does not significantly slow down when expanding translations" do
    baseline_item = create(:content_item, :with_content_id, :base_path => "/no-translations")

    test_item = create(:content_item, :with_content_id, :base_path => "/lots-of-translations")
    I18n.available_locales.each do |locale|
      next if locale == :en
      create(:content_item, :content_id => test_item.content_id, :locale => locale.to_s)
    end

    baseline = Benchmark.realtime { get "/content/no-translations" }
    actual = Benchmark.realtime { get "/content/lots-of-translations" }

    # FIXME: remove puts once we're sure the threshold is tuned correctly
    puts "\ntranslation times - baseline: #{baseline}, actual: #{actual}\n"
    expect(actual).to be_within(4 * baseline).of(baseline)
  end
end
