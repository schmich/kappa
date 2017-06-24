require 'rspec'
require 'kappa'
require_relative 'common'

include Twitch::V2

describe Twitch::V2::Images do
  describe '.new' do
    it 'accepts a hash' do
      hash = yaml_load('images/images.yml')
      i = Images.new(hash)
      expect(i).not_to be_nil
      expect(i.large_url).to eq(hash['large'])
      expect(i.medium_url).to eq(hash['medium'])
      expect(i.small_url).to eq(hash['small'])
      expect(i.template_url).to eq(hash['template'])
      custom = i.url(320, 240)
      expect(custom).not_to be_nil
      expect(custom).not_to eq(i.template_url)
    end
  end
end
