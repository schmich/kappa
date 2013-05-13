module Kappa::V2
  # A group of URLs pointing to variously-sized versions of the same image.
  class Images
    # @private
    def initialize(hash)
      @large_url = hash['large']
      @medium_url = hash['medium']
      @small_url = hash['small']
      @template_url = hash['template']
    end

    # Get a URL pointing to an image with a specific size.
    # @param width [Fixnum] Desired width of the image.
    # @param height [Fixnum] Desired height of the image.
    # @return [String] URL pointing to the image with the specified size.
    def url(width, height)
      @template_url.gsub('{width}', width.to_s).gsub('{height}', height.to_s)
    end

    # TODO: Add documentation notes about rough sizes for small, medium, large images.

    # @return [String] URL for the large-sized version of this image.
    attr_reader :large_url

    # @return [String] URL for the medium-sized version of this image.
    attr_reader :medium_url

    # @return [String] URL for the small-sized version of this image.
    attr_reader :small_url

    # @note You shouldn't need to use this property directly. See #url for getting a formatted URL instead.
    # @return [String] Template image URL with placeholders for width and height.
    # @see #url
    attr_reader :template_url
  end
end
