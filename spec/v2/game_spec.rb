require 'rspec'
require 'kappa'
require 'common'

describe Twitch::V2::Game, :game => true do
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
      g.should_not be_nil
      g.id.should == hash['game']['_id']
      g.name.should == hash['game']['name']
      g.giantbomb_id.should == hash['game']['giantbomb_id']
      g.channel_count.should == hash['channels']
      g.viewer_count.should == hash['viewers']
      g.box_images.should_not be_nil
      g.box_images.class.should == Images
      g.logo_images.should_not be_nil
      g.logo_images.class.should == Images
    end
  end

  describe '#streams' do
    it 'returns a list of streams' do
      g = Twitch.games.top(:limit => 3).first
      g.should_not be_nil
      s = g.streams
      s.should_not be_nil
      s.count.should == 99
    end

    it 'accepts a block' do
      g = Twitch.games.top(:limit => 3).first
      g.should_not be_nil
      i = 0
      g.streams do |stream|
        i += 1
      end
      i.should == 99
    end
  end
end

describe Twitch::V2::Games, :game => true do
  before do
    WebMocks.load_dir(fixture('game'))
  end

  after do
    WebMock.reset!
  end

  describe '.top' do
    it 'returns a list of top games' do
      g = Twitch.games.top
      g.should_not be_nil
      g.each { |s| s.class.should == Game }
      g.count.should == 445
    end

    it 'limits results with the :limit parameter' do
      g = Twitch.games.top(:limit => 3)
      g.should_not be_nil
      g.each { |s| s.class.should == Game }
      g.count.should == 3
    end

    it 'can be filtered with the :hls parameter' do
      g = Twitch.games.top(:hls => true, :limit => 3)
      g.should_not be_nil
      g.should_not be_empty
      g.count.should == 3
    end

    it 'returns results offset by the :offset parameter' do
      g = Twitch.games.top(:offset => 5, :limit => 5)
      g.should_not be_nil
      g.should_not be_empty
      g.count.should == 5
    end
  end

  describe '.find' do
    it 'returns a list of game suggestions' do
      g = Twitch.games.find(:name => 'starcraft')
      g.should_not be_nil
      g.count.should == 7
      g.each { |s| s.class.should == GameSuggestion }
    end

    it 'returns a list of game suggestions that are live' do
      g1 = Twitch.games.find(:name => 'diablo')
      g1.should_not be_nil
      g2 = Twitch.games.find(:name => 'diablo', :live => true)
      g2.should_not be_nil
      g1.count.should > g2.count
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
      g.should_not be_nil
      g.should be_empty
    end
  end
end

describe Twitch::V2::GameSuggestion, :game => true do
  describe '.new' do
    it 'accepts a hash' do
      hash = yaml_load('game/game_suggestion.yml')
      g = GameSuggestion.new(hash)
      g.should_not be_nil
      g.id.should == hash['_id']
      g.name.should == hash['name']
      g.giantbomb_id.should == hash['giantbomb_id']
      g.popularity.should == hash['popularity']
      g.box_images.should_not be_nil
      g.box_images.class.should == Images
      g.logo_images.should_not be_nil
      g.logo_images.class.should == Images
    end
  end
end
