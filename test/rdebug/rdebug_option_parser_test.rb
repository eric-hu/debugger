require_relative '../test_helper'
require_relative '../../lib/debugger/runner/rdebug_option_parser'
require 'minitest/autorun'
require 'mocha/setup'

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
      assert_raises(SystemExit) do
          RdebugOptionParser.instance.parse ['--version']
      end
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
      Debugger.expects(:annotate=).with(3)
      call_rdebug_parse_with_arguments ["--annotate=3"]
    end

    it "parses the short form" do
      Debugger.expects(:annotate=).with(3)
      call_rdebug_parse_with_arguments ["-A", "3"]
    end
  end

  describe "require arguments" do
    it "parses the long form" do
      RdebugOptionParser.instance.expects(:require).with('foo').returns(true)
      call_rdebug_parse_with_arguments ["--require=foo"]
    end

    it "parses the short form" do
      RdebugOptionParser.instance.expects(:require).with('foo').returns(true)
      call_rdebug_parse_with_arguments ["-r", "foo"]
    end
  end

  describe "client mode arguments" do
    it "parses the long form" do
      result = call_rdebug_parse_with_arguments ["--client"]
      result.client.must_equal true
    end

    it "parses the short form" do
      result = call_rdebug_parse_with_arguments ["-c"]
      result.client.must_equal true
    end
  end

  describe "server mode arguments" do
    it "parses the long form" do
      result = call_rdebug_parse_with_arguments ["--server"]
      result.server.must_equal true
    end

    it "parses the short form" do
      result = call_rdebug_parse_with_arguments ["-s"]
      result.server.must_equal true
    end
  end

  describe "wait mode arguments" do
    it "parses the long form" do
      result = call_rdebug_parse_with_arguments ["--wait"]
      result.wait.must_equal true
    end

    it "parses the short form" do
      result = call_rdebug_parse_with_arguments ["-w"]
      result.wait.must_equal true
    end
  end

  describe "debug arguments" do
    before { @old_debug_setting = $DEBUG }
    after { $DEBUG = @old_debug_setting }
    it "parses the long form" do
      $DEBUG = false
      call_rdebug_parse_with_arguments ["--debug"]
      $DEBUG.must_equal true
    end

    it "parses the short form" do
      $DEBUG = false
      call_rdebug_parse_with_arguments ["-d"]
      $DEBUG.must_equal true
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
