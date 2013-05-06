require 'rspec'
require 'kappa'
require 'web_mocks'

include Kappa::V2

describe Kappa::V2::User do
  it 'can be created from a hash' do
    hash = YAML.load_file('spec/fixtures/v2/user.yml')
    u = User.new(hash)
    u.id.should == hash['_id']
    u.created_at.class.should == DateTime
    u.created_at.should < DateTime.now
    u.display_name.should == hash['display_name']
    u.logo_url.should == hash['logo']
    u.name.should == hash['name']
    u.type.should == hash['type']
    u.updated_at.class.should == DateTime
    u.updated_at.should < DateTime.now
  end

  describe '.get' do
    it 'creates a User from user name' do
      WebMocks.load('spec/fixtures/v2/web_mock.yml')
      u = User.get('colminigun')
      u.should_not == nil
    end

    it 'returns nil when user does not exist' do
      WebMocks.load('spec/fixtures/v2/web_mock.yml')
      u = User.get('does_not_exist')
      u.should == nil
    end
  end
end
