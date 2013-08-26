# A handful of behavior tests for rdebug.  This one file takes about twice as
# long to run as the rest of the test suite, so it isn't included in the 'rake
# test' autorunner by default.
#
# Execute with:
#   bundle exec ruby test/rdebug/rdebug_test_slow
require_relative '../test_helper'
require 'minitest/autorun'

describe "rdebug" do

  it "outputs the command line options when run without arguments" do
    output = `bin/rdebug`

    output.must_include "Usage: rdebug [options] <script.rb> -- <script.rb parameters>"
  end

  # rdebug should output gdb style annotations, which are documented here:
  #   http://www.sourceware.org/gdb/onlinedocs/annotate.html#Annotations-Overview
  it "annotates the output when called with the annotate flag" do
     output = call_rdebug "--annotate=3"
     # \032 is the same character as ctrl-Z
     output.must_include "\032"
  end

  it "requires a file when called with the require flag" do
    output = call_rdebug "--require=./test/rdebug/simple_class.rb", "p defined?(SimpleClass)"

    output.must_include "constant"
  end

  it "supports server and client modes" do
    OUTPUT_FILENAME = 'rdebug_test_output'
    #output_file = File.open OUTPUT_FILENAME, 'w'
    #spawn "bin/rdebug --server --wait test/rdebug/simple_loop.rb", :out => [OUTPUT_FILENAME, 'w']
    spawn "bin/rdebug --server --wait test/rdebug/simple_loop.rb > #{OUTPUT_FILENAME}" #, :out => output_file

    # Repeat client connection attempts until successful.  This is hacky, so
    # please fix this if there's a better way to determine when the rdebug
    # server has started.
    #
    client_output = ''
    while !defined?(client_output) || client_output.empty?
      client_output = call_rdebug "--client"
    end

    #server_output = read_pipe.each_line.reduce {|accum, line| accum += line.to_s}
    file = File.open OUTPUT_FILENAME, 'r'
    server_output = file.read

    server_output.must_include "Starting simple loop"
    client_output.must_include "Connected."

    #puts "client output: \n#{client_output}"
    # cleanup
    File.delete OUTPUT_FILENAME
    client_output = ''

  end

  it "should set DEBUG global variable in debugger mode" do
    output = call_rdebug "--debug", "p $DEBUG"
    output.must_include "true"
  end

  private
  # Private: call rdebug on a test script and then pass the given string as
  # standard input
  #
  # arguments - A string of the arguments to be passed to rdebug, including
  #             dashes
  # std_input - A string of the input to be passed to rdebug, using "\n" for
  #             enter/return.  Automatically terminates this string with
  #             "\nc\n" to force rdebug to continue. (Optional)
  #
  # Example
  #
  #   call_rdebug "--annotate=2"
  #
  # Returns a string of all text that would be normally sent to standard output
  def call_rdebug arguments, std_input=""
    # Use single quotes when passing arguments to printf so that bash doesn't
    # evaluate global variables like $DEBUG
    `printf '#{std_input}\nc\n' - | bin/rdebug #{arguments} test/rdebug/simple_loop.rb`
  end
end
