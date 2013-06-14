require 'rspec'
require 'yaml'
require 'kappa'
require 'common'

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
    f.fake.should be_true
    f.proxied.should be_nil
  end

  it 'responds to proxied methods by creating proxy' do
    f = Fake.new
    f.real.should be_true
    f.proxied.should_not be_nil
  end

  describe '#respond_to?' do
    it 'returns true for methods it has defined' do
      f = Fake.new
      f.respond_to?(:fake).should be_true
    end

    it 'returns true for proxied methods' do
      f = Fake.new
      f.respond_to?(:real).should be_true
    end

    it 'returns false for undefined methods' do
      f = Fake.new
      f.respond_to?(:undefined).should be_false
    end
  end

  describe '#respond_to_missing?' do
    it 'returns a valid method for methods it has defined' do
      f = Fake.new
      m = f.method(:fake)
      m.should_not be_nil
    end

    it 'returns a valid method for proxied methods' do
      f = Fake.new
      m = f.method(:real)
      m.should_not be_nil
    end

    it 'returns nil for undefined methods' do
      expect {
        f = Fake.new
        m = f.method(:undefined)
      }.to raise_error(NameError)
    end
  end
end
