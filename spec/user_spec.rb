require 'rspec'
require 'kappa'
require 'web_mocks'

include Kappa::V2

def fixture(file)
  File.join(File.dirname(__FILE__), 'fixtures', 'v2', file)
end

describe Kappa::V2::User do
  describe '#new' do
    it 'accepts a hash' do
      hash = YAML.load_file(fixture('user.yml'))
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
  end

  describe '.get' do
    before { WebMocks.load(fixture('web_mock.yml')) }

    it 'creates a User from user name' do
      u = User.get('colminigun')
      u.should_not == nil
    end

    it 'returns nil when user does not exist' do
      u = User.get('does_not_exist')
      u.should == nil
    end
  end
end
