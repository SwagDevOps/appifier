# frozen_string_literal: true

autoload(:YAML, 'yaml')

# Return samples as a Hash with results indexed by name
info = lambda do
  {}.tap do |samples|
    samples[:answer] = 42
  end
end

# @formatter:off
{
  samples: info.call
}
# @formatter:on
