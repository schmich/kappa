require 'rspec'
require 'kappa'
require 'common'

describe Twitch::Connection do
  after do
    WebMock.reset!
  end

  describe '#get' do
    it 'raises Arugment error if no path is specified' do
      expect {
        c = Twitch::V2::Connection.new('client_id')
        content = c.get
      }.to raise_error(ArgumentError)
    end

    it 'raises FormatError if response is not valid JSON' do
      stub_request(:any, /.*/)
        .to_return(:body => '"Invalid JSON')

      expect {
        c = Twitch::V2::Connection.new('client_id')
        json = c.get('/test')
      }.to raise_error(Twitch::Error::FormatError)
    end

    it 'raises FormatError with request URL' do
      status = 200
      body = '"Invalid JSON'

      stub_request(:any, /.*/)
        .to_return(:status => status, :body => body)

      error = false
      begin
        c = Twitch::V2::Connection.new('client_id')
        json = c.get('/test')
      rescue Twitch::Error::FormatError => e
        error = true
        e.url.should =~ /test/ 
        e.status.should == status
        e.body.should == body
      end

      error.should be_true
    end

    it 'raises ClientError when HTTP status is 404' do
      status = 404
      body = 'Not found.'

      stub_request(:any, /.*/)
        .to_return(:status => status, :body => body)

      error = false
      begin
        c = Twitch::V2::Connection.new('client_id')
        json = c.get('/test')
      rescue Twitch::Error::ClientError => e
        error = true
        e.url.should =~ /test/
        e.status.should == status
        e.body.should == body
      end

      error.should be_true
    end

    it 'raises ServerError when HTTP status is 404' do
      status = 500
      body = 'Internal server error.'

      stub_request(:any, /.*/)
        .to_return(:status => status, :body => body)

      error = false
      begin
        c = Twitch::V2::Connection.new('client_id')
        json = c.get('/test')
      rescue Twitch::Error::ServerError => e
        error = true
        e.url.should =~ /test/
        e.status.should == status
        e.body.should == body
      end

      error.should be_true
    end
  end
end
