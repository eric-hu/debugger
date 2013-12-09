require_relative '../test_helper'
require_relative '../../lib/debugger/runner/rdebug_option_parser'
require 'minitest/autorun'
require 'mocha/setup'

describe RdebugOptionParser do
  before do
    # Hack to re-initialize a Singleton class and clear its state
    Singleton.__init__(RdebugOptionParser)
  end

  it "returns an option summary" do
    RdebugOptionParser.instance.to_s.wont_be_empty
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

  it "parses a control port argument and sets a value in the returned OpenStruct" do
    result = call_rdebug_parse_with_arguments ["--cport=3000"]
    result.cport.must_equal 3000
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

  describe "emacs arguments" do
    it "parses an emacs option with custom annotation level" do
      Debugger.expects(:annotate=).with(5)
      ENV.expects(:[]=).with('EMACS', '1')

      # Mock column width less than 120
      ENV.expects(:[]).with('COLUMNS').returns(110)
      ENV.expects(:[]=).with('COLUMNS', '120')

      result = call_rdebug_parse_with_arguments ['--emacs=5']
      result.control.must_equal false
      result.quit.must_equal false
    end

    it "parses an emacs basic argument" do
      ENV.expects(:[]=).with('EMACS', '1')

      call_rdebug_parse_with_arguments ['--emacs-basic']
    end
  end

  describe "host arguments" do
    it "parses the short form" do
      result = call_rdebug_parse_with_arguments ['-h', '5000']
      result.host.must_equal '5000'
    end

    it "parses the long form" do
      result = call_rdebug_parse_with_arguments ['--host=5000']
      result.host.must_equal '5000'
    end
  end

  describe "include arguments" do
    before { $LOAD_PATH.expects(:unshift).with('./') }
    it "parses the long form" do
      call_rdebug_parse_with_arguments ['--include=./']
    end

    it "parses the short form" do
      call_rdebug_parse_with_arguments ['-I', './']
    end
  end

  it "parses a no-control-thread argument and sets a boolean in the returned OpenStruct" do
    result = call_rdebug_parse_with_arguments ['--no-control']
    result.control.must_equal false
  end

  it "parses a no-quit argument and sets a boolean in the returned OpenStruct" do
    result = call_rdebug_parse_with_arguments ['--no-quit']
    result.quit.must_equal false
  end

  it "parses a no-rewrite-program argument and sets a boolean in returned OpenStruct" do
    result = call_rdebug_parse_with_arguments ['--no-rewrite-program']
    result.no_rewrite_program.must_equal true
  end

  it "parses a no-stop argument and sets a boolean in returned OpenStruct" do
    result = call_rdebug_parse_with_arguments ['--no-stop']
    result.stop.must_equal false
  end

  it "parses a skip init files argument and sets a boolean in returned OpenStruct" do
    result = call_rdebug_parse_with_arguments ['-nx']
    result.nx.must_equal true
  end

  it "parses a port argument and sets a user-provided value in the returned OpenStruct" do
    result = call_rdebug_parse_with_arguments ['-p', '5000']
    result.port.must_equal 5000
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

  describe "restart-script" do
    it "sets the filename in the returned OpenStruct" do
      result = call_rdebug_parse_with_arguments ['--restart-script=./']
      result.restart_script.must_equal './'
    end

    it "checks for the existence of a file and prints an error message if it doesn't exist" do
      out, err = capture_io do
        assert_raises(SystemExit) do
          RdebugOptionParser.instance.parse ['--restart-script=./non_existent_file']
        end
      end

      out.must_match /is not found/
    end
  end

  describe "script" do
    it "sets the filename in the returned OpenStruct" do
      result = call_rdebug_parse_with_arguments ['--script=./']
      result.script.must_equal './'
    end

    it "checks for the existence of a file and prints an error message if it doesn't exist" do
      out, err = capture_io do
        assert_raises(SystemExit) do
          RdebugOptionParser.instance.parse ['--script=./non_existent_file']
        end
      end

      out.must_match /is not found/
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

  describe "trace arguments" do
    after { @result.tracing.must_equal true }

    it "parses the long version and sets a boolean on the returned OpenStruct" do
      @result = call_rdebug_parse_with_arguments ["-x"]
    end

    it "parses the short version and sets a boolean on the returned OpenStruct" do
      @result = call_rdebug_parse_with_arguments ["--trace"]
    end
  end

  describe "help argument" do

    it "prints the command line options" do
      out,err = capture_io do
        call_rdebug_parse_with_arguments ['--help']
      end

      out.must_include "Usage:"
    end
  end

  it 'parses a version argument' do
    out, err = capture_io do
      assert_raises(SystemExit) do
        RdebugOptionParser.instance.parse ['--version']
      end
    end

    out.must_include Debugger::VERSION
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

    it 'parses a verbose argument' do
      options = RdebugOptionParser.instance.parse ['--verbose']

      options.verbose_long.must_equal true
      $VERBOSE.must_equal true
    end

    it 'parses a verbose/version argument and prints a message' do
      out, err = capture_io do
        options = RdebugOptionParser.instance.parse ['-v']

        $VERBOSE.must_equal true
      end

      out.must_include Debugger::VERSION
    end
  end

  it "to_s returns the command line options when run without arguments" do
    output = RdebugOptionParser.instance.to_s

    output.must_include "Usage:"
    output.must_include "[options] <script.rb> -- <script.rb parameters>"
    output.must_include "-A, --annotate LEVEL             Set annotation level"
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
