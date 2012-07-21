require 'bundler/capistrano'
load 'deploy/assets'

# Load RVM's capistrano plugin.
require "rvm/capistrano"

# Multi-stage support
set :stages, %w(staging production)
require 'capistrano/ext/multistage'

#set :rvm_path, "$HOME/.rvm"
set :rvm_ruby_string, "1.9.3"
set :rvm_type, :user

set :application, "chatty"
set :repository,  "git@github.tenderlove/chatty.git"

set :scm, :git
ssh_options[:forward_agent] = true

set :keep_release, 5

set :branch, 'master'

set :user, 'deploy'
set :use_sudo, false

set :home_dir, "/home/#{user}/#{application}"

set :deploy_to, "#{home_dir}"
set :deploy_via, :copy
set :scm_verbose, true
set :copy_exclude, [".git", ".DS_Store", ".gitignore", ".gitmodules"]

set :bundle_roles, [:app]

# if you want to clean up old releases on each deploy uncomment this:
after "deploy", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  namespace :web do
    task :disable, :roles => :web, :except => {:no_release => true} do
      require 'haml'
      on_rollback {run "rm #{shared_path}/system/maintenance.html"}

      reason = ENV['REASON']  || " for maintenance."
      deadline = ENV['UNTIL']  || " in the next 30 minutes."

      template = File.read("./app/views/layouts/maintenance.html.haml")

      result = Haml::Engine.new(template).render

      put result, "#{shared_path}/system/maintenance.html", :mode =>0644
    end
  end
end
