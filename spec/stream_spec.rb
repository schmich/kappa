require 'rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Stream do
  describe '#new' do
    it 'accepts a hash' do
      hash = YAML.load_file(fixture('stream/stream_real.yml'))
      s = Stream.new(hash)
      s.id.should == hash['_id']
      s.broadcaster.should == hash['broadcaster']
      s.game_name.should == hash['game']
      s.name.should == hash['name']
      s.viewer_count.should == hash['viewers']
      s.preview_url.should == hash['preview']
      # TODO: s.channel assert
    end
  end

  describe '.get' do
    before { YamlWebMock.load(fixture('stream/stream_web_mock.yml')) }

    it 'creates a Stream from stream name' do
      s = Stream.get('stream_foo')
      s.should_not be_nil
    end

    it 'returns nil when stream is not live' do
      s = Stream.get('does_not_exist')
      s.should be_nil
    end
  end

  it 'should be equal to self' do
  end

  it 'should be equal by ID' do
  end

  it 'should be different by ID' do
  end
end
