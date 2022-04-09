# set :application, 'crawler'
# set :repo_url, 'git@github.com:Loicrosier/crawler.git'


# server '151.80.7.25', user: 'samuel', roles: %w{web app db}, ssh_options: { forward_agent: true }

# # ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/crawler.dev'
# # set :scm, :git

# # set :format, :pretty
# # set :log_level, :debug
# # set :pty, true

#  set :linked_files, %w{config/database.yml}
#  set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle}

# # set :default_env, { path: "/opt/ruby/bin:$PATH" }
# # set :keep_releases, 5

# set :nginx_config_name, 'crawler_dev'
# set :nginx_server_name, '151.80.7.25'
# set :puma_workers, 2

# namespace :deploy do

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       # Your restart mechanism here, for example:
#       # execute :touch, release_path.join('tmp/restart.txt')
#     end
#   end

#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end

#   after :finishing, 'deploy:cleanup'

# end
