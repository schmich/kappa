require 'webmock'
require 'addressable/uri'
require 'json'
require 'yaml'

def fixture(file)
  File.join(File.dirname(__FILE__), 'fixtures', 'v2', file)
end

def yaml_load(file)
  YAML.load_file(fixture(file))
end

include WebMock::API

require 'yaml'

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

class YamlWebMock
  def self.load(file_name)
    doc = YAML.load_expand(file_name)
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

