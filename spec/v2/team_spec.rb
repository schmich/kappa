require 'rspec'
require 'yaml'
require 'kappa'
require 'common'
require 'uri'

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
      t.id.should == hash['_id']
      t.logo_url.should == hash['logo']
      t.display_name.should == hash['display_name']
      t.background_url.should == hash['background']
      t.updated_at.class.should == Time
      t.updated_at.should < Time.now
      t.updated_at.utc?.should be_true
      t.created_at.class.should == Time
      t.created_at.should < Time.now
      t.created_at.utc?.should be_true
      t.info.should == hash['info']
      t.banner_url.should == hash['banner']
      t.name.should == hash['name']
    end
  end

  describe '#url' do
    it 'should return a valid URI' do
      t = Twitch.teams.get('teamliquid')
      t.should_not be_nil
      u = t.url
      u.should_not be_nil
      uri = URI.parse(u)
      uri.class.should == URI::HTTP
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
      t.should_not be_nil
    end

    it 'returns nil when team does not exist' do
      t = Twitch.teams.get('does_not_exist')
      t.should be_nil
    end
  end

  describe '#all' do
    it 'returns all teams by default' do
      t = Twitch.teams.all
      t.count.should == 486
    end

    it 'returns a limited number of teams when specified' do
      t = Twitch.teams.all(:limit => 10)
      t.count.should == 10
    end
  end
end
