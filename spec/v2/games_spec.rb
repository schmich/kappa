require 'rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Games do
  before do
    WebMocks.load_dir(fixture('games'))
  end

  after do
    WebMock.reset!
  end

  describe '.top' do
    it 'returns a list of top games' do
      g = Games.top
      g.should_not be_nil
      g.each { |s| s.class.should == Game }
      g.count.should == 445
    end

    it 'limits results with the :limit parameter' do
      g = Games.top(:limit => 3)
      g.should_not be_nil
      g.each { |s| s.class.should == Game }
      g.count.should == 3
    end

    it 'handles server errors' do
      # TODO: HTTP 500
    end
  end

  describe '.find' do
    it 'returns a list of game suggestions' do
      g = Games.find(:name => 'starcraft')
      g.should_not be_nil
      g.count.should == 7
      g.each { |s| s.class.should == GameSuggestion }
    end

    it 'returns a list of game suggestions that are live' do
      g1 = Games.find(:name => 'diablo')
      g1.should_not be_nil
      g2 = Games.find(:name => 'diablo', :live => true)
      g2.should_not be_nil
      g1.count.should > g2.count
    end

    it 'requires :name to be specified' do
      expect {
        Games.find
      }.to raise_error(ArgumentError)

      expect {
        Games.find(:live => true)
      }.to raise_error(ArgumentError)
    end

    it 'handles empty results' do
      g = Games.find(:name => 'empty_results')
      g.should_not be_nil
      g.should be_empty
    end

    it 'handles server errors' do
      # TODO: HTTP 500
    end
  end
end
