# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

set :branch, ENV['branch'] || "#{`git branch`.scan(/^\* (\S+)/)}"

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

# The name of your application. Used for directory and file names associated with
# the application.
set :application, "members"

# Target directory for the application on the web and app servers.
set :deploy_to, "/home/aor/#{application}"

# Login user for ssh.
set :user, "aor" # "deploy"

# URL of your source repository.
set :scm, :git
set :repository, "git@github.com:austinonrails/members.git"
set :deploy_via, :remote_cache

# Primary domain name of your application. Used as a default for all server roles.
set :domain, "members.austinonrails.org"
set :use_sudo, false
set :shared_path, "/home/aor"
# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

# Modify these values to execute tasks on a different server.
role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain

# Automatically symlink these directories from curent/public to shared/public.
# set :app_symlinks, %w{photo document asset}

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25
ssh_options[:forward_agent] = true

# =============================================================================
# CAPISTRANO OPTIONS
# =============================================================================
default_run_options[:pty] = true
set :keep_releases, 20

# =============================================================================
# CUSTOM CAPISTRANO RECIPES
# =============================================================================

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  desc "Make symlink for database.yml" 
  task :symlink_dbyaml do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
  end

  desc "Create empty database.yml in shared path" 
  task :create_dbyaml do
    run "mkdir -p #{shared_path}/config" 
    put '', "#{shared_path}/config/database.yml" 
  end

  desc "Make symlink for rakismet.rb" 
  task :symlink_akismet do
    run "ln -nfs #{shared_path}/config/initializers/rakismet.rb #{release_path}/config/initializers/rakismet.rb" 
  end

  desc "Create empty rakismet.rb in shared path" 
  task :create_akismet do
    run "mkdir -p #{shared_path}/config/initializers" 
    put '', "#{shared_path}/config/initializers/rakismet.rb" 
  end
end

after 'deploy:setup', 'deploy:create_dbyaml'
after 'deploy:setup', 'deploy:create_akismet'
after 'deploy:update_code', 'deploy:symlink_dbyaml'
after 'deploy:update_code', 'deploy:symlink_akismet'
