require 'resque'
require 'resque/tasks'
require 'resque-scheduler'
require 'resque/scheduler/tasks'

task 'resque:setup' => :environment

namespace :resque do
  task :setup do
    ENV['QUEUE'] = 'exchange_rate'
  end
end
