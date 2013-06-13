require_relative 'test_helper'

describe "rdebug" do

  it "outputs the command line options when run without arguments" do
    output = `bin/rdebug`

    output.must_include partial_command_line_output_with_no_args
  end

  def partial_command_line_output_with_no_args
    "Usage: rdebug [options] <script.rb> -- <script.rb parameters>"
  end

end
