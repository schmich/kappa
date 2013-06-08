# @private
module Proxy
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def proxy(&create_block)
      self.class_variable_set(:@@creator, create_block)
    end
  end

  def method_missing(*args)
    real.send(*args)
  end

  def respond_to?(sym, include_private = false)
    real.respond_to?(sym, include_private) || super
  end

  def respond_to_missing?(method_name, include_private = false)
    real.respond_to?(method_name, include_private) || super
  end

private
  def real
    @real ||= begin
      creator = self.class.class_variable_get(:@@creator)
      self.instance_eval(&creator)
    end
  end
end
