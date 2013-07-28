require 'rspec'
require 'webmock/rspec'
require 'kappa'
require 'common'

describe Twitch::V2::Video do
  before do
    WebMocks.load_dir(fixture('video'))
  end

  after do
    WebMock.reset!
  end

  describe '#new' do
    it 'accepts a hash' do
      hash = yaml_load('video/video.yml')
      v = Video.new(hash, nil)
      v.id.should == hash['_id']
      v.title.should == hash['title']
      v.recorded_at.class.should == Time
      v.recorded_at.should < Time.now
      v.recorded_at.utc?.should be_true
      v.url.should == hash['url']
      v.view_count.should == hash['views']
      v.description.should == hash['description']
      v.length.should == hash['length']
      v.game_name.should == hash['game']
      v.preview_url.should == hash['preview']
      v.channel.should_not be_nil
      v.embed_html.should_not be_nil
      v.embed_html.should_not be_empty
    end
  end

  describe '.channel' do
    it 'returns a valid channel' do
      v = Twitch.videos.get('a402689752')
      v.should_not be_nil
      c = v.channel
      c.should_not be_nil
    end

    it 'returns a proxy channel object without causing a request' do
      v = Twitch.videos.get('a402689752')
      v.should_not be_nil
      c = v.channel
      c.should_not be_nil
      c.name.should_not be_nil
      c.display_name.should_not be_nil
      a_request(:get, 'https://api.twitch.tv/kraken/channels/wcs_osl').should_not have_been_made
    end

    it 'causes a request when getting other channel attributes' do
      v = Twitch.videos.get('a413663426')
      v.should_not be_nil
      c = v.channel
      c.should_not be_nil
      c.status.should_not be_nil
      a_request(:get, 'https://api.twitch.tv/kraken/channels/wcs_osl').should have_been_made
    end
  end
end

describe Twitch::V2::Videos do
  before do
    WebMocks.load_dir(fixture('video'))
  end

  after do
    WebMock.reset!
  end

  describe '#get' do
    it 'creates a Video from video ID' do
      v = Twitch.videos.get('a402689752')
      v.should_not be_nil
    end

    it 'returns nil when video does not exist' do
      v = Twitch.videos.get('does_not_exist')
      v.should be_nil
    end

    it 'handles video name with URL characters' do
      v = Twitch.videos.get('foo/bar')
      v.should_not be_nil
    end
  end

  describe '#top' do
    it 'returns top videos' do
      v = Twitch.videos.top
      v.should_not be_nil
      v.should_not be_empty
      v.length.should == 10
    end

    it 'can be filtered by game' do
      v = Twitch.videos.top(:game => 'Super Meat Boy')
      v.should_not be_nil
      v.should_not be_empty
      v.length.should == 10
      v.each do |video|
        video.game_name.should == 'Super Meat Boy'
      end
    end

    it 'can return videos from multiple time periods' do
      v = Twitch.videos.top(:period => :week)
      v.should_not be_nil
      v.should_not be_empty
      v.length.should == 10

      v = Twitch.videos.top(:period => :month)
      v.should_not be_nil
      v.should_not be_empty
      v.length.should == 10

      v = Twitch.videos.top(:period => :all)
      v.should_not be_nil
      v.should_not be_empty
      v.length.should == 10
    end

    it 'rejects invalid periods' do
      expect {
        v = Twitch.videos.top(:period => :invalid)
      }.to raise_error(ArgumentError)
    end
  end

  describe '#for_channel' do
    it 'returns broadcasts' do
      v = Twitch.videos.for_channel('ms_vixen', :type => :broadcasts, :limit => 75)
      v.should_not be_nil
      v.count.should == 75
    end

    it 'returns highlights' do
      v = Twitch.videos.for_channel('ms_vixen', :type => :highlights, :limit => 50)
      v.should_not be_nil
      v.count.should == 50
    end

    it 'rejects :type if not :broadcats or :highlights' do
      expect {
        v = Twitch.videos.for_channel('ms_vixen', :type => :invalid)
      }.to raise_error(ArgumentError)
    end
  end
end
