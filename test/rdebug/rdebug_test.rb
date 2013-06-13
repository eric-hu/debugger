require_relative '../test_helper'

describe "rdebug" do

  it "outputs the command line options when run without arguments" do
    output = `bin/rdebug`

    output.must_include "Usage: rdebug [options] <script.rb> -- <script.rb parameters>"
  end

  # This test is commented as it currently appears that calling rdebug
  # with the annotate option has the same output as without the annotate
  # option.
  # rdebug should output gdb style annotations, which are documented here:
  #   http://www.sourceware.org/gdb/onlinedocs/annotate.html#Annotations-Overview
  #it "annotates the output when called with -A 2" do
    # output = call_rdebug "--annotate=2"
    #
    # output.must_include ""
  #end

  it "requires a file when called with the require flag" do
    output = call_rdebug "--require=./test/rdebug/simple_class.rb", "p defined?(SimpleClass)"

    output.must_include "constant"
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
    `printf "#{std_input}\nc\n" - | bin/rdebug #{arguments} test/rdebug/simple_loop.rb`
  end
end
