Story "Enable a node with 'node' command",
%(As a cluster administrator
  I want to enable a node using 'node' command
  So that I can enable a node) do


  Scenario 'node enable success' do
    # [TODO] インストーラが追加されていない場合、node enable に失敗する
    # シナリオ
    Given 'TEST_INSTALLER installer is added' do
      unless FileTest.directory?( './installers/TEST_INSTALLER' )
        FileUtils.mkdir './installers/TEST_INSTALLER'
      end
    end

    Given 'TEST_NODE is already added and is disabled' do
      add_fresh_node 'TEST_NODE'
      File.open( './nodes/TEST_NODE/00_00_00_00_00_00', 'w' ) do | file |
        file.puts <<-EOF
gateway_address:192.168.2.254
ip_address:192.168.2.1
netmask_address:255.255.255.0
        EOF
      end
    end

    When 'I run', './node enable TEST_NODE --installer TEST_INSTALLER --no-builder' do | command |
      @error_message = output_with( command )
    end

    Then 'It should succeeed with no error message' do
      @error_message.should be_empty
    end
  end
end


Story 'Trace node enable command',
%(As a cluster administrator
  I can trace a failed 'node enable' command
  So that I can report a detailed backtrace to Lucie developers) do

  Scenario 'run node enable with --trace option' do
    Given 'TEST_NODE is already added' do
      add_fresh_node 'TEST_NODE'
    end

    Given 'TEST_INSTALLER is not added yet' do
      cleanup_installers
    end

    When 'I run a command that fails with --trace option' do
      @error_message = output_with( './node enable TEST_NODE --installer TEST_INSTALLER --trace' )
    end

    Then 'I get backtrace' do
      @error_message.should match( /^\s+from/ )
    end
  end
end
