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
end
