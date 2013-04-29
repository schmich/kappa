require 'rake/testtask'
require 'fileutils'

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

Rake::TestTask.new do |t|
  t.libs << 'test'
end

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

  unless (`git branch --no-color`.strip rescue '') =~ /\A*\s+master\z/
    puts 'You must release from the master branch.'
    exit!
  end

  version = $gem.version
  puts "Releasing version #{version}."

  sh "git commit --allow-empty -a -m \"Release #{version}.\""
  sh "git tag v#{version}"
  sh 'git push origin master'
  sh "git push origin v#{version}"
  sh "gem push gem/#{$gem.gem_filename}"

  puts 'Fin.'
end

desc 'Run tests'
task :default => :test
