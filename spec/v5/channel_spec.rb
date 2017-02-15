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
      expect(c.id).to eq(hash['_id'])
      expect(c.background_url).to eq(hash['background'])
      expect(c.banner_url).to eq(hash['banner'])
      expect(c.created_at.class).to eq(Time)
      expect(c.created_at).to be < Time.now
      expect(c.created_at.utc?).to be_truthy
      expect(c.display_name).to eq(hash['display_name'])
      expect(c.game_name).to eq(hash['game'])
      expect(c.logo_url).to eq(hash['logo'])
      expect(c.name).to eq(hash['name'])
      expect(c.status).to eq(hash['status'])
      expect(c.updated_at.class).to eq(Time)
      expect(c.updated_at).to be < Time.now
      expect(c.updated_at.utc?).to be_truthy
      expect(c.url).to eq(hash['url'])
      expect(c.video_banner_url).to eq(hash['video_banner'])
      expect(c.mature?).to eq(hash['mature'])
    end

    it 'has associated teams' do
      hash = yaml_load('channel/colminigun.yml')
      c = Channel.new(hash, nil)
      expect(c.teams).not_to be_nil
      expect(c.teams).not_to be_empty
    end
  end

  describe '#streaming?' do
    it 'returns true when a channel has a live stream' do
      c = Twitch.channels.get('incontroltv')
      expect(c).not_to be_nil
      expect(c.streaming?).to be_truthy
      expect(c.stream).not_to be_nil
    end

    it 'returns false when a channel does not have a live stream' do
      c = Twitch.channels.get('lagtvmaximusblack')
      expect(c).not_to be_nil
      expect(c.streaming?).to be_falsey
      expect(c.stream).to be_nil
    end
  end

  describe '#followers' do
    it 'returns the list of users following this channel' do
      c = Twitch.channels.get('osrusher')
      expect(c).not_to be_nil
      f = c.followers
      expect(f).not_to be_nil
      expect(f.count).to eq(533)
      f.each { |u| expect(u.class).to eq(User) }
    end

    it 'limits the number of results based on the :limit parameter' do
      c = Twitch.channels.get('osrusher')
      expect(c).not_to be_nil
      f = c.followers(:limit => 7)
      expect(f).not_to be_nil
      expect(f.count).to eq(7)
      f.each { |u| expect(u.class).to eq(User) }
    end
  end

  describe '#user' do
    it 'returns the user owning the channel' do
      c = Twitch.channels.get('nathanias')
      expect(c).not_to be_nil
      u = c.user
      expect(u).not_to be_nil
      expect(c.name).to eq(u.name)
    end
  end

  describe '#videos' do
    it 'returns broadcasts' do
      c = Twitch.channels.get('ms_vixen')
      expect(c).not_to be_nil
      v = c.videos(:type => :broadcasts, :limit => 75)
      expect(v).not_to be_nil
      expect(v.count).to eq(75)
    end

    it 'returns highlights' do
      c = Twitch.channels.get('ms_vixen')
      expect(c).not_to be_nil
      v = c.videos(:type => :highlights, :limit => 50)
      expect(v).not_to be_nil
      expect(v.count).to eq(50)
    end

    it 'rejects :type if not :broadcats or :highlights' do
      expect {
        c = Twitch.channels.get('ms_vixen')
        expect(c).not_to be_nil
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
      expect(c).not_to be_nil
    end

    it 'handles channel name with URL characters' do
      c = Twitch.channels.get('foo/bar')
      expect(c).not_to be_nil
    end

    it 'returns nil when channel does not exist' do
      c = Twitch.channels.get('does_not_exist')
      expect(c).to be_nil
    end

    it 'returns nil when the channel is associated with a Justin.tv account' do
      c = Twitch.channels.get('desrow')
      expect(c).to be_nil
    end
  end
end
