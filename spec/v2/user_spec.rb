require 'rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::User do
  before do
    WebMocks.load_dir(fixture('user'))
  end

  after do
    WebMock.reset!
  end

  describe '#new' do
    it 'accepts a hash' do
      hash = yaml_load('user/user_real.yml')
      u = User.new(hash)
      u.id.should == hash['_id']
      u.created_at.class.should == DateTime
      u.created_at.should < DateTime.now
      u.display_name.should == hash['display_name']
      u.logo_url.should == hash['logo']
      u.name.should == hash['name']
      u.staff?.should == hash['staff']
      u.updated_at.class.should == DateTime
      u.updated_at.should < DateTime.now
    end
  end

  describe '.get' do
    it 'creates a User from user name' do
      u = User.get('colminigun')
      u.should_not be_nil
    end

    it 'returns nil when user does not exist' do
      u = User.get('does_not_exist')
      u.should be_nil
    end
  end

  describe '#eql?' do
    it 'should be equal to self' do
      u1 = User.new(yaml_load('user/user_real.yml'))
      u1.should == u1
      u1.eql?(u1).should be_true
      (u1 == u1).should be_true
    end

    it 'should be equal by ID' do
      u1 = User.new(yaml_load('user/user_real.yml'))
      u2 = User.new(yaml_load('user/user_real.yml'))
      u1.should == u2
      u1.hash.should == u2.hash
      u1.eql?(u2).should be_true
      (u1 == u2).should be_true
    end

    it 'should be different by ID' do
      u1 = User.new(yaml_load('user/user_real.yml'))
      u2 = User.new(yaml_load('user/user_foo.yml'))
      u1.should_not == u2
      u1.eql?(u2).should be_false
      (u1 == u2).should be_false
    end
  end

  # TODO: User#following
  # TODO: User#following?
end
