require 'rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Images do
  describe '.new' do
    it 'accepts a hash' do
      hash = yaml_load('images/images.yml')
      i = Images.new(hash)
      i.should_not be_nil
      i.large_url.should == hash['large']
      i.medium_url.should == hash['medium']
      i.small_url.should == hash['small']
      i.template_url.should == hash['template']
      custom = i.url(320, 240)
      custom.should_not be_nil
      custom.should_not == i.template_url
    end
  end
end
