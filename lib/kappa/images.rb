module Kappa
  class ImagesBase
    def initialize(hash)
      parse(hash)
    end
  end
end

module Kappa::V2
  class Images < Kappa::ImagesBase
    def url(width, height)
      @template_url.gsub('{width}', width.to_s, '{height}', height.to_s)
    end

    attr_reader :large_url
    attr_reader :medium_url
    attr_reader :small_url
    attr_reader :template_url

  private
    def parse(hash)
      @large_url = hash['large']
      @medium_url = hash['medium']
      @small_url = hash['small']
      @template_url = hash['template']
    end
  end
end
