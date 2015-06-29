Feature: trema killall command
  Background:
    Given I set the environment variables to:
      | variable         | value |
      | TREMA_LOG_DIR    | .     |
      | TREMA_PID_DIR    | .     |
      | TREMA_SOCKET_DIR | .     |
    And a file named "null_controller.rb" with:
      """
      class NullController < Trema::Controller; end
      """
    And a file named "trema.conf" with:
      """
      vswitch { datapath_id 0xabc }
      vhost('host1') { ip '192.168.0.1' }
      vhost('host2') { ip '192.168.0.2' }
      link '0xabc', 'host1'
      link '0xabc', 'host2'
      """
    And I run `trema run null_controller.rb -c trema.conf -d`
    And a file named "void_controller.rb" with:
      """
      class VoidController < Trema::Controller; end
      """
    And I run `trema run void_controller.rb -p 6654 -d`

  @sudo
  Scenario: killall controller_name
    When I successfully run `trema killall NullController`
    Then virtual links should not exist 
    And I successfully run `ls`
    And the following files should not exist:
      | NullController.pid |
      | vhost.host1.pid    |
      | vhost.host2.pid    |
    And the following files should exist:
      | VoidController.pid |
  
  @sudo
  Scenario: killall --all
    When I successfully run `trema killall --all`
    Then virtual links should not exist 
    And the following files should not exist:
      | NullController.pid |
      | VoidController.pid |
      | vhost.host1.pid    |
      | vhost.host2.pid    |

  @sudo
  Scenario: killall NO_SUCH_NAME
    When I run `trema killall NO_SUCH_NAME`
    Then the exit status should not be 0
    And the output should contain:
    """
    Controller process "NO_SUCH_NAME" does not exist.
    """
