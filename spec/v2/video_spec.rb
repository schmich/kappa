require 'rspec'
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
      v.recorded_at.class.should == DateTime
      v.recorded_at.should < DateTime.now
      v.url.should == hash['url']
      v.view_count.should == hash['views']
      v.description.should == hash['description']
      v.length_sec.should == hash['length']
      v.game_name.should == hash['game']
      v.preview_url.should == hash['preview']
      v.channel_name.should == hash['channel']['name']
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
  end
end
