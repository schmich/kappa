require 'rspec'
require 'kappa'
require 'common'

include Kappa::V2

describe Kappa::V2::Streams do
  before do
    WebMocks.load_dir(fixture('streams'))
  end

  after do
    WebMock.reset!
  end

  describe '.find' do
    it 'requires some query parameter' do
      expect {
        Streams.find({})
      }.to raise_error(ArgumentError)
    end

    it 'requires some query parameter besides limit and offset' do
      expect {
        Streams.find(:limit => 10, :offset => 0)
      }.to raise_error(ArgumentError)
    end

    it 'can query streams by channel list' do
      s = Streams.find(:channel => ['mlgsc2', 'rootcatz', 'crs_saintvicious', 'phantoml0rd'])
      s.length.should == 4
    end

    it 'can query streams by game name' do
      s = Streams.find(:game => 'StarCraft II: Heart of the Swarm')
      s.length.should == 156
    end

    it 'can query streams by game name with limit' do
      s = Streams.find(:game => 'League of Legends', :limit => 10)
      s.length.should == 10
    end

    it 'can query by channel list when someone is not streaming' do
      s = Streams.find(:channel => ['leveluplive', 'djwheat'])
      s.length.should == 1
    end

    it 'can query by channel list and game name' do
      s = Streams.find(:channel => ['quantichyun', 'sc2sage'], :game => 'StarCraft II: Heart of the Swarm')
      s.length.should == 2
    end

    it 'filters out duplicate streams' do
      s = Streams.find(:game => 'Ultimate Marvel vs. Capcom 3')
      s.length.should == 2
    end

    it 'can find many streams at once' do
      channels = ['psystarcraft', 'steven_bonnell_ii', 'destiny', 'whitera', 'combatex', 'day9tv', 'beastyqt', 'huskystarcraft', 'incontroltv', 'liquidjinro', 'slayersmin', 'eghuk', 'eg_idra', 'idrajit', 'fxoqxc', 'colqxc', 'tslkiller', 'colkiller', 'demuslim', 'axslav', 'strifecro', 'liquidsheth', 'liquidhaypro', 'liquidhero', 'liquidret', 'rrb115', 'liquidtyler', 'liquidnony', 'nony', 'liquidtlo', 'desrowfighting', 'hongun', 'megumixbear', 'colcatz', 'rootcatz', 'slayersyugioh', 'slayerscella', 'tt1', 'hellosase', 'dignitasselect', 'selectkr', 'vibelol', 'slayersgolden', 'golden', 'ailujsc', 'tslpolt', 'thorzain', 'ignproleague', 'ignproleague2', 'ignproleague3', 'pokebunny', 'coldrewbie', 'hwangsin', 'tslalive', 'gomtv', 'artosis', 'rgnartist', 'helloflo', 'satiinifi', 'dignitasapollo', 'playhemtv', 'colminigun', 'vileyong', 'proddongs', 'ddoro', 'lalush5', 'slayersdragon', 'lessonforyou', 'machineusa', 'tslrevival', 'kimsungje', 'wayne379', 'dignitaskiller', 'zenexpuzzle', 'daisyprime', 'followgrubby', 'esaharanaama', 'checkpooh', 'esltv_event2', 'esltv_event', 'esltv_studio2', 'esltv_sc2', 'eslsea', 'sc2guineapig', 'spanishiwa', 'illusioncss', 'quanticillusion', 'illusionsc', 'mouzmorrow', 'ministryofwin_morrow', 'morrow', 'esvision', 'sjow', 'kawaiirice', 'fxopenesports', 'ogsforgg', 'fxoptikzero', 'ogsvns', 'nasltv', 'nasls3', 'nasls4', 'dignitasbling', 'lzgamertv', 'egjyp', 'annaprosser', 'mlg_live', 'jechotv', 'stateofthegame', '92sleep', 'col_heart', 'setttv', 'protech', 'stimstarcraft', 'mstephano', 'egstephano', 'ewm', 'col_nada', 'onemoregametv', 'dragon', 'lonestarclash', 'lonestarclash2', 'ganzi', 'complexity', 'atncloud', 'mlgstarcrafta', 'mlgstarcraftb', 'mlg_drpepper', 'mlg_sca', 'mlgsc2', 'mlgsc2a', 'mlgsc2b', 'mlgsc2c', 'mlgsc2d', 'ironsquid', 'orbtl', 'liquidtaeja', 'lagtvmaximusblack', 'onenationofgamers', 'iscrazymoving', 'msspyte', 'coltrimaster', 'cstarleague', 'dreamhacktv', 'dreamhacksc2', 'dreamhacksc2b', 'imls', 'fitzyhere', 'puckk', 'thegdstudio', 'thegesl', 'thegesl2', 'glhf', 'teamliquidnet', 'sockesc2', 'cybersportsnetwork', 'milleniumgaminghouse', 'taketv', 'taketvbstream', 'superiorwolf', 'aclprosc2', 'dongraegu', 'crank', 'azubuviolet', 'rotterdam08', 'slush', 'partsasquatch', 'chanmanv', 'quantichawk', 'vilehawk', 'scarlettm', 'yoanm', 'empiretvkas', 'mvptails', 'liquidsea', 'starnan', 'gaulzi', 'primetv', 'avilo', 'thehandsomenerd', 'ssonlight', 'fxoleenock', 'fxoasd', 'sc2', 'sc2_2', 'sc2_3', 'sc2_4', 'liquidzenio', 'naniwasc2', 'sc2proleague', 'thoropensc2', 'millfeast', 'totalbiscuit', 'egjd', 'fxogumiho', 'lucifron7', 'the_13abyknight', 'fxolucky', 'elfi', 'sortofsc', 'ogssupernova', 'liquidsnute', 'sc2sage', 'axmiya', 'quanticcenter', 'apollosc2', 'universitysl', 'acermma', 'quantichyun', 'starcraft', 'caliber206', 'gomtv_en', 'wcs_gsl', 'wcs_gsl2', 'khaldor', 'tumescentpie', 'wcs_europe', 'wcs_europe2', 'mentalking', 'zlfreebird', 'kaitlyn', 'nathanias', 'sc2daisy', 'wcs_america', 'tarababcock', 'noobeater5', 'my4590', 'fxochoya', 'temp0_sc', 'massansc', 'filtersc', 'itmejp', 'marinekingprime', 'kanesc2', 'nasl_lauren', 'wcs_osl', 'wcs_osl2', 'xenocidersc2', 'imarinetv']
      s = Streams.find(:channel => channels)
      s.should_not be_nil
      s.should_not be_empty
      s.length.should == 11
    end
  end

  describe '.featured' do
    it 'returns a list of featured streams' do
      s = Streams.featured
      s.should_not be_nil
      s.count.should == 15
      s.each { |e| e.class.should == Stream }
    end

    it 'limits the number of results based on the :limit parameter' do
      s = Streams.featured(:limit => 3)
      s.should_not be_nil
      s.count.should == 3
      s.each { |e| e.class.should == Stream }
    end
  end
end
