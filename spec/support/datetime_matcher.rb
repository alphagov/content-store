RSpec::Matchers.define :match_datetime do |expected|
  match do |actual|
    actual = Time.zone.parse(actual) if actual.is_a?(String)
    expected = Time.zone.parse(expected) if expected.is_a?(String)
    actual.to_i == expected.to_i
  end

  diffable

  failure_message do |actual|
    "expected that #{actual} would be be the same time as #{expected}"
  end
  failure_message_when_negated do |actual|
    "expected that #{actual} would not be be the same time as #{expected}"
  end
end
