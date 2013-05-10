require 'rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Streams do
  before do
    WebMocks.load_dir('spec/fixtures/v2/streams')
  end

  describe '.all' do
  end

  describe '.where' do
    it 'requires some query parameter' do
      expect {
        Streams.where({})
      }.to raise_error(ArgumentError)
    end

    it 'requires some query parameter besides limit and offset' do
      expect {
        Streams.where(:limit => 10, :offset => 0)
      }.to raise_error(ArgumentError)
    end

    it 'can query streams by channel list' do
      s = Streams.where(:channel => ['mlgsc2', 'rootcatz', 'crs_saintvicious', 'phantoml0rd'])
      s.length.should == 4
    end

    it 'can query streams by game name' do
      s = Streams.where(:game => 'StarCraft II: Heart of the Swarm')
      s.length.should == 127
    end

    it 'can query streams by game name with limit' do
      s = Streams.where(:game => 'League of Legends', :limit => 10)
      s.length.should == 10
    end

    it 'can query by channel list when someone is not streaming' do
      s = Streams.where(:channel => ['leveluplive', 'djwheat'])
      s.length.should == 1
    end

    it 'can query by channel list and game name' do
      s = Streams.where(:channel => ['quantichyun', 'sc2sage'], :game => 'StarCraft II: Heart of the Swarm')
      s.length.should == 2
    end

    it 'filters out duplicate streams' do
      s = Streams.where(:game => 'Ultimate Marvel vs. Capcom 3')
      s.length.should == 2
    end

    it 'handles server errors' do
      # HTTP 500
    end
  end

  describe '.featured' do
  end
end
