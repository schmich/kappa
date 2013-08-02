# <img src="https://raw.github.com/schmich/kappa/master/assets/kappa.png" /> Kappa

Kappa is the Ruby library for interfacing with the [Twitch.tv API](https://github.com/justintv/Twitch-API).

[![Gem Version](https://badge.fury.io/rb/kappa.png)](http://rubygems.org/gems/kappa)
[![Build Status](https://secure.travis-ci.org/schmich/kappa.png)](http://travis-ci.org/schmich/kappa)
[![Dependency Status](https://gemnasium.com/schmich/kappa.png)](https://gemnasium.com/schmich/kappa)
[![Coverage Status](https://coveralls.io/repos/schmich/kappa/badge.png?branch=master)](https://coveralls.io/r/schmich/kappa?branch=master)
[![Code Climate](https://codeclimate.com/github/schmich/kappa.png)](https://codeclimate.com/github/schmich/kappa)

## Getting Started

```bash
gem install kappa
```

```ruby
require 'kappa'

frag = Twitch.channels.get('lethalfrag')
puts frag.streaming?
```

```ruby
gem 'kappa', '~> 1.0'
```

## Configuration

When making requests to Twitch, you must specify a client ID for your application.
If you do not specify a client ID, Twitch reserves the right to rate-limit your application
without warning.

Your client ID can be specified through configuration, for example:

```ruby
Twitch.configure do |config|
  config.client_id = 'sc2daily-v1.0.0'
end
```

See the [`Twitch.configure`](http://rdoc.info/gems/kappa/Twitch#configure-class_method) documentation.

## Examples

Get the featured streams on the Twitch.tv homepage:

```ruby
Twitch.streams.featured do |stream|
  channel = stream.channel
  puts "#{channel.display_name}: #{stream.viewer_count} viewers"
  puts "#{channel.status}"
  puts '-' * 80
end
```

See if certain users are streaming:

```ruby
users = ['destiny', 'followgrubby', 'incontroltv']
Twitch.streams.find(:channel => users) do |stream|
  puts "#{stream.channel.name} is streaming #{stream.game_name}."
end
```

Get the most popular games being streamed:

```ruby
Twitch.games.top(:limit => 3) do |game|
  print "#{game.name}: "
  print "#{game.viewer_count} viewers in "
  puts  "#{game.channel_count} channels"
end
```

Get streams for a particular game:

```ruby
Twitch.streams.find(:game => 'League of Legends') do |stream|
  next if stream.viewer_count < 1000
  puts "#{stream.channel.display_name}: #{stream.viewer_count}"
end
```

Get info for a single user:

```ruby
user = Twitch.users.get('lethalfrag')
stream = user.stream

puts user.display_name
if stream
  puts "Streaming #{stream.game_name} at #{stream.url}"
else
  puts 'Not streaming.'
end
```

Get the followers of a channel:

```ruby
channel = Twitch.channels.get('day9tv')
channel.followers do |user|
  puts user.display_name
end
```

## Resources

### <a id="channels"></a>Channels

Channels serve as the home location for a [user's](#users) content. Channels have a [stream](#streams),
can run commercials, store [videos](#videos), display information and status, and have a customized page
including banners and backgrounds. See the [`Channel`](http://rdoc.info/gems/kappa/Twitch/V2/Channel) documentation.

```ruby
c = Twitch.channels.get('destiny')
c.nil?        # => false (channel exists)
c.stream      # => #<Kappa::V2::Stream> (current live stream)
c.url         # => "http://www.twitch.tv/destiny"
c.status      # => "Destiny - Diamond I ADC  - Number 1 Draven player..."
c.teams       # => [#<Kappa::V2::Team>]      
c.videos      # => [#<Kappa::V2::Video>, ...]
c.followers   # => [#<Kappa::V2::User>, ...]
```

### <a id="streams"></a>Streams

Streams are video broadcasts that are currently live. They belong to a [user](#users) and are part of a
[channel](#channels). See the [`Stream`](http://rdoc.info/gems/kappa/Twitch/V2/Stream) and
[`Streams`](http://rdoc.info/gems/kappa/Twitch/V2/Streams) documentation.

```ruby
s = Twitch.streams.get('idrajit')
s.nil?          # => false (currently live)
s.game_name     # => "StarCraft II: Heart of the Swarm"
s.viewer_count  # => 7267
s.channel.url   # => "http://www.twitch.tv/idrajit"
```

### <a id="users"></a>Users

These are members of the Twitch community who have a Twitch account. If broadcasting, they can own a
[stream](#streams) that they can broadcast on their [channel](#channels). If mainly viewing, they might
follow or subscribe to channels. See the [`User`](http://rdoc.info/gems/kappa/Twitch/V2/User) documentation.

```ruby
u = Twitch.users.get('snoopeh')
u.nil?                    # => false (user exists)
u.channel                 # => #<Kappa::V2::Channel>
u.following.map(&:name)   # => ["national_esl1", "dreamhacklol", "riotgames"]
```

### <a id="videos"></a>Videos

Videos are broadcasts or highlights owned by a [channel](#channels). Broadcasts are unedited videos that are saved
after a streaming session. Highlights are videos edited from broadcasts by the channel's owner. See the
[`Video`](http://rdoc.info/gems/kappa/Twitch/V2/Video) and [`Videos`](http://rdoc.info/gems/kappa/Twitch/V2/Videos)
documentation.

```ruby
v = Twitch.videos.get('a395995729')
v.nil?          # => false (video exists)
v.title         # => "DreamHack Open Stockholm 26-27 April"
v.game_name     # => "StarCraft II: Heart of the Swarm"
v.recorded_at   # => 2013-04-26 18:33:48 UTC
v.view_count    # => 12506
```

### <a id="teams"></a>Teams

Teams are an organization of [channels](#channels). See the [`Team`](http://rdoc.info/gems/kappa/Twitch/V2/Team)
documentation.

```ruby
t = Twitch.teams.get('teamliquid')
t.nil?          # => false (team exists)
t.display_name  # => "TeamLiquid"
t.info          # => "TeamLiquid is awesome. and esports. video games. \n\n"
t.updated_at    # => 2013-05-24 00:17:10 UTC
```

### <a id="games"></a>Games

Games are categories (e.g. League of Legends, Diablo 3) used by [streams](#streams) and [channels](#channels).
Games can be searched for by query. See the [`Game`](http://rdoc.info/gems/kappa/Twitch/V2/Game),
[`Games`](http://rdoc.info/gems/kappa/Twitch/V2/Games), and
[`GameSuggestion`](http://rdoc.info/gems/kappa/Twitch/V2/GameSuggestion) documentation.

```ruby
top = Twitch.games.top(:limit => 2)
top.map(&:name)  # => ["League of Legends", "StarCraft II: Heart of the Swarm"]
```

```ruby
g = Twitch.games.top(:limit => 1).first
g.name                   # => "League of Legends"
g.channel_count          # => 906
g.viewer_count           # => 79223
g.box_images.medium_url  # =>"http://static-cdn.jtvnw.net/ttv-boxart/31412.jpg"
```

```ruby
s = Twitch.games.find(:name => 'diablo', :live => true)
s.map(&:name)        # => ["Diablo III", "Diablo II", "Diablo"]
s.map(&:popularity)  # => [120, 4, 1]
```

## Errors

All errors derive from `Twitch::Error`.

- `Twitch:Error` - Base class for all errors.
- `Twitch::Error::ResponseError` - Base class for all Twitch.tv API response errors.
- `Twitch::Error::FormatError` - The returned data was incorrectly formatted (e.g. invalid JSON).
- `Twitch::Error::ClientError` - The server returned a 4xx status code.
- `Twitch::Error::ServerError` - The server returned a 5xx status code.

All `ResponseError` errors have additional diagnostic information:

```ruby
e.status # => 422
e.body   # => '{"status":422,"message":"...","error":"..."}'
e.url    # => "https://api.twitch.tv/streams/desrow"
```

See the [`ResponseError`](http://rdoc.info/gems/kappa/Twitch/Error/ResponseError) documentation.

## Documentation

- Current release: [http://rdoc.info/gems/kappa/frames](http://rdoc.info/gems/kappa/frames)
- Latest master: [http://rdoc.info/github/schmich/kappa/frames](http://rdoc.info/github/schmich/kappa/frames)
- Twitch REST API: [https://github.com/justintv/Twitch-API](https://github.com/justintv/Twitch-API)

## Versioning

### Library version

Kappa adheres to the [Semantic Versioning 2.0.0](http://semver.org/) specification. Most importantly, any
compatibility- or API-breaking changes will result in a new major version (e.g. `1.x.x` to `2.x.x`). Because
of this, you should use a [pessimistic version constraint](http://docs.rubygems.org/read/chapter/16#page74) when
taking a dependency on this library. For example:

```ruby
gem 'kappa', '~> 1.0'
```

Any new backwards-compatible features will result in a new minor version (e.g. `x.1.x` to `x.2.x`) while any
backwards-compatible bugfixes will result in a new patch version (e.g. `x.x.1` to `x.x.2`).

### Twitch API versions

Twitch supports multiple versions of their API simultaneously, with each version potentially providing different data
and behaving differently. Because of this, you can specify which version of the Twitch API you wish to use.
This is done through Kappa configuration.

For example, if you want to use the V2 Twitch API:

```ruby
Twitch.configure do |config|
  config.client_id = 'sc2daily-v1.0.0'
  config.api = Twitch::V2
end
```

`Twitch::V2` is the default and is currently the only supported API version.

## Contributing

- [Fork and clone the repo.](http://help.github.com/fork-a-repo/)
- [Create a branch for your changes.](http://git-scm.com/book/en/Git-Branching-Basic-Branching-and-Merging)
- Run `bundle install` to install development requirements.
- Implement your feature or bug fix.
- Add specs under the `spec` folder to prevent regressions or to test new code.
- Add [YARD](http://rubydoc.info/docs/yard/file/docs/GettingStarted.md) documentation for new features. Run `rake yard` to view documentation.
- Run `rake coverage` to run specs with code coverage. All specs must pass; coverage must remain at 100%. Run `rake coverage:view` to see a detailed report.
- Commit and push your changes.
- [Submit a pull request.](http://help.github.com/send-pull-requests/)

## License

Copyright &copy; 2013 Chris Schmich
<br />
MIT License, See [LICENSE](LICENSE) for details.
[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/b885add21cf8f2b473d1394edc1cf5b4 "githalytics.com")](http://githalytics.com/schmich/kappa)
