require_relative '../test_helper'
require 'debugger/runner/rdebug_option_parser'
require 'minitest/autorun'

describe RdebugOptionParser do
  it "receives options to parse" do
    mock_obj = Minitest::Mock.new
    mock_obj.expect(:process_options, nil, [anything])
    #mock_obj.verify
    assert_send([RdebugOptionParser, :process_options, *parameters])
    #RdebugOptionParser.should_receive(:process_options).with(anything)
    RdebugOptionParser.begin
  end
end
