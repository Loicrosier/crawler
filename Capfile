# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git
# require "ed25519 (>= 1.2, < 1.3)"
# require "bcrypt_pbkdf (>= 1.0, < 2.0)"

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails/tree/master/assets
#   https://github.com/capistrano/rails/tree/master/migrations
#
 require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
 require 'capistrano/bundler'
 require 'capistrano/rails/assets'
 require 'capistrano/rails/migrations'
#  require 'capistrano/rails/db'
 require 'capistrano/puma'
 require 'capistrano/puma/nginx'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
