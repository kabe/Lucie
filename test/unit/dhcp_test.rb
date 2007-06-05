require File.dirname( __FILE__ ) + '/../test_helper'
require 'facter'


class DhcpTest < Test::Unit::TestCase
  include FileSandbox


  def test_setup___success__
    in_sandbox do | sandbox |
      sandbox.new :file => 'hosts', :with_content => '192.168.1.1 TEST_NODE'
      sandbox.new :file => 'TEST_NODE/00:00:00:00:00:00', :with_content => ''
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER', :with_content => ''

      Configuration.expects( :nodes_directory ).at_least_once.returns( sandbox.root )

      file_mock = mock( 'FILE' )
      file_mock.expects( :puts ).times( 1 )
      File.expects( :open ).with( '/etc/dhcp3/dhcpd.conf.TEST_INSTALLER_example', 'w' ).times( 1 ).yields( file_mock )

      Dhcp.setup 'TEST_INSTALLER', sandbox.root + '/hosts'
    end
  end


  def test_setup___fail___with_lucie_server_domain_resolv_failure
    in_sandbox do | sandbox |
      sandbox.new :file => 'hosts', :with_content => '192.168.1.1 TEST_NODE'
      sandbox.new :file => 'TEST_NODE/00:00:00:00:00:00', :with_content => ''
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER', :with_content => ''

      Configuration.expects( :nodes_directory ).at_least_once.returns( sandbox.root )

      File.expects( :open ).with( '/etc/dhcp3/dhcpd.conf.TEST_INSTALLER_example', 'w' ).times( 1 ).yields( nil )

      Facter.expects( :value ).with( 'domain' ).returns( nil )

      assert_raises( "Cannnot resolve Lucie server's domain name." ) do
        Dhcp.setup 'TEST_INSTALLER', sandbox.root + '/hosts'
      end
    end
  end


  def test_setup___fail___with_lucie_server_ipaddress_resolv_failure
    in_sandbox do | sandbox |
      sandbox.new :file => 'hosts', :with_content => '192.168.1.1 TEST_NODE'
      sandbox.new :file => 'TEST_NODE/00:00:00:00:00:00', :with_content => ''
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER', :with_content => ''

      Configuration.expects( :nodes_directory ).at_least_once.returns( sandbox.root )

      File.expects( :open ).with( '/etc/dhcp3/dhcpd.conf.TEST_INSTALLER_example', 'w' ).times( 1 ).yields( nil )

      Facter.expects( :value ).with( 'domain' ).returns( 'DOMAIN' )
      Facter.expects( :value ).with( 'ipaddress' ).returns( nil )

      assert_raises( "Cannnot resolve Lucie server's IP address." ) do
        Dhcp.setup 'TEST_INSTALLER', sandbox.root + '/hosts'
      end
    end
  end


  def test_setup___fail___with_no_ipaddress_resolv_failure
    in_sandbox do | sandbox |
      sandbox.new :file => 'hosts', :with_content => '192.168.1.1 TEST_NODE'
      sandbox.new :file => 'TEST_NODE/00:00:00:00:00:00', :with_content => ''
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER', :with_content => ''

      Configuration.expects( :nodes_directory ).at_least_once.returns( sandbox.root )

      resolver_mock = mock( 'Resolv::Hosts' )
      resolver_mock.expects( :getaddress ).returns( nil )
      Resolv::Hosts.expects( :new ).returns( resolver_mock )

      assert_raises( "Cannnot resolve host 'TEST_NODE' IP address." ) do
        Dhcp.setup 'TEST_INSTALLER', sandbox.root + '/hosts'
      end
    end
  end
end