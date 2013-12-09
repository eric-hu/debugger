require 'optparse'
require 'ostruct'
require 'singleton'

# Singleton parser class for Rdebug options
#
# Usage:
#
#   RdebugOptionParser.instance.parse arguments
#
# Returns an OpenStruct with attributes built from (in order of priority)
#   1.  arguments passed to parse()
#   2.  default_options
class RdebugOptionParser
  include Singleton

  # arguments - an array of strings, the same format as ARGV
  def parse arguments
    begin
      @option_parser.parse! arguments
    rescue StandardError => e
      puts @option_parser
      puts
      puts e.message
      exit(-1)
    end

    @options
  end

  def initialize
    @options = default_options

    program = File.basename($0)
    @option_parser = OptionParser.new do |parser|
      parser.banner = <<EOB
#{program} #{Debugger::VERSION}
Usage: #{program} [options] <script.rb> -- <script.rb parameters>
EOB
      parser.separator ""
      parser.separator "Options:"
      parser.on("-A", "--annotate LEVEL", Integer,
                "Set annotation level") do |annotate|
        Debugger.annotate = annotate
      end
      parser.on("-c", "--client", "Connect to remote debugger") do
        @options.client = true
      end
      parser.on("--cport PORT", Integer, "Port used for control commands.  Default 8990") do
        |cport|
        @options.cport = cport
      end
      parser.on("-d", "--debug", "Set $DEBUG=true") {$DEBUG = true}
      parser.on("--emacs LEVEL", Integer,
              "Activates full Emacs support at annotation level LEVEL") do
        |level|
        Debugger.annotate = level.to_i
        ENV['EMACS'] = '1'
        ENV['COLUMNS'] = '120' if ENV['COLUMNS'].to_i < 120
        @options.control = false
        @options.quit = false
      end
      parser.on('--emacs-basic', 'Activates basic Emacs mode') do
        ENV['EMACS'] = '1'
      end
      parser.on('-h', '--host HOST', 'Host name used for remote debugging') do
        |host|
        @options.host = host
      end
      parser.on('-I', '--include PATH', String, 'Add PATH to $LOAD_PATH') do |path|
        $LOAD_PATH.unshift(path)
      end
      parser.on('--no-control', 'Do not automatically start control thread') do
        @options.control = false
      end
      parser.on('--no-quit', 'Do not quit when script finishes') do
        @options.quit = false
      end
      parser.on('--no-rewrite-program',
              'Do not set $0 to the program being debugged') do
        @options.no_rewrite_program = true
      end
      parser.on('--no-stop', 'Do not stop when script is loaded') do
        @options.stop = false
      end
      parser.on('-nx', 'Not run debugger initialization files (e.g. .rdebugrc') do
        @options.nx = true
      end
      parser.on('-p', '--port PORT', Integer, 'Port used for remote debugging.  Default 8989') do
        |port|
        @options.port = port
      end
      parser.on('-r', '--require SCRIPT', String,
              'Require the library, before executing your script') do |name|
        if name == 'debug'
          puts "debugger is not compatible with Ruby's 'debug' library. This option is ignored."
        else
          require name
        end
      end
      parser.on('--restart-script FILE', String,
              'Name of the script file to run. Erased after read') do
        |restart_script|
        @options.restart_script = restart_script
        unless File.exists?(@options.restart_script)
          puts "Script file '#{@options.restart_script}' is not found"
          exit
        end
      end
      parser.on('--script FILE', String, 'Name of the script file to run') do
        |script|
        @options.script = script
        unless File.exists?(@options.script)
          puts "Script file '#{@options.script}' is not found"
          exit
        end
      end
      parser.on('-s', '--server', 'Listen for remote connections') do
        @options.server = true
      end
      parser.on('-w', '--wait', 'Wait for a client connection, implies -s option') do
        @options.wait = true
      end
      parser.on('-x', '--trace', 'Turn on line tracing') {@options.tracing = true}
      parser.separator ''
      parser.separator 'Common options:'
      parser.on_tail('--help', 'Show this message') do
        puts parser
        exit
      end
      parser.on_tail('--version',
                   'Print the version') do
        puts "debugger #{Debugger::VERSION}"
        exit
      end
      parser.on('--verbose', 'Turn on verbose mode') do
        $VERBOSE = true
        @options.verbose_long = true
      end
      parser.on_tail('-v',
                   'Print version number, then turn on verbose mode') do
        puts "debugger #{Debugger::VERSION}"
        $VERBOSE = true
      end
    end
  end

  # Delegate to_s to @option_parser, which returns an option summary string
  def to_s
    @option_parser.to_s
  end

  private

  def default_options
    OpenStruct.new(
      'annotate'           => Debugger.annotate,
      'client'             => false,
      'control'            => true,
      'cport'              => Debugger::PORT + 1,
      'host'               => nil,
      'quit'               => true,
      'no_rewrite_program' => false,
      'stop'               => true,
      'nx'                 => false,
      'port'               => Debugger::PORT,
      'restart_script'     => nil,
      'script'             => nil,
      'server'             => false,
      'tracing'            => false,
      'verbose_long'       => false,
      'wait'               => false
    )
  end
end
