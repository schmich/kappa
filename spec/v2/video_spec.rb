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
