require 'rspec'
require 'yaml'
require 'kappa'
require 'common'

include Twitch::V2

describe Twitch::V2::Channel do
  before do
    WebMocks.load_dir(fixture('channel'))
  end

  after do
    WebMock.reset!
  end

  describe '.new' do
    it 'can be created from a hash' do
      hash = yaml_load('channel/colminigun.yml')
      c = Channel.new(hash, nil)
      c.id.should == hash['_id']
      c.background_url.should == hash['background']
      c.banner_url.should == hash['banner']
      c.created_at.class.should == Time
      c.created_at.should < Time.now
      c.created_at.utc?.should be_true
      c.display_name.should == hash['display_name']
      c.game_name.should == hash['game']
      c.logo_url.should == hash['logo']
      c.name.should == hash['name']
      c.status.should == hash['status']
      c.updated_at.class.should == Time
      c.updated_at.should < Time.now
      c.updated_at.utc?.should be_true
      c.url.should == hash['url']
      c.video_banner_url.should == hash['video_banner']
      c.mature?.should == hash['mature']
    end

    it 'has associated teams' do
      hash = yaml_load('channel/colminigun.yml')
      c = Channel.new(hash, nil)
      c.teams.should_not be_nil
      c.teams.should_not be_empty
    end
  end

  describe '#streaming?' do
    it 'returns true when a channel has a live stream' do
      c = Twitch.channels.get('incontroltv')
      c.should_not be_nil
      c.streaming?.should be_true
      c.stream.should_not be_nil
    end

    it 'returns false when a channel does not have a live stream' do
      c = Twitch.channels.get('lagtvmaximusblack')
      c.should_not be_nil
      c.streaming?.should be_false
      c.stream.should be_nil
    end
  end

  describe '#followers' do
    it 'returns the list of users following this channel' do
      c = Twitch.channels.get('osrusher')
      c.should_not be_nil
      f = c.followers
      f.should_not be_nil
      f.count.should == 533
      f.each { |u| u.class.should == User }
    end

    it 'limits the number of results based on the :limit parameter' do
      c = Twitch.channels.get('osrusher')
      c.should_not be_nil
      f = c.followers(:limit => 7)
      f.should_not be_nil
      f.count.should == 7
      f.each { |u| u.class.should == User }
    end
  end

  describe '#user' do
    it 'returns the user owning the channel' do
      c = Twitch.channels.get('nathanias')
      c.should_not be_nil
      u = c.user
      u.should_not be_nil
      c.name.should == u.name
    end
  end

  describe '#videos' do
    it 'returns broadcasts' do
      c = Twitch.channels.get('ms_vixen')
      c.should_not be_nil
      v = c.videos(:type => :broadcasts, :limit => 75)
      v.should_not be_nil
      v.count.should == 75
    end

    it 'returns highlights' do
      c = Twitch.channels.get('ms_vixen')
      c.should_not be_nil
      v = c.videos(:type => :highlights, :limit => 50)
      v.should_not be_nil
      v.count.should == 50
    end

    it 'rejects :type if not :broadcats or :highlights' do
      expect {
        c = Twitch.channels.get('ms_vixen')
        c.should_not be_nil
        v = c.videos(:type => :invalid)
      }.to raise_error(ArgumentError)
    end
  end
end

describe Twitch::V2::Channels do
  before do
    WebMocks.load_dir(fixture('channel'))
  end

  after do
    WebMock.reset!
  end
 
  describe '#get' do
    it 'creates a Channel from channel name' do
      c = Twitch.channels.get('colminigun')
      c.should_not be_nil
    end

    it 'handles channel name with URL characters' do
      c = Twitch.channels.get('foo/bar')
      c.should_not be_nil
    end

    it 'returns nil when channel does not exist' do
      c = Twitch.channels.get('does_not_exist')
      c.should be_nil
    end

    it 'returns nil when the channel is associated with a Justin.tv account' do
      c = Twitch.channels.get('desrow')
      c.should be_nil
    end
  end
end
