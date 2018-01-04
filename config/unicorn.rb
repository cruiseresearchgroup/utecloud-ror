# config/unicorn.rb
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 10)
timeout 3600
preload_app true

# :tcp_nopush This prevents partial TCP frames from being sent out
# :tcp_nodelay Disables Nagle’s algorithm on TCP sockets if true.
port = ENV["PORT"].to_i || 3000
# the ENV["PORT"] is a Heroku environment variable
listen port, tcp_nopush: false, tcp_nodelay: true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
