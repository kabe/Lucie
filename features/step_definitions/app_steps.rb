When /^I try to install the node "([^\"]*)"$/ do | node |
  @messenger = StringIO.new( "" )
  options = [ node, "--suite=potato", "--dry-run", "--netmask=255.255.255.0", "--storage-conf=mystorage.conf", "--mac=11:22:33:44:55:66", "--ldb-repository=http://ldb.repository.org/" ]
  Command::NodeInstall::App.new( options, @messenger ).main( [ node ] )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

