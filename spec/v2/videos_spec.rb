require 'rspec'
require 'webmock/rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Videos do
  before do
    WebMocks.load_dir(fixture('videos'))
  end

  after do
    WebMock.reset!
  end

  describe '.top' do
    it 'returns top videos' do
      v = Videos.top
      v.should_not be_nil
      v.should_not be_empty
      v.length.should == 10
    end

    it 'can be filtered by game' do
      v = Videos.top(:game => 'Super Meat Boy')
      v.should_not be_nil
      v.should_not be_empty
      v.length.should == 10
      v.each do |video|
        video.game_name.should == 'Super Meat Boy'
      end
    end

    it 'can return videos from multiple time periods' do
      v = Videos.top(:period => :week)
      v.should_not be_nil
      v.should_not be_empty
      v.length.should == 10

      v = Videos.top(:period => :month)
      v.should_not be_nil
      v.should_not be_empty
      v.length.should == 10

      v = Videos.top(:period => :all)
      v.should_not be_nil
      v.should_not be_empty
      v.length.should == 10
    end

    it 'rejects invalid periods' do
      expect {
        v = Videos.top(:period => :invalid)
      }.to raise_error(ArgumentError)
    end
  end
end
