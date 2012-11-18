module TestDsl

  # Adds commands to the input queue, so they will be retrieved by Processor later.
  # I.e. it emulates user's input.
  #
  # If a command is a Proc object, it will be executed before retrieving by Processor.
  # May be handy when you need build a command depending on the current context/state.
  #
  # Usage:
  #
  #   enter 'b 12'
  #   enter 'b 12', 'cont'
  #   enter ['b 12', 'cont']
  #   enter 'b 12', ->{"disable #{Debugger.breakpoints.first.id}"}, 'cont'
  #
  def enter(*messages)
    messages = messages.first.is_a?(Array) ? messages.first : messages
    interface.input_queue.concat(messages)
  end

  # Runs a debugger with the provided basename for a file. The file should be placed
  # to the test/new/examples dir.
  #
  # You also can specify block, which will be executed when Processor extracts all the
  # commands from the input queue. You can use it e.g. for making asserts for the current
  # test. If you specified the block, and it never was executed, the test will fail.
  #
  # Usage:
  #
  #   debug "ex1" # ex1 should be placed in test/new/examples/ex1.rb
  #
  #   enter 'b 4', 'cont'
  #   debug("ex1") { state.line.must_equal 4 } # It will be executed after running 'cont' and stopping at the breakpoint
  #
  def debug_file(filename, &block)
    is_test_block_called = false
    exception = nil
    if block
      interface.test_block = lambda do
        is_test_block_called = true
        # We need to store exception and reraise it after completing debugging, because
        # Debugger will swallow any exceptions, so e.g. our failed assertions will be ignored
        begin
          block.call
        rescue Exception => e
          exception = e
          raise e
        end
      end
    end
    Debugger.start { load fullpath(filename) }
    flunk "test block is provided, but not called" if block && !is_test_block_called
    raise exception if exception
  end

  # Checks the output of the debugger. By default it checks output queue of the current interface,
  # but you can check again any queue by providing it as a second argument.
  #
  # Usage:
  #
  #   enter 'break 4', 'cont'
  #   debug("ex1")
  #   check_output "Breakpoint 1 at #{fullpath('ex1')}:4"
  #
  def check_output(message, queue = interface.output_queue)
    queue.map(&:strip).must_include(message.strip)
  end

  def fullpath(filename)
    (Pathname.new(__FILE__) + "../../examples/#{filename}.rb").cleanpath.to_s
  end

  def interface
    Debugger.handler.interface
  end

  def state
    $rdebug_state
  end

  def context
    state.context
  end
end