require 'optparse'

module AlacIt
  class Application
    attr_reader :name # Name of this app.

    def initialize
      @options = {}
      standard_exception_handling do
        @name = File.split($0)[1]
        ffmpeg_exists
      end
    end

    def standard_exception_handling
      begin
        yield
      rescue SystemExit => ex
        # Exit silently with current status
        raise
      rescue OptionParser::InvalidOption => ex
        $stderr.puts ex.message
        exit(false)
      rescue Exception => ex
        # Exit with error message
        display_error_message(ex)
        exit(false)
      end
    end

    # Display the error message that caused the exception.
    def display_error_message(ex)
      $stderr.puts "#{name} aborted!"
      $stderr.puts ex.message
      $stderr.puts ex.backtrace.join("\n")
    end

    def parse_args
      OptionParser.new do |opts|
        opts.banner = "Converts ALAC and WAV files to Apple Lossless.\n\n"
        @usage = "Usage: #{@name} [options] dir [dir ...] [file ...]\n"
        @usage += "       #{@name} [options] file [file ...] [dir ...]\n"
        opts.banner += "#{@usage}\n"

        opts.on('-f', '--force', 'Overwrite output files') do |f|
          @options[:force] = true
        end

        opts.on('-v', '--version', 'AlacIt version') do
          puts 'AlacIt ' + AlacIt::VERSION
          exit
        end
      end.parse!

      args_exist
    end

    def args_exist
      if ARGV.empty?
        $stderr.puts 'Error: You must supply one or more file or directory names.'
        $stderr.puts
        $stderr.puts @usage
        exit -1
      end
    end

    def ffmpeg_exists
      unless command? 'ffmpeg'
        error = 'Error: FFmpeg executable not found.'
        error += ' Install Homebrew and type `brew install ffmpeg`.' if os_is_mac?
        error += ' To install, type `sudo apt-get install flac ffmpeg`.' if os_is_linux?
        $stderr.puts error
        exit 2
      end
    end

    def command?(name)
      `which #{name}`
      $?.success?
    end

    def os_is_mac?
      RUBY_PLATFORM.downcase.include? 'darwin'
    end

    def os_is_linux?
      RUBY_PLATFORM.downcase.include? 'linux'
    end
  end
end