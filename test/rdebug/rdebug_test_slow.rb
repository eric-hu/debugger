# A handful of behavior tests for rdebug.  This one file takes about twice as
# long to run as the rest of the test suite, so it isn't included in the 'rake
# test' autorunner by default.
#
# Execute with:
#   bundle exec ruby test/rdebug/rdebug_test_slow
require_relative '../test_helper'
require 'minitest/autorun'

describe "rdebug" do
  # rdebug should output gdb style annotations, which are documented here:
  #   http://www.sourceware.org/gdb/onlinedocs/annotate.html#Annotations-Overview
  it "annotates the output when called with the annotate flag" do
     output = call_rdebug "--annotate=3"
     # \032 is the same character as ctrl-Z
     output.must_include "\032"
  end

  it "requires a file when called with the require flag" do
    output = call_rdebug "--require=#{current_dir}/simple_class.rb", "p defined?(SimpleClass)"

    output.must_include "constant"
  end

  it "supports server and client modes" do
    OUTPUT_FILENAME = 'rdebug_test_output'
    thread = Thread.new {`#{rdebug_file_path} --server --wait #{current_dir}/simple_loop.rb > #{OUTPUT_FILENAME}`}

    # Wait for the server thread to finish initializing
    sleep(0.05) while thread.status == 'run'

    client_output = call_rdebug "--client"

    file = File.open OUTPUT_FILENAME, 'r'
    server_output = file.read

    server_output.must_include "Starting simple loop"
    client_output.must_include "Connected."

    # cleanup
    File.delete OUTPUT_FILENAME
    client_output = ''
    thread.kill
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
    `printf '#{std_input}\nc\n' - | #{rdebug_file_path} #{arguments} #{current_dir}/simple_loop.rb`
  end

  def rdebug_file_path
    File.expand_path('../../bin/rdebug', File.dirname(__FILE__))
  end

  def current_dir
    File.expand_path(File.dirname(__FILE__))
  end
end
