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

    # TODO: Handles user name with URL characters.
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

  describe '#following' do
    it 'returns the list of channels a user is following' do
      u = User.get('nathanias')
      u.should_not be_nil
      f = u.following
      f.should_not be_nil
      f.count.should == 60
      f.each { |c| c.class.should == Channel }
    end

    it 'limits the number of results returned based on the :limit parameter' do
      u = User.get('nathanias')
      u.should_not be_nil
      f = u.following(:limit => 7)
      f.should_not be_nil
      f.count.should == 7
      f.each { |c| c.class.should == Channel }
    end
  end

  describe '#following?' do
    it 'returns true if the user is following the channel' do
      u = User.get('eghuk')
      u.should_not be_nil
      f = u.following?('liquidtlo')
      f.should == true
    end

    it 'returns false if the user is not following the channel' do
      u = User.get('eghuk')
      u.should_not be_nil
      f = u.following?('idrajit')
      f.should == false
    end

    it 'accepts a Channel object' do
      u = User.get('eghuk')
      u.should_not be_nil
      c = Channel.get('nony')
      f = u.following?(c)
      f.should == true
    end

    # TODO: URL characters
  end

  describe '#channel' do
    it 'returns the channel associated with the user' do
      u = User.get('colthestc')
      u.should_not be_nil
      c = u.channel
      c.should_not be_nil
      c.name.should == u.name
    end
  end

  describe '#stream' do
    it 'returns a valid stream if the user is streaming' do
      u = User.get('incontroltv')
      u.should_not be_nil
      s = u.stream
      s.should_not be_nil
    end

    it 'returns nil if the user is not streaming' do
      u = User.get('tsm_dyrus')
      u.should_not be_nil
      s = u.stream
      s.should be_nil
    end
  end

  describe '#streaming?' do
    it 'returns true if the user is streaming' do
      u = User.get('incontroltv')
      u.should_not be_nil
      u.streaming?.should == true
    end

    it 'returns false if the user is not streaming' do
      u = User.get('tsm_dyrus')
      u.should_not be_nil
      u.streaming?.should == false
    end
  end
end
