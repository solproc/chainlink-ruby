ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  include SpecHelpers

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.global_fixtures = :all

  config.before do
    stubbed_response = {from: "spec/support/mocks_and_stubs.rb"}.to_json

    allow_any_instance_of(BlockCypherClient).to receive(:get_transaction_hex)
      .and_return("01000000000000000000")

    allow_any_instance_of(BlockCypher::Api).to receive(:event_webhook_subscribe)
      .and_return('blah')
      # .and_return(canned_block_cypher_response)

    allow_any_instance_of(BlockCypher::Api).to receive(:blockchain_transaction)
      .and_return('blah')
      # .and_return(block_cypher_blockchain_transaction SecureRandom.hex)

    allow(CoordinatorClient).to receive(:get)
      .and_return(http_response body: {}.to_json)
    allow(CoordinatorClient).to receive(:post)
      .and_return(http_response body: {}.to_json)

    allow(EthereumClient).to receive(:post)
      .with("/", instance_of(Hash))
      .and_return(http_response body: ethereum_create_transaction_response.to_json)
    allow_any_instance_of(EthereumClient).to receive(:gas_price)
      .and_return(22_333)
    allow_any_instance_of(EthereumClient).to receive(:get_transaction_count)
      .and_return(rand 100_000)

    allow(HttpRetriever).to receive(:get)
      .and_return(stubbed_response)

    allow(InputAdapterClient).to receive(:post)
      .and_return(http_response body: stubbed_response)
    allow(InputAdapterClient).to receive(:get)
      .and_return(http_response body: stubbed_response)
    allow(InputAdapterClient).to receive(:delete)
      .and_return(http_response body: stubbed_response)
  end

  config.around bitcoin_network: :bitcoin do |example|
    Bitcoin.network = :bitcoin
    example.run
    Bitcoin.network = :testnet3
  end
end
