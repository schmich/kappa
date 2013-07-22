require 'rspec'
require 'kappa'
require 'common'

describe Twitch::V2::Stream do
  before do
    WebMocks.load_dir(fixture('stream'))
  end

  after do
    WebMock.reset!
  end

  describe '.new' do
    it 'accepts a hash' do
      hash = yaml_load('stream/stream_riotgames.yml')
      s = Stream.new(hash, nil)
      s.id.should == hash['_id']
      s.broadcaster.should == hash['broadcaster']
      s.game_name.should == hash['game']
      s.name.should == hash['name']
      s.viewer_count.should == hash['viewers']
      s.preview_url.should == hash['preview']
      s.channel.should_not be_nil
      s.url.should_not be_nil
    end

    it 'has an associated channel' do
      hash = yaml_load('stream/stream_riotgames.yml')
      s = Stream.new(hash, nil)
      c = s.channel
      c.should_not be_nil
    end
  end
  
  describe '#user' do
    it 'returns the user owning the stream' do
      s = Twitch.streams.get('nathanias')
      s.should_not be_nil
      u = s.user
      u.should_not be_nil
      s.channel.name.should == u.name
    end
  end
end

describe Twitch::V2::Streams do
  before do
    WebMocks.load_dir(fixture('stream'))
  end

  after do
    WebMock.reset!
  end

  describe '#get' do
    it 'creates a Stream from stream name' do
      s = Twitch.streams.get('riotgames')
      s.should_not be_nil
    end

    it 'returns nil when stream does not exist' do
      s = Twitch.streams.get('does_not_exist')
      s.should be_nil
    end

    it 'returns nil when stream is offline' do
      s = Twitch.streams.get('offline_stream')
      s.should be_nil
    end

    it 'returns nil when the stream is associated with a Justin.tv account' do
      c = Twitch.streams.get('desrow')
      c.should be_nil
    end
  end

  describe '#find' do
    it 'requires some query parameter' do
      expect {
        Twitch.streams.find({})
      }.to raise_error(ArgumentError)
    end

    it 'requires some query parameter besides limit and offset' do
      expect {
        Twitch.streams.find(:limit => 10, :offset => 0)
      }.to raise_error(ArgumentError)
    end

    it 'rejects a :channel scalar' do
      expect {
        Twitch.streams.find(:channel => 'mlgsc2')
      }.to raise_error(ArgumentError)
    end

    it 'can query streams by channel list' do
      s = Twitch.streams.find(:channel => ['mlgsc2', 'rootcatz', 'crs_saintvicious', 'phantoml0rd'])
      s.should_not be_nil
      s.length.should == 4
    end

    it 'can query streams by Channel' do
      c = Channel.new(yaml_load('channel/lethalfrag.yml'), nil)
      s = Twitch.streams.find(:channel => [c])
      s.should_not be_nil
      s.length.should == 1
    end

    it 'can query streams by game name' do
      s = Twitch.streams.find(:game => 'StarCraft II: Heart of the Swarm')
      s.should_not be_nil
      s.length.should == 156
    end

    it 'can limit paginated results' do
      s = Twitch.streams.find(:game => 'StarCraft II: Heart of the Swarm', :limit => 120)
      s.should_not be_nil
      s.length.should == 120
    end

    it 'can filter by :hls parameter' do
      s = Twitch.streams.find(:hls => true, :limit => 10)
      s.should_not be_nil
      s.count.should == 10
    end

    it 'can filter by :embeddable parameter' do
      s = Twitch.streams.find(:embeddable => true, :limit => 10)
      s.should_not be_nil
      s.count.should == 10
    end

    it 'can query streams by game name with limit' do
      s = Twitch.streams.find(:game => 'League of Legends', :limit => 10)
      s.length.should == 10
    end

    it 'can query streams by Game objects' do
      g = Game.new(yaml_load('game/game.yml'))
      s = Twitch.streams.find(:game => g, :limit => 10)
      s.should_not be_nil
      s.length.should == 10
    end

    it 'can query by channel list when someone is not streaming' do
      s = Twitch.streams.find(:channel => ['leveluplive', 'djwheat'])
      s.length.should == 1
    end

    it 'can query by channel list and game name' do
      s = Twitch.streams.find(:channel => ['quantichyun', 'sc2sage'], :game => 'StarCraft II: Heart of the Swarm')
      s.length.should == 2
    end

    it 'filters out duplicate streams' do
      s = Twitch.streams.find(:game => 'Ultimate Marvel vs. Capcom 3')
      s.length.should == 2
    end

    it 'can find many streams at once' do
      channels = ['psystarcraft', 'steven_bonnell_ii', 'destiny', 'whitera', 'combatex', 'day9tv', 'beastyqt', 'huskystarcraft', 'incontroltv', 'liquidjinro', 'slayersmin', 'eghuk', 'eg_idra', 'idrajit', 'fxoqxc', 'colqxc', 'tslkiller', 'colkiller', 'demuslim', 'axslav', 'strifecro', 'liquidsheth', 'liquidhaypro', 'liquidhero', 'liquidret', 'rrb115', 'liquidtyler', 'liquidnony', 'nony', 'liquidtlo', 'desrowfighting', 'hongun', 'megumixbear', 'colcatz', 'rootcatz', 'slayersyugioh', 'slayerscella', 'tt1', 'hellosase', 'dignitasselect', 'selectkr', 'vibelol', 'slayersgolden', 'golden', 'ailujsc', 'tslpolt', 'thorzain', 'ignproleague', 'ignproleague2', 'ignproleague3', 'pokebunny', 'coldrewbie', 'hwangsin', 'tslalive', 'gomtv', 'artosis', 'rgnartist', 'helloflo', 'satiinifi', 'dignitasapollo', 'playhemtv', 'colminigun', 'vileyong', 'proddongs', 'ddoro', 'lalush5', 'slayersdragon', 'lessonforyou', 'machineusa', 'tslrevival', 'kimsungje', 'wayne379', 'dignitaskiller', 'zenexpuzzle', 'daisyprime', 'followgrubby', 'esaharanaama', 'checkpooh', 'esltv_event2', 'esltv_event', 'esltv_studio2', 'esltv_sc2', 'eslsea', 'sc2guineapig', 'spanishiwa', 'illusioncss', 'quanticillusion', 'illusionsc', 'mouzmorrow', 'ministryofwin_morrow', 'morrow', 'esvision', 'sjow', 'kawaiirice', 'fxopenesports', 'ogsforgg', 'fxoptikzero', 'ogsvns', 'nasltv', 'nasls3', 'nasls4', 'dignitasbling', 'lzgamertv', 'egjyp', 'annaprosser', 'mlg_live', 'jechotv', 'stateofthegame', '92sleep', 'col_heart', 'setttv', 'protech', 'stimstarcraft', 'mstephano', 'egstephano', 'ewm', 'col_nada', 'onemoregametv', 'dragon', 'lonestarclash', 'lonestarclash2', 'ganzi', 'complexity', 'atncloud', 'mlgstarcrafta', 'mlgstarcraftb', 'mlg_drpepper', 'mlg_sca', 'mlgsc2', 'mlgsc2a', 'mlgsc2b', 'mlgsc2c', 'mlgsc2d', 'ironsquid', 'orbtl', 'liquidtaeja', 'lagtvmaximusblack', 'onenationofgamers', 'iscrazymoving', 'msspyte', 'coltrimaster', 'cstarleague', 'dreamhacktv', 'dreamhacksc2', 'dreamhacksc2b', 'imls', 'fitzyhere', 'puckk', 'thegdstudio', 'thegesl', 'thegesl2', 'glhf', 'teamliquidnet', 'sockesc2', 'cybersportsnetwork', 'milleniumgaminghouse', 'taketv', 'taketvbstream', 'superiorwolf', 'aclprosc2', 'dongraegu', 'crank', 'azubuviolet', 'rotterdam08', 'slush', 'partsasquatch', 'chanmanv', 'quantichawk', 'vilehawk', 'scarlettm', 'yoanm', 'empiretvkas', 'mvptails', 'liquidsea', 'starnan', 'gaulzi', 'primetv', 'avilo', 'thehandsomenerd', 'ssonlight', 'fxoleenock', 'fxoasd', 'sc2', 'sc2_2', 'sc2_3', 'sc2_4', 'liquidzenio', 'naniwasc2', 'sc2proleague', 'thoropensc2', 'millfeast', 'totalbiscuit', 'egjd', 'fxogumiho', 'lucifron7', 'the_13abyknight', 'fxolucky', 'elfi', 'sortofsc', 'ogssupernova', 'liquidsnute', 'sc2sage', 'axmiya', 'quanticcenter', 'apollosc2', 'universitysl', 'acermma', 'quantichyun', 'starcraft', 'caliber206', 'gomtv_en', 'wcs_gsl', 'wcs_gsl2', 'khaldor', 'tumescentpie', 'wcs_europe', 'wcs_europe2', 'mentalking', 'zlfreebird', 'kaitlyn', 'nathanias', 'sc2daisy', 'wcs_america', 'tarababcock', 'noobeater5', 'my4590', 'fxochoya', 'temp0_sc', 'massansc', 'filtersc', 'itmejp', 'marinekingprime', 'kanesc2', 'nasl_lauren', 'wcs_osl', 'wcs_osl2', 'xenocidersc2', 'imarinetv']
      s = Twitch.streams.find(:channel => channels)
      s.should_not be_nil
      s.should_not be_empty
      s.length.should == 11
    end
  end

  describe '#featured' do
    it 'returns a list of featured streams' do
      s = Twitch.streams.featured
      s.should_not be_nil
      s.count.should == 15
      s.each { |e| e.class.should == Stream }
    end

    it 'limits the number of results based on the :limit parameter' do
      s = Twitch.streams.featured(:limit => 3)
      s.should_not be_nil
      s.count.should == 3
      s.each { |e| e.class.should == Stream }
    end

    it 'returns results offset by the :offset parameter' do
      s = Twitch.streams.featured(:offset => 5)
      s.should_not be_nil
      s.count.should == 22
    end

    it 'can filter by :hls parameter' do
      s = Twitch.streams.featured(:hls => true, :limit => 5)
      s.should_not be_nil
      s.count.should == 5
    end
  end
end
