require_relative '../test_helper'
require_relative '../../lib/debugger/runner/rdebug_option_parser'
require 'minitest/autorun'

describe RdebugOptionParser do
  it "returns an option summary" do
    RdebugOptionParser.instance.to_s.wont_be_empty
  end

  describe 'verbose options' do
    before do
      # preserve $VERBOSE setting so that this test doesn't make other tests
      # noisy
      @verbose_before = $VERBOSE
    end

    after do
      $VERBOSE = @verbose_before
    end

    it 'supports a verbose option' do
      options = RdebugOptionParser.instance.parse ['--verbose']

      options.verbose_long.must_equal true
      $VERBOSE.must_equal true
    end

    it 'supports a verbose/version option' do
      out, err = capture_io do
        options = RdebugOptionParser.instance.parse ['-v']

        $VERBOSE.must_equal true
      end

      out.must_include Debugger::VERSION
    end
  end

  it 'supports a version option' do
    out, err = capture_io do
      assert_raises(SystemExit) {
          RdebugOptionParser.instance.parse ['--version']
      }
    end

    out.must_include Debugger::VERSION
  end

  it "to_s returns the command line options when run without arguments" do
    output = RdebugOptionParser.instance.to_s

    output.must_include "Usage:"
    output.must_include "[options] <script.rb> -- <script.rb parameters>"
    output.must_include "-A, --annotate LEVEL             Set annotation level"
  end

  describe "annotation arguments" do
    it "parses the long form" do
      new_annotate_level = Debugger.annotate + 1
      call_rdebug_parse_with_arguments ["--annotate=#{new_annotate_level}"]
      Debugger.annotate.must_equal new_annotate_level
    end

    it "parses the short form" do
      new_annotate_level = Debugger.annotate + 1
      call_rdebug_parse_with_arguments ["-A", new_annotate_level.to_s]
      Debugger.annotate.must_equal new_annotate_level
    end
  end

  private
  def call_rdebug_parse_with_arguments arguments
    begin
      RdebugOptionParser.instance.parse arguments
    # RdebugOptionParser catches all StandardErrors and calls exit(-1)
    rescue SystemExit
    end
  end
end
