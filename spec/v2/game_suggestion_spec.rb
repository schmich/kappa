require 'rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::GameSuggestion do
  describe '.new' do
    it 'accepts a hash' do
      hash = yaml_load('game_suggestion/game_suggestion.yml')
      g = GameSuggestion.new(hash)
      g.should_not be_nil
      g.id.should == hash['_id']
      g.name.should == hash['name']
      g.giantbomb_id.should == hash['giantbomb_id']
      g.popularity.should == hash['popularity']
      g.box_images.should_not be_nil
      g.box_images.class.should == Images
      g.logo_images.should_not be_nil
      g.logo_images.class.should == Images
    end
  end
end
