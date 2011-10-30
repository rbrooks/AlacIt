#!/usr/bin/env ruby

# AlacIt
#   by: Russell Brooks (russbrooks.com)
#
# Converts FLAC and WAV files to ALAC (Apple Lossless Audio Codec) files in
# an M4A container for importation into iTunes. Fast. No loss in quality.
# Basic metadata ports as well. Puts converted files in same dir as source.
#
# Dependency: FFmpeg 0.8.0+. Older versions will likely work too.
#   On OS X : Get Homebrew and type `brew install ffmpeg`.
#   On Linux: `sudo apt-get install flac ffmpeg`
#   Windows : [untested]

module AlacIt
  require 'open3'
  require 'optparse'

  class Converter
    def initialize
      @options = {}
      executable_name = File.split($0)[1]

      if ARGV.length == 0
        banner = "Usage: #{executable_name} dir [dir ...] [file ...]\n"
        banner += "       #{executable_name} file [file ...] [dir ...]"
        STDERR.puts banner
        exit -1
      end

      unless command? 'ffmpeg'
        error = 'Error: FFmpeg executable not found.'
        error += ' Install Homebrew and type `brew install ffmpeg`.' if os_is_mac?
        STDERR.puts error
        exit 2
      end

      OptionParser.new do |opts|
        opts.on('-f', '--force', 'Overwrite output files') do |v|
          @options[:force] = true
        end
      end.parse!

      ARGV.each do |source|
        if File.directory? source
          convert_dir source
        elsif File.file? source
          convert_file source
        else
          abort "Error: #{source}: Not a file or directory."
        end
      end
      exit $?.exitstatus
    end

    def convert_dir(source_dir)
      source_glob = File.join(source_dir, '*.{flac,wav}')

      unless Dir.glob(source_glob).empty?
        Dir.glob(source_glob) do |file|
          m4a_file = file.chomp(File.extname(file)) + '.m4a'

          if !File.exists?(m4a_file) || @options[:force]
            command = 'ffmpeg -y -i "' + file + '" -acodec alac "' + m4a_file + '"'
            stdout_str, stderr_str, status = Open3.capture3(command)

            if status.success?
              puts "#{file}: Converted."
            else
              STDERR.puts "Error: #{file}: File could not be converted."
              STDERR.puts stderr_str.split("\n").last
              next
            end
          else
            STDERR.puts "Error: #{m4a_file} exists."
            next
          end
        end
      else
        STDERR.puts 'Error: No FLAC or WAV files found.'
        return
      end
    end

    def convert_file(file)
      if File.extname(file) =~ /(\.flac|\.wav)/i
        if File.exists? file
          m4a_file = file.chomp(File.extname(file)) + '.m4a'

          if !File.exists?(m4a_file) || @options[:force]
            command = 'ffmpeg -y -i "' + file + '" -acodec alac "' + m4a_file + '"'
            stdout_str, stderr_str, status = Open3.capture3(command)

            if status.success?
              puts "#{file}: Converted."
            else
              STDERR.puts "Error: #{file}: File could not be converted."
              STDERR.puts stderr_str.split("\n").last
              return
            end
          else
            STDERR.puts "Error: #{m4a_file} exists."
            return
          end
        else
          STDERR.puts "Error: #{file}: No such file."
          return
        end
      else
        STDERR.puts "Error: #{file}: Not a FLAC or WAV file."
        return
      end
    end

    private

      def command?(name)
        `which #{name}`
        $?.success?
      end

      def os_is_mac?
        RUBY_PLATFORM.downcase.include? 'darwin'
      end
  end
end

c = AlacIt::Converter.new
