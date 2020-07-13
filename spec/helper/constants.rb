# frozen_string_literal: true

autoload(:Pathname, 'pathname')

# Constants ----------------------------------------------------------

SPEC_DIR     = Pathname.new('spec')
SAMPLES_PATH = SPEC_DIR.join('samples')
