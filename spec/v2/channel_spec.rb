require 'rspec'
require 'yaml'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Channel do
  before do
    WebMocks.load_dir(fixture('channel'))
  end

  after do
    WebMock.reset!
  end

  describe '.new' do
    it 'can be created from a hash' do
      hash = yaml_load('channel/colminigun.yml')
      c = Channel.new(hash)
      c.id.should == hash['_id']
      c.background_url.should == hash['background']
      c.banner_url.should == hash['banner']
      c.created_at.class.should == DateTime
      c.created_at.should < DateTime.now
      c.display_name.should == hash['display_name']
      c.game_name.should == hash['game']
      c.logo_url.should == hash['logo']
      c.name.should == hash['name']
      c.status.should == hash['status']
      c.updated_at.class.should == DateTime
      c.updated_at.should < DateTime.now
      c.url.should == hash['url']
      c.video_banner_url.should == hash['video_banner']
      c.mature?.should == hash['mature']
    end

    it 'has associated teams' do
      hash = yaml_load('channel/colminigun.yml')
      c = Channel.new(hash)
      c.teams.should_not be_nil
      c.teams.should_not be_empty
    end
  end
 
  describe '.get' do
    it 'creates a Channel from channel name' do
      c = Channel.get('colminigun')
      c.should_not be_nil
    end

    it 'handles channel name with URL characters' do
      c = Channel.get('foo/bar')
      c.should_not be_nil
    end

    it 'returns nil when channel does not exist' do
      c = Channel.get('does_not_exist')
      c.should be_nil
    end

    it 'returns nil when the channel is associated with a Justin.tv account' do
      c = Channel.get('desrow')
      c.should be_nil
    end
  end

  describe '.streaming?' do
    it 'returns true when a channel has a live stream' do
      c = Channel.get('incontroltv')
      c.should_not be_nil
      c.streaming?.should be_true
      c.stream.should_not be_nil
    end

    it 'returns false when a channel does not have a live stream' do
      c = Channel.get('lagtvmaximusblack')
      c.should_not be_nil
      c.streaming?.should be_false
      c.stream.should be_nil
    end
  end

  describe '#followers' do
    it 'returns the list of users following this channel' do
      c = Channel.get('osrusher')
      c.should_not be_nil
      f = c.followers
      f.should_not be_nil
      f.count.should == 533
      f.each { |u| u.class.should == User }
    end

    it 'limits the number of results based on the :limit parameter' do
      c = Channel.get('osrusher')
      c.should_not be_nil
      f = c.followers(:limit => 7)
      f.should_not be_nil
      f.count.should == 7
      f.each { |u| u.class.should == User }
    end
  end

  describe '.user' do
    it 'returns the user owning the channel' do
      c = Channel.get('nathanias')
      c.should_not be_nil
      u = c.user
      u.should_not be_nil
      c.name.should == u.name
    end
  end
end
