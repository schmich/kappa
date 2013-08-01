require 'rspec'
require 'kappa'
require 'common'

describe Twitch::V2::User do
  before do
    WebMocks.load_dir(fixture('user'))
  end

  after do
    WebMock.reset!
  end

  describe '#new' do
    it 'accepts a hash' do
      hash = yaml_load('user/user_real.yml')
      u = User.new(hash, nil)
      u.id.should == hash['_id']
      u.created_at.class.should == Time
      u.created_at.should < Time.now
      u.display_name.should == hash['display_name']
      u.logo_url.should == hash['logo']
      u.name.should == hash['name']
      u.staff?.should == hash['staff']
      u.updated_at.class.should == Time
      u.updated_at.should < Time.now
    end
  end

  describe '#eql?' do
    it 'should be equal to self' do
      u1 = User.new(yaml_load('user/user_real.yml'), nil)
      u1.should == u1
      u1.eql?(u1).should be_true
      (u1 == u1).should be_true
    end

    it 'should be equal by ID' do
      u1 = User.new(yaml_load('user/user_real.yml'), nil)
      u2 = User.new(yaml_load('user/user_real.yml'), nil)
      u1.should == u2
      u1.hash.should == u2.hash
      u1.eql?(u2).should be_true
      (u1 == u2).should be_true
    end

    it 'should be different by ID' do
      u1 = User.new(yaml_load('user/user_real.yml'), nil)
      u2 = User.new(yaml_load('user/user_foo.yml'), nil)
      u1.should_not == u2
      u1.eql?(u2).should be_false
      (u1 == u2).should be_false
    end
  end

  describe '#following' do
    it 'returns the list of channels a user is following' do
      u = Twitch.users.get('nathanias')
      u.should_not be_nil
      f = u.following
      f.should_not be_nil
      f.count.should == 60
      f.each { |c| c.class.should == Channel }
    end

    it 'limits the number of results returned based on the :limit parameter' do
      u = Twitch.users.get('nathanias')
      u.should_not be_nil
      f = u.following(:limit => 7)
      f.should_not be_nil
      f.count.should == 7
      f.each { |c| c.class.should == Channel }
    end

    it 'returns results offset by the :offset parameter' do
      u = Twitch.users.get('lethalfrag')
      u.should_not be_nil
      f = u.following(:limit => 5, :offset => 2)
      f.should_not be_nil
      f.count.should == 5
    end
  end

  describe '#following?' do
    it 'returns true if the user is following the channel' do
      u = Twitch.users.get('eghuk')
      u.should_not be_nil
      f = u.following?('liquidtlo')
      f.should be_true
    end

    it 'returns false if the user is not following the channel' do
      stub_request(:any, /\/follows\//)
        .to_return(:status => 404, :body => '{"status":404, "message":"eghuk is not following idrajit", "error":"Not Found"}')

      u = Twitch.users.get('eghuk')
      u.should_not be_nil
      f = u.following?('idrajit')
      f.should be_false
    end

    it 'accepts a Channel object' do
      u = Twitch.users.get('eghuk')
      u.should_not be_nil
      c = Twitch.channels.get('nony')
      f = u.following?(c)
      f.should be_true
    end
  end

  describe '#channel' do
    it 'returns the channel associated with the user' do
      u = Twitch.users.get('colthestc')
      u.should_not be_nil
      c = u.channel
      c.should_not be_nil
      c.name.should == u.name
    end
  end

  describe '#stream' do
    it 'returns a valid stream if the user is streaming' do
      u = Twitch.users.get('incontroltv')
      u.should_not be_nil
      s = u.stream
      s.should_not be_nil
    end

    it 'returns nil if the user is not streaming' do
      u = Twitch.users.get('tsm_dyrus')
      u.should_not be_nil
      s = u.stream
      s.should be_nil
    end
  end

  describe '#streaming?' do
    it 'returns true if the user is streaming' do
      u = Twitch.users.get('incontroltv')
      u.should_not be_nil
      u.streaming?.should be_true
    end

    it 'returns false if the user is not streaming' do
      u = Twitch.users.get('tsm_dyrus')
      u.should_not be_nil
      u.streaming?.should be_false
    end
  end
end

describe Twitch::V2::Users do
  before do
    WebMocks.load_dir(fixture('user'))
  end

  after do
    WebMock.reset!
  end

  describe '#get' do
    it 'creates a User from user name' do
      u = Twitch.users.get('colminigun')
      u.should_not be_nil
    end

    it 'returns nil when user does not exist' do
      u = Twitch.users.get('does_not_exist')
      u.should be_nil
    end
  end
end
