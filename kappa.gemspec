require File.expand_path('lib/kappa/version.rb', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name = 'kappa'
  s.version = Twitch::VERSION
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'Ruby library for interfacing with the Twitch.tv API.'
  s.description = <<-END
    The Ruby library for interfacing with the Twitch.tv API
    including users, channels, streams, games, and videos.
  END
  s.authors = ['Chris Schmich']
  s.email = 'schmch@gmail.com'
  s.files = Dir['{lib}/**/*.rb', 'bin/*', '*.md', 'LICENSE', '.yardopts']
  s.require_path = 'lib'
  s.homepage = 'https://github.com/schmich/kappa'
  s.license = 'MIT'
  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency 'httparty', '~> 0.13'
  s.add_runtime_dependency 'addressable', '~> 2.5'
  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'webmock', '~> 1.20'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'launchy', '~> 2.4'
  s.add_development_dependency 'yard', '~> 0.8'
  s.add_development_dependency 'markdown', '~> 1.1'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'coveralls'
end
