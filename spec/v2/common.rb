require 'webmock'
require 'addressable/uri'
require 'json'
require 'yaml'

# Force YAML to use newer parsing engine.
YAML::ENGINE.yamler = 'psych'

def fixture(path)
  File.join(File.dirname(__FILE__), 'fixtures', path)
end

def yaml_load(file)
  YAML.load_file(fixture(file))
end

include WebMock::API

class WebMocks
  def self.load_dir(dir)
    pattern = File.join(dir, '*.mock.yml')
    Dir[pattern].each do |file|
      WebMocks.load(file)
    end
  end

  def self.load(file_name)
    doc = YAML.load_file(file_name)
    doc.each do |url, response|
      uri = Addressable::URI.parse(url)

      body = response['body']
      status = response['status']

      if body && status
        body = body.is_a?(Hash) ? body.to_json : body.to_s
      else
        status = 200
        body = response.is_a?(Hash) ? response.to_json : response.to_s
      end

      stub_request(:any, uri.omit(:query))
        .with(:query => uri.query_values)
        .to_return(:status => status, :body => body)
    end
  end
end

