require 'kappa/id_equality'
require 'kappa/connection'
require 'kappa/channel'
require 'kappa/stream'
require 'kappa/game'
require 'kappa/video'
require 'kappa/team'
require 'kappa/user'
require 'kappa/images'
require 'kappa/twitch'
require 'kappa/version'

# TODO
# https://github.com/justintv/Twitch-API
# Blocks
#   GET /users/:login/blocks
#   PUT /users/:user/blocks/:target
#   DELETE /users/:user/blocks/:target
# Channels
#   - GET /channels/:channel
#   GET /channel
#   GET /channels/:channel/editors
#   PUT /channels/:channel
#   GET /channels/:channel/videos
#   GET /channels/:channel/follows
#   DELETE /channels/:channel/stream_key
#   POST /channels/:channel/commercial
# Chat
#   GET /chat/:channel
#   GET /chat/emoticons
# Follows
#   GET /channels/:channel/follows
#   GET /users/:user/follows/channels
#   GET /users/:user/follows/channels/:target
#   PUT /users/:user/follows/channels/:target
#   DELETE /users/:user/follows/channels/:target
# Games
#   - GET /games/top
# Ingests
#   GET /ingests
# Root
#   GET /
# Search
#   GET /search/streams
#   - GET /search/games
# Streams
#   - GET /streams/:channel
#   - GET /streams
#   GET /streams/featured
#   GET /streams/summary
#   GET /streams/followed
# Subscriptions
#   GET /channels/:channel/subscriptions
#   GET /channels/:channel/subscriptions/:user
# Teams
#   GET /teams
#   GET /teams/:team
# Users
#   GET /users/:user
#   GET /user
#   GET /streams/followed
# Videos
#   GET /videos/:id
#   GET /videos/top
#   GET /channels/:channel/videos

# Overarching
# - Common query syntax
# - Access to raw properties (e.g. stream['game'] or stream.raw('game'))
# - Paginated results take a block to allow for intermediate processing/termination

# t = Kappa::Client.new
# c = t.channel('lagtvmaximusblack')
# c.editors -> [...]
# c.videos -> [...]
# c.followers -> [...]
# c.subscriptions
# c.start_commercial
# c.reset_stream_key
# c... ; c.save! 
# TODO: current user channel

# t = Kappa::Client.new
# t.streams.all
# t.streams.all(:limit => 10)
# t.streams.featured
# t.streams.where(:channel => 'lagtvmaximusblack')
# t.streams.where(:channel => [...], :game => '...', :embeddable => t/f, :hls => t/f)
# t.stream_summary
