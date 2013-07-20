require 'rspec'
require 'yaml'
require 'kappa'
require 'common'
require 'securerandom'
require 'webmock/rspec'

include Kappa::V2

describe Kappa do
  before do
    WebMocks.load_dir(fixture('configuration'))
  end

  after do
    WebMock.reset!
  end

  describe '.configure' do
    it 'can configure client_id' do
      client_id = SecureRandom.uuid

      Kappa.configure do |config|
        config.client_id = client_id
      end

      Kappa::Configuration.instance.client_id.should == client_id
    end

    it 'sets Client-ID header if client_id is set' do
      client_id = SecureRandom.uuid

      Kappa.configure do |config|
        config.client_id = client_id
      end

      c = Channel.get('giantwaffle')
      c.should_not be_nil

      a_request(:get, 'https://api.twitch.tv/kraken/channels/giantwaffle')
        .with(:headers => { 'Client-ID' => client_id })
        .should have_been_made.once
    end
  end
end
