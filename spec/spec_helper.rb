# frozen_string_literal: true

require "dividendo_crawler"
require "vcr"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = false
  config.configure_rspec_metadata!
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :faraday
  # For debugging uncomment this line
  # config.debug_logger = $stdout
  config.default_cassette_options = {
    # Change to :once or :new_episodes if you add new end-points that need a cassette to be recorded
    record: :new_episodes,
    allow_playback_repeats: true,
    decode_compressed_response: true
  }
end
