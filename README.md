# <img src="https://raw.github.com/schmich/kappa/master/assets/kappa.png" /> Kappa

Kappa is a Ruby library for interfacing with the [Twitch.tv API](https://github.com/justintv/Twitch-API).

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

```ruby
c = Channel.get('destiny')

c.nil?                # Does the requested channel not exist? (ex: false)
c.name                # Unique Twitch name (ex: "destiny")
c.display_name        # Display name, e.g. name used for page title (ex: "Destiny")
c.stream              # The currently live stream for this channel (ex: #<Kappa::V2::Stream> object)
c.url                 # The URL for the channel's main page (ex: "http://www.twitch.tv/destiny")
c.status              # Current status (ex: "Destiny - Diamond I ADC  - Number 1 Draven player in the entire Omaha (NE) metro area -watch from http://www.destiny.gg")
c.streaming?          # Is the channel currently streaming? (ex: true)
c.game_name           # Name of the primary game for this channel (ex: "League of Legends")
c.mature?             # Does the channel have mature content? (ex: true)
c.id                  # Unique Twitch ID (ex: 18074328)
c.created_at          # When the channel was created (ex: #<DateTime: 2010-11-22T04:14:56+00:00 ((2455523j,15296s,0n),+0s,2299161j)>)
c.updated_at          # When the channel was last updated, e.g. last stream time (ex: #<DateTime: 2013-05-11T19:57:29+00:00 ((2456424j,71849s,0n),+0s,2299161j)>)
c.background_url      # URL for background image (ex: "http://static-cdn.jtvnw.net/jtv_user_pictures/destiny-channel_background_image-ab706db77853e079.jpeg")
c.banner_url          # URL for banner image (ex: "http://static-cdn.jtvnw.net/jtv_user_pictures/destiny-channel_header_image-d2b9b2452f67ec00-640x125.jpeg")
c.logo_url            # URL for logo image (ex: "http://static-cdn.jtvnw.net/jtv_user_pictures/destiny-profile_image-168e66661c484c5e-300x300.jpeg")
c.video_banner_url    # URL for the image shown when the stream is offline (ex: "http://static-cdn.jtvnw.net/jtv_user_pictures/destiny-channel_offline_image-7a21fd1bd88c4ac3-640x360.jpeg")

c.videos
c.teams
c.subscribers
c.editors
c.followers
c.has_subscriber?
```

### Streams

Streams are video broadcasts that are currently live. They have a [broadcaster](#users) and are part of a [channel](#channels).

### Users

These are members of the Twitch community who have a Twitch account. If broadcasting, they can own a [stream](#streams) that they can broadcast on their [channel](#channels). If mainly viewing, they might follow or subscribe to channels.

### Videos

Videos are broadcasts or highlights owned by a [channel](#channels). Broadcasts are unedited videos that are saved after a streaming session. Highlights are videos edited from broadcasts by the channel's owner.

### Teams

Teams are an organization of [channels](#channels).

### Games

Games are categories (e.g. League of Legends, Diablo 3) used by [streams](#streams) and [channels](#channels). Games can be searched for by query.

## Contributing

## License

Copyright &copy; 2013 Chris Schmich
<br />
MIT License, See [LICENSE](LICENSE) for details.
