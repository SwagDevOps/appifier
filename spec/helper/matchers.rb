# frozen_string_literal: true

# expect(something).to be_boolean
RSpec::Matchers.define :be_boolean do
  match do |value|
    [true, false].include? value
  end
end
