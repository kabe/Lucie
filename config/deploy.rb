set :application, 'lucie'
set :repository, 'http://lucie.is.titech.ac.jp/svn/trunk'

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :web, 'localhost'
# role :app, "your app-server here"
# role :web, "your web-server here"
# role :db,  "your db-server here", :primary => true
