require 'rspec'
require 'yaml'
require 'kappa'
require_relative '../v2/common'

class Real
  def real
    true
  end
end

class Fake
  def fake
    true
  end

  include Proxy

  attr_accessor :proxied

  proxy {
    @proxied = Real.new
  }
end

describe Proxy do
  it 'responds to methods it has defined without creating proxy' do
    f = Fake.new
    expect(f.fake).to be_truthy
    expect(f.proxied).to be_nil
  end

  it 'responds to proxied methods by creating proxy' do
    f = Fake.new
    expect(f.real).to be_truthy
    expect(f.proxied).not_to be_nil
  end

  describe '#respond_to?' do
    it 'returns true for methods it has defined' do
      f = Fake.new
      expect(f.respond_to?(:fake)).to be_truthy
    end

    it 'returns true for proxied methods' do
      f = Fake.new
      expect(f.respond_to?(:real)).to be_truthy
    end

    it 'returns false for undefined methods' do
      f = Fake.new
      expect(f.respond_to?(:undefined)).to be_falsey
    end
  end

  describe '#respond_to_missing?' do
    it 'returns a valid method for methods it has defined' do
      f = Fake.new
      m = f.method(:fake)
      expect(m).not_to be_nil
    end

    it 'returns a valid method for proxied methods' do
      f = Fake.new
      m = f.method(:real)
      expect(m).not_to be_nil
    end

    it 'returns nil for undefined methods' do
      expect {
        f = Fake.new
        m = f.method(:undefined)
      }.to raise_error(NameError)
    end
  end
end
