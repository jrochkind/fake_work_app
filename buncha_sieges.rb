#!/usr/bin/env ruby

# yeah, this is gonna take an hour or two to run

branches = %w{unicorn unicorn_4_workers puma puma_clustered puma_clustered_4_workers}

logfile     = ENV['LOG'] || 'siege.log'
heroku_app  = ENV['HEROKU_APP']
query       = ENV['QUERY']
max_conc    = ENV['MAX_CONC'] || 20

branches.each do |branch|
  
  `git push -f heroku origin/#{branch}:master`
   sleep(5) # give app a bit of time to get comfortable
   
   1.upto(max_conc) do |concurrency|
     sleep(10) # give it a breather so everything gets through the system!
     marker_arg = (concurrency == 1) ? "-m \"#{branch}\"" : ""
     command = "siege -b -c#{concurrency} -t30s http://#{heroku_app}.herokuapp.com/fake_work?#{query} -l#{logfile} #{marker_arg}"
     puts command
     `#{command}`
   end 
end
