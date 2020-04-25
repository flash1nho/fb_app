rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'
config_file = rails_root + '/config/resque.yml'

resque_config = YAML::load(ERB.new(IO.read(config_file)).result)
Resque.redis = resque_config[rails_env]
Resque.logger.level = Logger::DEBUG
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))
Resque.redis.namespace = 'resque:funbox_app'
Resque.schedule = YAML.load_file Rails.root.join('config', 'resque_schedule.yml')
