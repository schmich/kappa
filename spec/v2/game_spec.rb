require 'rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Game do
  describe '.new' do
    it 'accepts a hash' do
      hash = yaml_load('game/game.yml')
      g = Game.new(hash)
      g.should_not be_nil
      g.id.should == hash['game']['_id']
      g.name.should == hash['game']['name']
      g.giantbomb_id.should == hash['game']['giantbomb_id']
      g.channel_count.should == hash['channels']
      g.viewer_count.should == hash['viewers']
      g.box_images.should_not be_nil
      g.box_images.class.should == Images
      g.logo_images.should_not be_nil
      g.logo_images.class.should == Images
    end
  end
end
