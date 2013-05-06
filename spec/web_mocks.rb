require 'webmock'
require 'yaml'
require 'addressable/uri'
require 'json'

include WebMock::API

class WebMocks
  def self.load(file_name)
    doc = YAML.load_file(file_name)
    base_url = Addressable::URI.parse(doc['base_url'])
    mocks = doc['mocks']
    mocks.each do |path, response|
      status = response['status'] || 200

      body = response['body']
      body = case body
        when Hash
          body.to_json
        when String
          body
        else
          body.to_s
      end

      stub_request(:any, base_url + path)
        .to_return(:status => status, :body => body)
    end
  end
end
