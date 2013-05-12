require 'webmock'
require 'addressable/uri'
require 'json'
require 'yaml'

def fixture(path)
  File.join(File.dirname(__FILE__), 'fixtures', path)
end

def yaml_load(file)
  YAML.load_file(fixture(file))
end

module YAML
  def self.load_expand(file)
    expand(YAML.load_file(file), file)
  end

private
  def self.expand(node, file)
    case node
      when Hash
        node.each do |k, v|
          if v.is_a? String
            if v =~ /^\$\((.*)\)/
              file = File.join(File.dirname(file), $1)
              node[k] = load_expand(file)
            end
          else
            expand(v, file)
          end
        end
      when Array
        node.each do |n|
          expand(n, file)
        end
    end

    node
  end
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
    doc = YAML.load_expand(file_name)
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

