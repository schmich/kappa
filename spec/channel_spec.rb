require 'rspec'
require 'yaml'
require 'kappa'

include Kappa::V2

describe Kappa::V2::Channel do
  it 'can be created from a hash' do
    hash = yaml_load('channel/channel.yml')
    c = Channel.new(hash)
    c.id.should == hash['_id']
    c.background_url.should == hash['background']
    c.banner_url.should == hash['banner']
    c.created_at.class.should == DateTime
    c.created_at.should < DateTime.now
    c.stream_delay_sec.should == hash['delay']
    c.display_name.should == hash['display_name']
    c.game_name.should == hash['game']
    c.logo_url.should == hash['logo']
    c.name.should == hash['name']
    c.status.should == hash['status']
    c.updated_at.class.should == DateTime
    c.updated_at.should < DateTime.now
    c.url.should == hash['url']
    c.video_banner_url.should == hash['video_banner']
    c.mature?.should == hash['mature']
  end

  it 'raises error when created with invalid argument' do
    expect { Channel.new(42) }.to raise_error(ArgumentError)
  end

  # TODO: Test creating via name: Channel.new('colminigun')
end
