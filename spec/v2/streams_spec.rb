require 'rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Streams do
  before do
    WebMocks.load_dir(fixture('streams'))
  end

  after do
    WebMock.reset!
  end

  describe '.all' do
  end

  describe '.find' do
    it 'requires some query parameter' do
      expect {
        Streams.find({})
      }.to raise_error(ArgumentError)
    end

    it 'requires some query parameter besides limit and offset' do
      expect {
        Streams.find(:limit => 10, :offset => 0)
      }.to raise_error(ArgumentError)
    end

    it 'can query streams by channel list' do
      s = Streams.find(:channel => ['mlgsc2', 'rootcatz', 'crs_saintvicious', 'phantoml0rd'])
      s.length.should == 4
    end

    it 'can query streams by game name' do
      s = Streams.find(:game => 'StarCraft II: Heart of the Swarm')
      s.length.should == 156
    end

    it 'can query streams by game name with limit' do
      s = Streams.find(:game => 'League of Legends', :limit => 10)
      s.length.should == 10
    end

    it 'can query by channel list when someone is not streaming' do
      s = Streams.find(:channel => ['leveluplive', 'djwheat'])
      s.length.should == 1
    end

    it 'can query by channel list and game name' do
      s = Streams.find(:channel => ['quantichyun', 'sc2sage'], :game => 'StarCraft II: Heart of the Swarm')
      s.length.should == 2
    end

    it 'filters out duplicate streams' do
      s = Streams.find(:game => 'Ultimate Marvel vs. Capcom 3')
      s.length.should == 2
    end

    it 'handles server errors' do
      # TODO: HTTP 500
    end

    # TODO: It can handle :channel channels with URL characters in their name.
  end

  # TODO: Streams.featured
  describe '.featured' do
  end

  # TODO: Streams.all

  # TODO: Test Streams.find with > 100 channels (force pagination).
  # See sc2daily for example.
end
