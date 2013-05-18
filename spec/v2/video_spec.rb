require 'rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Video do
  before do
    # WebMocks.load_dir(fixture('video'))
  end

  after do
    # WebMock.reset!
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
    end

    it 'returns nil when video does not exist' do
    end

    # TODO: Handles video ID with URL characters.
  end
end
