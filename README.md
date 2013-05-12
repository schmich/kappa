# <img src="https://raw.github.com/schmich/kappa/master/assets/kappa.png" /> Kappa

Kappa is the Ruby library for interfacing with the [Twitch.tv API](https://github.com/justintv/Twitch-API).

[![Gem Version](https://badge.fury.io/rb/kappa.png)](http://rubygems.org/gems/kappa)
[![Build Status](https://secure.travis-ci.org/schmich/kappa.png)](http://travis-ci.org/schmich/kappa)
[![Dependency Status](https://gemnasium.com/schmich/kappa.png)](https://gemnasium.com/schmich/kappa)
[![Coverage Status](https://coveralls.io/repos/schmich/kappa/badge.png?branch=master)](https://coveralls.io/r/schmich/kappa?branch=master)
[![Code Climate](https://codeclimate.com/github/schmich/kappa.png)](https://codeclimate.com/github/schmich/kappa)

## Getting Started

`gem install kappa --pre`

```ruby
require 'kappa'

include Kappa::V2

grubby = Channel.get('followgrubby')
puts grubby.streaming?
```

## Examples

### Channels

Channels serve as the home location for a [user's](#users) content. Channels have a [stream](#streams), can run commercials, store [videos](#videos), display information and status, and have a customized page including banners and backgrounds.

See also [`Kappa::V2::Channel`](http://rdoc.info/github/schmich/kappa/master/Kappa/V2/Channel) documentation.

```ruby
c = Channel.get('destiny')
c.nil?        # => false (channel exists)
c.stream      # => #<Kappa::V2::Stream> (current live stream)
c.url         # => "http://www.twitch.tv/destiny"
c.status      # => "Destiny - Diamond I ADC  - Number 1 Draven player..."
c.teams       # => []      
c.videos      # => []
c.followers   # => []
```

### Streams

Streams are video broadcasts that are currently live. They have a [broadcaster](#users) and are part of a [channel](#channels).

See also [`Kappa::V2::Stream`](http://rdoc.info/github/schmich/kappa/master/Kappa/V2/Stream) and [`Kappa::V2::Streams`](http://rdoc.info/github/schmich/kappa/master/Kappa/V2/Streams) documentation.

```ruby
s = Stream.get('idrajit')
s.nil?          # => false (currently live)
s.game_name     # => "StarCraft II: Heart of the Swarm"
s.viewer_count  # => 7267
s.channel.url   # => "http://www.twitch.tv/idrajit"
```

### Users

These are members of the Twitch community who have a Twitch account. If broadcasting, they can own a [stream](#streams) that they can broadcast on their [channel](#channels). If mainly viewing, they might follow or subscribe to channels.

See also [`Kappa::V2::User`](http://rdoc.info/github/schmich/kappa/master/Kappa/V2/User) documentation.

```ruby
u = User.get('snoopeh')
u.nil?                    # => false (user exists)
u.channel                 # => #<Kappa::V2::Channel>
u.following.map(&:name)   # => ["national_esl1", "dreamhacklol", "riotgames"]
```

### Videos

Videos are broadcasts or highlights owned by a [channel](#channels). Broadcasts are unedited videos that are saved after a streaming session. Highlights are videos edited from broadcasts by the channel's owner.

See also [`Kappa::V2::Video`](http://rdoc.info/github/schmich/kappa/master/Kappa/V2/Video) and [`Kappa::V2::Videos`](http://rdoc.info/github/schmich/kappa/master/Kappa/V2/Videos) documentation.

```ruby
v = Video.get('a395995729')
v.nil?          # => false (video exists)
v.title         # => "DreamHack Open Stockholm 26-27 April"
v.game_name     # => "StarCraft II: Heart of the Swarm"
v.recorded_at   # => #<DateTime: 2013-04-26T18:33:48+00:00>
v.view_count    # => 12506
```

### Teams

Teams are an organization of [channels](#channels).

### Games

Games are categories (e.g. League of Legends, Diablo 3) used by [streams](#streams) and [channels](#channels). Games can be searched for by query.

## Documentation

Detailed API documentation is avaiable at [http://rdoc.info/github/schmich/kappa/master/frames](http://rdoc.info/github/schmich/kappa/master/frames).

## Contributing

- [Fork and clone the repo.](http://help.github.com/fork-a-repo/)
- [Create a branch for your changes.](http://learn.github.com/p/branching.html)
- Run `bundle install` to install development requirements.
- Implement your feature or bug fix.
- Add specs under the `spec` folder to prevent regressions or to test new code.
- Add [YARD](http://rubydoc.info/docs/yard/file/docs/GettingStarted.md) documentation for new features.
- Run `rake` to run specs. Everything must pass.
- Commit and push your changes.
- [Submit a pull request.](http://help.github.com/send-pull-requests/)

## License

Copyright &copy; 2013 Chris Schmich
<br />
MIT License, See [LICENSE](LICENSE) for details.
