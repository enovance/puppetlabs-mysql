require 'socket'
require 'timeout'
require 'ipaddr'

module Puppet
  module Util
    class MysqlValidator
      attr_reader :mysql_server
      attr_reader :mysql_port

      def initialize(mysql_server, mysql_port)
        @mysql_server = IPAddr.new(mysql_server).to_s
        @mysql_port   = mysql_port
      end

      # Utility method; attempts to make a connection to the mysql server.
      # This is abstracted out into a method so that it can be called multiple times
      # for retry attempts.
      #
      # @return true if the connection is successful, false otherwise.
      def attempt_connection
        Timeout::timeout(Puppet[:configtimeout]) do
          begin
            TCPSocket.new(@mysql_server, @mysql_port).close
            true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
            Puppet.debug "Unable to connect to mysql server (#{@mysql_server}:#{@mysql_port}): #{e.message}"
            false
          end
        end
      rescue Timeout::Error
        false
      end
    end
  end
end

