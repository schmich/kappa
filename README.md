# <img src="http://static-cdn.jtvnw.net/jtv_user_pictures/chansub-global-emoticon-ddc6e3a8732cb50f-25x28.png" /> Kappa

Kappa is a Ruby library for interfacing with the [Twitch.tv Kraken API](https://github.com/justintv/Twitch-API).

## Getting Started

`gem install kappa --pre`

```ruby
require 'kappa'

include Kappa::V2

grubby = Channel.get('followgrubby')
puts grubby.streaming?
```

## Examples

## Contributing

## License

Copyright &copy; 2013 Chris Schmich
<br />
MIT License, see LICENSE for details.
