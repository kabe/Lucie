#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rake/clean'

require( File.join( File.dirname( __FILE__ ), 'config', 'boot' ) )

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'


CLEAN.exclude 'installers/*'


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
