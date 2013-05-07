class Class
  def module_class(sym)
    parts = name.split('::')
    parts[-1] = sym
    parts.inject(Kernel) { |const, part|
      const.const_get(part)
    }
  end
end