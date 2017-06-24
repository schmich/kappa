require 'rspec'
require 'kappa'
require_relative 'common'

include Twitch::V2

describe Twitch::V2::Game do
  before do
    WebMocks.load_dir(fixture('game'))
  end

  after do
    WebMock.reset!
  end

  describe '.new' do
    it 'accepts a hash' do
      hash = yaml_load('game/game.yml')
      g = Game.new(hash, nil)
      expect(g).not_to be_nil
      expect(g.id).to eq(hash['game']['_id'])
      expect(g.name).to eq(hash['game']['name'])
      expect(g.giantbomb_id).to eq(hash['game']['giantbomb_id'])
      expect(g.channel_count).to eq(hash['channels'])
      expect(g.viewer_count).to eq(hash['viewers'])
      expect(g.box_images).not_to be_nil
      expect(g.box_images.class).to eq(Images)
      expect(g.logo_images).not_to be_nil
      expect(g.logo_images.class).to eq(Images)
    end
  end

  describe '#streams' do
    it 'returns a list of streams' do
      g = Twitch.games.top(:limit => 3).first
      expect(g).not_to be_nil
      s = g.streams
      expect(s).not_to be_nil
      expect(s.count).to eq(99)
    end

    it 'accepts a block' do
      g = Twitch.games.top(:limit => 3).first
      expect(g).not_to be_nil
      i = 0
      g.streams do |stream|
        i += 1
      end
      expect(i).to eq(99)
    end
  end
end

describe Twitch::V2::Games do
  before do
    WebMocks.load_dir(fixture('game'))
  end

  after do
    WebMock.reset!
  end

  describe '.top' do
    it 'returns a list of top games' do
      g = Twitch.games.top
      expect(g).not_to be_nil
      g.each { |s| expect(s.class).to eq(Game) }
      expect(g.count).to eq(445)
    end

    it 'limits results with the :limit parameter' do
      g = Twitch.games.top(:limit => 3)
      expect(g).not_to be_nil
      g.each { |s| expect(s.class).to eq(Game) }
      expect(g.count).to eq(3)
    end

    it 'can be filtered with the :hls parameter' do
      g = Twitch.games.top(:hls => true, :limit => 3)
      expect(g).not_to be_nil
      expect(g).not_to be_empty
      expect(g.count).to eq(3)
    end

    it 'returns results offset by the :offset parameter' do
      g = Twitch.games.top(:offset => 5, :limit => 5)
      expect(g).not_to be_nil
      expect(g).not_to be_empty
      expect(g.count).to eq(5)
    end
  end

  describe '.find' do
    it 'returns a list of game suggestions' do
      g = Twitch.games.find(:name => 'starcraft')
      expect(g).not_to be_nil
      expect(g.count).to eq(7)
      g.each { |s| expect(s.class).to eq(GameSuggestion) }
    end

    it 'returns a list of game suggestions that are live' do
      g1 = Twitch.games.find(:name => 'diablo')
      expect(g1).not_to be_nil
      g2 = Twitch.games.find(:name => 'diablo', :live => true)
      expect(g2).not_to be_nil
      expect(g1.count).to be > g2.count
    end

    it 'requires :name to be specified' do
      expect {
        Twitch.games.find
      }.to raise_error(ArgumentError)

      expect {
        Twitch.games.find(:live => true)
      }.to raise_error(ArgumentError)

      expect {
        Twitch.games.find({})
      }.to raise_error(ArgumentError)
    end

    it 'requires a valid hash to be specified' do
      expect {
        Twitch.games.find(nil)
      }.to raise_error(ArgumentError)
    end

    it 'handles empty results' do
      g = Twitch.games.find(:name => 'empty_results')
      expect(g).not_to be_nil
      expect(g).to be_empty
    end
  end
end

describe Twitch::V2::GameSuggestion do
  describe '.new' do
    it 'accepts a hash' do
      hash = yaml_load('game/game_suggestion.yml')
      g = GameSuggestion.new(hash)
      expect(g).not_to be_nil
      expect(g.id).to eq(hash['_id'])
      expect(g.name).to eq(hash['name'])
      expect(g.giantbomb_id).to eq(hash['giantbomb_id'])
      expect(g.popularity).to eq(hash['popularity'])
      expect(g.box_images).not_to be_nil
      expect(g.box_images.class).to eq(Images)
      expect(g.logo_images).not_to be_nil
      expect(g.logo_images.class).to eq(Images)
    end
  end
end
