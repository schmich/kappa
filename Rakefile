require 'fileutils'
require 'launchy'
require 'json'
require 'yaml'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |config|
  config.ruby_opts = '-I./spec/v2'
end

desc 'Run RSpec code examples with code coverage'
RSpec::Core::RakeTask.new(:coverage) do |config|
  config.ruby_opts = '-r ./spec/coverage.rb -I./spec/v2'
end

desc 'Run RSpec code examples and upload coverage stats'
RSpec::Core::RakeTask.new(:'coverage:upload') do |config|
  config.ruby_opts = '-r ./spec/coverage-upload.rb -I./spec/v2'
end

class GemInfo
  def initialize
    @gemspec_filename = Dir['*.gemspec'][0]
  end
   
  def spec
    @spec ||= eval(File.read(@gemspec_filename))
  end

  def name
    @name ||= spec.name
  end

  def version
    @version ||= spec.version.to_s
  end

  def gem_filename
    "#{name}-#{version}.gem"
  end

  def gemspec_filename
    @gemspec_filename
  end
end

$gem = GemInfo.new

desc "Start irb #{$gem.name} session"
task :irb do
  sh "irb -rubygems -I./lib -r ./lib/#{$gem.name.gsub('-', '/')}.rb"
end

desc "Install #{$gem.name} gem"
task :install => :build do
  gemfile = "gem/#{$gem.gem_filename}"
  if !gemfile.nil?
    sh "gem install --no-ri --no-rdoc #{gemfile}"
  else
    puts 'Could not find gem.'
  end
end

desc "Uninstall #{$gem.name} gem"
task :uninstall do
  sh "gem uninstall #{$gem.name} -x"
end

desc "Build #{$gem.name} gem"
task :build do
  FileUtils.mkdir_p('gem')
  sh "gem build #{$gem.gemspec_filename}"
  FileUtils.mv $gem.gem_filename, 'gem'
end

desc 'Run YARD server to view docs'
task :yard do
  if Dir.exists?('.yardoc')
    FileUtils.rm_rf('.yardoc')
  end

  Launchy.open('http://localhost:8808/docs/frames')
  system('yard server --reload')
end

desc "Release #{$gem.name} v#{$gem.version} and tag in git"
task :release => :build do
  if (`git` rescue nil).nil?
    puts 'Could not run git command.'
    exit!
  end

  if (`gem` rescue nil).nil?
    puts 'Could not run gem command.'
    exit!
  end

  unless `git branch --no-color`.strip =~ /^\*\s+master$/
    puts 'You must release from the master branch.'
    exit!
  end

  version = $gem.version
  tag = "v#{version}"

  if `git tag`.strip =~ /^#{tag}$/
    puts "Tag #{tag} already exists, you must bump version."
    exit!
  end

  puts "Releasing version #{version}."

  sh "git commit --allow-empty -a -m \"Release #{version}.\""
  sh "git tag #{tag}"
  sh 'git push origin master'
  sh "git push origin #{tag}"
  sh "gem push gem/#{$gem.gem_filename}"

  puts 'Fin.'
end

desc 'Log a Twitch request as YAML'
task :request do
  $stderr.print 'Path: '
  path = $stdin.gets.strip.sub(/^\/+/, '')

  url = "https://api.twitch.tv/kraken/#{path}"
  $stderr.puts "Requesting #{url}."

  content = `curl -k -H "Accept: application/vnd.twitchtv.v2+json" "#{url}"`
  $stdout.puts "#{url}:"
  hash = JSON.parse(content)
  yaml = YAML.dump(hash)
  yaml.lines.drop(1).each do |line|
    $stdout.puts "  #{line}"
  end
end

desc 'View code coverage results'
task :'coverage:view' do
  file = File.absolute_path('coverage/index.html')
  if !File.exists?(file)
    $stderr.puts "Coverage results not present. Run 'rake coverage' first."
    exit
  end

  url = "file:///#{file}"
  Launchy.open(url)
end

desc 'Run tests'
task :default => :spec
