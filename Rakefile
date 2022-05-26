namespace :muck do

  desc "Start the cron worker"
  task :cron do
    require 'clockwork'
    config_file_path = ENV['MUCK_CONFIG_PATH'] || File.expand_path('/config')
    require config_file_path.join('cron')
    trap('TERM') { puts "Exiting..."; Process.exit(0) }
    Clockwork.run
  end

end