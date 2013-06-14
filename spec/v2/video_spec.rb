require 'rspec'
require 'webmock/rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Video do
  before do
    WebMocks.load_dir(fixture('video'))
  end

  after do
    WebMock.reset!
  end

  describe '#new' do
    it 'accepts a hash' do
      hash = yaml_load('video/video.yml')
      v = Video.new(hash)
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
    end
  end

  describe '.get' do
    it 'creates a Video from video ID' do
      v = Video.get('a402689752')
      v.should_not be_nil
    end

    it 'returns nil when video does not exist' do
      v = Video.get('does_not_exist')
      v.should be_nil
    end

    it 'handles video name with URL characters' do
      v = Video.get('foo/bar')
      v.should_not be_nil
    end
  end

  describe '.channel' do
    it 'returns a valid channel' do
      v = Video.get('a402689752')
      v.should_not be_nil
      c = v.channel
      c.should_not be_nil
    end

    it 'returns a proxy channel object without causing a request' do
      v = Video.get('a402689752')
      v.should_not be_nil
      c = v.channel
      c.should_not be_nil
      c.name.should_not be_nil
      c.display_name.should_not be_nil
      a_request(:get, 'https://api.twitch.tv/kraken/channels/wcs_osl').should_not have_been_made
    end

    it 'causes a request when getting other channel attributes' do
      v = Video.get('a413663426')
      v.should_not be_nil
      c = v.channel
      c.should_not be_nil
      c.status.should_not be_nil
      c.respond_to? :status
      m = c.method(:status)
      m.should_not be_nil
      a_request(:get, 'https://api.twitch.tv/kraken/channels/wcs_osl').should have_been_made
    end
  end
end
