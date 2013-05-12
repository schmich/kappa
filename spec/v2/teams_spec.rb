require 'rspec'
require 'yaml'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Team do
  before do
    WebMocks.load_dir(fixture('teams'))
  end

  after do
    WebMock.reset!
  end

  describe '.all' do
    it 'returns all teams by default' do
      t = Teams.all
      t.count.should == 486
    end

    it 'returns a limited number of teams when specified' do
      t = Teams.all(:limit => 10)
      t.count.should == 10
    end

    # TODO: Teams.all(:offset => 10)
  end
end
