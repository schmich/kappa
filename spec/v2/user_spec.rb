require 'rspec'
require 'kappa'
require_relative 'common'

include Twitch::V2

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
      expect(u.id).to eq(hash['_id'])
      expect(u.created_at.class).to eq(Time)
      expect(u.created_at).to be < Time.now
      expect(u.display_name).to eq(hash['display_name'])
      expect(u.logo_url).to eq(hash['logo'])
      expect(u.name).to eq(hash['name'])
      expect(u.staff?).to eq(hash['staff'])
      expect(u.updated_at.class).to eq(Time)
      expect(u.updated_at).to be < Time.now
    end
  end

  describe '#eql?' do
    it 'should be equal to self' do
      u1 = User.new(yaml_load('user/user_real.yml'), nil)
      expect(u1).to eq(u1)
      expect(u1.eql?(u1)).to be_truthy
      expect(u1 == u1).to be_truthy
    end

    it 'should be equal by ID' do
      u1 = User.new(yaml_load('user/user_real.yml'), nil)
      u2 = User.new(yaml_load('user/user_real.yml'), nil)
      expect(u1).to eq(u2)
      expect(u1.hash).to eq(u2.hash)
      expect(u1.eql?(u2)).to be_truthy
      expect(u1 == u2).to be_truthy
    end

    it 'should be different by ID' do
      u1 = User.new(yaml_load('user/user_real.yml'), nil)
      u2 = User.new(yaml_load('user/user_foo.yml'), nil)
      expect(u1).not_to eq(u2)
      expect(u1.eql?(u2)).to be_falsey
      expect(u1 == u2).to be_falsey
    end
  end

  describe '#following' do
    it 'returns the list of channels a user is following' do
      u = Twitch.users.get('nathanias')
      expect(u).not_to be_nil
      f = u.following
      expect(f).not_to be_nil
      expect(f.count).to eq(60)
      f.each { |c| expect(c.class).to eq(Channel) }
    end

    it 'limits the number of results returned based on the :limit parameter' do
      u = Twitch.users.get('nathanias')
      expect(u).not_to be_nil
      f = u.following(:limit => 7)
      expect(f).not_to be_nil
      expect(f.count).to eq(7)
      f.each { |c| expect(c.class).to eq(Channel) }
    end

    it 'returns results offset by the :offset parameter' do
      u = Twitch.users.get('lethalfrag')
      expect(u).not_to be_nil
      f = u.following(:limit => 5, :offset => 2)
      expect(f).not_to be_nil
      expect(f.count).to eq(5)
    end
  end

  describe '#following?' do
    it 'returns true if the user is following the channel' do
      u = Twitch.users.get('eghuk')
      expect(u).not_to be_nil
      f = u.following?('liquidtlo')
      expect(f).to be_truthy
    end

    it 'returns false if the user is not following the channel' do
      stub_request(:any, /\/follows\//)
        .to_return(:status => 404, :body => '{"status":404, "message":"eghuk is not following idrajit", "error":"Not Found"}')

      u = Twitch.users.get('eghuk')
      expect(u).not_to be_nil
      f = u.following?('idrajit')
      expect(f).to be_falsey
    end

    it 'accepts a Channel object' do
      u = Twitch.users.get('eghuk')
      expect(u).not_to be_nil
      c = Twitch.channels.get('nony')
      f = u.following?(c)
      expect(f).to be_truthy
    end
  end

  describe '#channel' do
    it 'returns the channel associated with the user' do
      u = Twitch.users.get('colthestc')
      expect(u).not_to be_nil
      c = u.channel
      expect(c).not_to be_nil
      expect(c.name).to eq(u.name)
    end
  end

  describe '#stream' do
    it 'returns a valid stream if the user is streaming' do
      u = Twitch.users.get('incontroltv')
      expect(u).not_to be_nil
      s = u.stream
      expect(s).not_to be_nil
    end

    it 'returns nil if the user is not streaming' do
      u = Twitch.users.get('tsm_dyrus')
      expect(u).not_to be_nil
      s = u.stream
      expect(s).to be_nil
    end
  end

  describe '#streaming?' do
    it 'returns true if the user is streaming' do
      u = Twitch.users.get('incontroltv')
      expect(u).not_to be_nil
      expect(u.streaming?).to be_truthy
    end

    it 'returns false if the user is not streaming' do
      u = Twitch.users.get('tsm_dyrus')
      expect(u).not_to be_nil
      expect(u.streaming?).to be_falsey
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
      expect(u).not_to be_nil
    end

    it 'returns nil when user does not exist' do
      u = Twitch.users.get('does_not_exist')
      expect(u).to be_nil
    end
  end
end
