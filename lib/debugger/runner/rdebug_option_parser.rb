require 'optparse'
require 'ostruct'

class RdebugOptionParser
  class<<self
    options = OpenStruct.new(
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

    def begin
      process_options(options)
    end

    def process_options(options)
      program = File.basename($0)
      opts = OptionParser.new do |opts|
        opts.banner = <<EOB
#{program} #{Debugger::VERSION}
Usage: #{program} [options] <script.rb> -- <script.rb parameters>
EOB
        opts.separator ""
        opts.separator "Options:"
        opts.on("-A", "--annotate LEVEL", Integer, "Set annotation level") do
          |annotate|
            Debugger.annotate = annotate
        end
        opts.on("-c", "--client", "Connect to remote debugger") do
          options.client = true
        end
        opts.on("--cport PORT", Integer, "Port used for control commands.  Default 8990") do
          |cport|
          options.cport = cport
        end
        opts.on("-d", "--debug", "Set $DEBUG=true") {$DEBUG = true}
        opts.on("--emacs LEVEL", Integer,
                "Activates full Emacs support at annotation level LEVEL") do
          |level|
          Debugger.annotate = level.to_i
          ENV['EMACS'] = '1'
          ENV['COLUMNS'] = '120' if ENV['COLUMNS'].to_i < 120
          options.control = false
          options.quit = false
        end
        opts.on('--emacs-basic', 'Activates basic Emacs mode') do
          ENV['EMACS'] = '1'
        end
        opts.on('-h', '--host HOST', 'Host name used for remote debugging') do
          |host|
          options.host = host
        end
        opts.on('-I', '--include PATH', String, 'Add PATH to $LOAD_PATH') do |path|
          $LOAD_PATH.unshift(path)
        end
        opts.on('--no-control', 'Do not automatically start control thread') do
          options.control = false
        end
        opts.on('--no-quit', 'Do not quit when script finishes') do
          options.quit = false
        end
        opts.on('--no-rewrite-program',
                'Do not set $0 to the program being debugged') do
          options.no_rewrite_program = true
        end
        opts.on('--no-stop', 'Do not stop when script is loaded') do
          options.stop = false
        end
        opts.on('-nx', 'Not run debugger initialization files (e.g. .rdebugrc') do
          options.nx = true
        end
        opts.on('-p', '--port PORT', Integer, 'Port used for remote debugging.  Default 8989') do
          |port|
          options.port = port
        end
        opts.on('-r', '--require SCRIPT', String,
                'Require the library, before executing your script') do |name|
          if name == 'debug'
            puts "debugger is not compatible with Ruby's 'debug' library. This option is ignored."
          else
            require name
          end
        end
        opts.on('--restart-script FILE', String,
                'Name of the script file to run. Erased after read') do
          |restart_script|
          options.restart_script = restart_script
          unless File.exists?(options.restart_script)
            puts "Script file '#{options.restart_script}' is not found"
            exit
          end
        end
        opts.on('--script FILE', String, 'Name of the script file to run') do
          |script|
          options.script = script
          unless File.exists?(options.script)
            puts "Script file '#{options.script}' is not found"
            exit
          end
        end
        opts.on('-s', '--server', 'Listen for remote connections') do
          options.server = true
        end
        opts.on('-w', '--wait', 'Wait for a client connection, implies -s option') do
          options.wait = true
        end
        opts.on('-x', '--trace', 'Turn on line tracing') {options.tracing = true}
        opts.separator ''
        opts.separator 'Common options:'
        opts.on_tail('--help', 'Show this message') do
          puts opts
          exit
        end
        opts.on_tail('--version',
                     'Print the version') do
          puts "debugger #{Debugger::VERSION}"
          exit
        end
        opts.on('--verbose', 'Turn on verbose mode') do
          $VERBOSE = true
          options.verbose_long = true
        end
        opts.on_tail('-v',
                     'Print version number, then turn on verbose mode') do
          puts "debugger #{Debugger::VERSION}"
          $VERBOSE = true
        end
      end
      return opts
    end
  end
end
