#!/usr/bin/env ruby

# yeah, this is gonna take an hour or two to run

# set the heroku app name in env variable HEROKU_APP
# so we can make the right url to siege

# Also local repo needs it's heroku git remote set up,
# and pushable (heroku login etc). 

branches = %w{unicorn unicorn_4_workers puma puma_clustered puma_clustered_4_workers}

logfile     = ENV['LOG'] || 'siege.log'
heroku_app  = ENV['HEROKU_APP']
query       = ENV['QUERY']
max_conc    = ENV['MAX_CONC'] || 20

if heroku_app.nil? || heroku_app == ""
  abort("Please set heroku app name in env HEROKU_APP. Exiting.")
end

branches.each do |branch|
  
  heroku_push_cmd = "git push -f heroku origin/#{branch}:master"
  `#{heroku_push_cmd}`
  unless $?.exitstatus == 0
   abort("Git push to heroku of #{branch} failed, we're aborting the whole thing man, you deal with it!") 
  end

   sleep(12) # give app a bit of time to get comfortable. superstitious much?
   
   1.upto(max_conc) do |concurrency|
     sleep(10) # give it a breather so everything gets through the system!
     marker_arg = (concurrency == 1) ? "-m \"#{branch}\"" : ""
     command = "siege -b -c#{concurrency} -t30s http://#{heroku_app}.herokuapp.com/fake_work?#{query} -l#{logfile} #{marker_arg}"
     puts command
     `#{command}`
   end 
end
