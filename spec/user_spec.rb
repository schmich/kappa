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

  it 'can be created by user name' do
    WebMocks.load('spec/fixtures/v2/web_mock.yml')
    u = User.new('colminigun')
  end

  it 'raises error when created with invalid argument' do
    expect { User.new(42) }.to raise_error(ArgumentError)
  end
end
