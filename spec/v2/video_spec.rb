require 'rspec'
require 'webmock/rspec'
require 'kappa'
require_relative 'common'

include Twitch::V2

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
      expect(v.id).to eq(hash['_id'])
      expect(v.title).to eq(hash['title'])
      expect(v.recorded_at.class).to eq(Time)
      expect(v.recorded_at).to be < Time.now
      expect(v.recorded_at.utc?).to be_truthy
      expect(v.url).to eq(hash['url'])
      expect(v.view_count).to eq(hash['views'])
      expect(v.description).to eq(hash['description'])
      expect(v.length).to eq(hash['length'])
      expect(v.game_name).to eq(hash['game'])
      expect(v.preview_url).to eq(hash['preview'])
      expect(v.channel).not_to be_nil
      expect(v.embed_html).not_to be_nil
      expect(v.embed_html).not_to be_empty
    end
  end

  describe '.channel' do
    it 'returns a valid channel' do
      v = Twitch.videos.get('a402689752')
      expect(v).not_to be_nil
      c = v.channel
      expect(c).not_to be_nil
    end

    it 'returns a proxy channel object without causing a request' do
      v = Twitch.videos.get('a402689752')
      expect(v).not_to be_nil
      c = v.channel
      expect(c).not_to be_nil
      expect(c.name).not_to be_nil
      expect(c.display_name).not_to be_nil
      expect(a_request(:get, 'https://api.twitch.tv/kraken/channels/wcs_osl')).not_to have_been_made
    end

    it 'causes a request when getting other channel attributes' do
      v = Twitch.videos.get('a413663426')
      expect(v).not_to be_nil
      c = v.channel
      expect(c).not_to be_nil
      expect(c.status).not_to be_nil
      expect(a_request(:get, 'https://api.twitch.tv/kraken/channels/wcs_osl')).to have_been_made
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
      expect(v).not_to be_nil
    end

    it 'returns nil when video does not exist' do
      stub_request(:any, /.*api\.twitch\.tv.*/)
        .to_return(:status => 404, :body => '{"status":404, "message":"Video does not exist", "error":"Not Found"}')

      v = Twitch.videos.get('does_not_exist')
      expect(v).to be_nil
    end

    it 'handles video name with URL characters' do
      v = Twitch.videos.get('foo/bar')
      expect(v).not_to be_nil
    end
  end

  describe '#top' do
    it 'returns top videos' do
      v = Twitch.videos.top
      expect(v).not_to be_nil
      expect(v).not_to be_empty
      expect(v.length).to eq(10)
    end

    it 'can be filtered by game' do
      v = Twitch.videos.top(:game => 'Super Meat Boy')
      expect(v).not_to be_nil
      expect(v).not_to be_empty
      expect(v.length).to eq(10)
      v.each do |video|
        expect(video.game_name).to eq('Super Meat Boy')
      end
    end

    it 'can return videos from multiple time periods' do
      v = Twitch.videos.top(:period => :week)
      expect(v).not_to be_nil
      expect(v).not_to be_empty
      expect(v.length).to eq(10)

      v = Twitch.videos.top(:period => :month)
      expect(v).not_to be_nil
      expect(v).not_to be_empty
      expect(v.length).to eq(10)

      v = Twitch.videos.top(:period => :all)
      expect(v).not_to be_nil
      expect(v).not_to be_empty
      expect(v.length).to eq(10)
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
      expect(v).not_to be_nil
      expect(v.count).to eq(75)
    end

    it 'accepts objects responding to #name' do
      channel = Object.new
      def channel.name
        'ms_vixen'
      end
      v = Twitch.videos.for_channel(channel, :type => :broadcasts, :limit => 75)
      expect(v).not_to be_nil
      expect(v.count).to eq(75)
    end

    it 'returns highlights' do
      v = Twitch.videos.for_channel('ms_vixen', :type => :highlights, :limit => 50)
      expect(v).not_to be_nil
      expect(v.count).to eq(50)
    end

    it 'rejects :type if not :broadcats or :highlights' do
      expect {
        v = Twitch.videos.for_channel('ms_vixen', :type => :invalid)
      }.to raise_error(ArgumentError)
    end
  end
end
