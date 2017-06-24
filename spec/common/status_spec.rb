require 'rspec'
require 'kappa'
require_relative '../v2/common'

describe Twitch::Status do
  describe '.map' do
    it 'returns a mapped value' do
      value = false

      value = Twitch::Status.map(404 => true) do
        raise Twitch::Error::ClientError.new('', '', 404, '')
      end

      expect(value).to be_truthy
    end

    it 'raises an error when value is not mapped' do
      expect {
        Twitch::Status.map(404 => true) do
          raise Twitch::Error::ClientError.new('', '', 400, '')
        end
      }.to raise_error(Twitch::Error::ClientError)
    end
  end
end
