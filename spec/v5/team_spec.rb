require 'rspec'
require 'yaml'
require 'kappa'
require 'common'
require 'uri'

include Twitch::V2

describe Twitch::V2::Team do
  before do
    WebMocks.load_dir(fixture('team'))
  end

  after do
    WebMock.reset!
  end

  describe '.new' do
    it 'can be created from a hash' do
      hash = yaml_load('team/eg.yml')
      t = Team.new(hash)
      expect(t.id).to eq(hash['_id'])
      expect(t.logo_url).to eq(hash['logo'])
      expect(t.display_name).to eq(hash['display_name'])
      expect(t.background_url).to eq(hash['background'])
      expect(t.updated_at.class).to eq(Time)
      expect(t.updated_at).to be < Time.now
      expect(t.updated_at.utc?).to be_truthy
      expect(t.created_at.class).to eq(Time)
      expect(t.created_at).to be < Time.now
      expect(t.created_at.utc?).to be_truthy
      expect(t.info).to eq(hash['info'])
      expect(t.banner_url).to eq(hash['banner'])
      expect(t.name).to eq(hash['name'])
    end
  end

  describe '#url' do
    it 'should return a valid URI' do
      t = Twitch.teams.get('teamliquid')
      expect(t).not_to be_nil
      u = t.url
      expect(u).not_to be_nil
      uri = URI.parse(u)
      expect(uri.class).to eq(URI::HTTP)
    end
  end
end

describe Twitch::V2::Teams do
  before do
    WebMocks.load_dir(fixture('team'))
  end

  after do
    WebMock.reset!
  end
  
  describe '#get' do
    it 'creates a Team from team name' do
      t = Twitch.teams.get('teamliquid')
      expect(t).not_to be_nil
    end

    it 'returns nil when team does not exist' do
      t = Twitch.teams.get('does_not_exist')
      expect(t).to be_nil
    end
  end

  describe '#all' do
    it 'returns all teams by default' do
      t = Twitch.teams.all
      expect(t.count).to eq(486)
    end

    it 'returns a limited number of teams when specified' do
      t = Twitch.teams.all(:limit => 10)
      expect(t.count).to eq(10)
    end
  end
end
