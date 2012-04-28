#!/usr/bin/env ruby

# AlacIt
#   by: Russell Brooks (russbrooks.com)
#
# Converts APE, FLAC, and WAV files to ALAC (Apple Lossless Audio Codec) files in
# an M4A container for importation into iTunes. Fast.  No loss in quality.
# Basic metadata ports as well.  Puts converted files in same dir as source.
#
# Dependency: FFmpeg 0.8.0+.
#   On OS X : Get Homebrew and type `brew install ffmpeg`.
#   On Linux: `sudo apt-get install flac ffmpeg`
#   Windows : [untested]

require 'open3'
require 'version'
require 'application'

module AlacIt
  class Converter < Application
    @was_error = false

    def convert
      standard_exception_handling do
        parse_args

        ARGV.each do |source|
          if File.directory? source
            convert_dir source
          elsif File.file? source
            convert_file source
          else
            $stderr.puts "Error: #{source}: Not a file or directory."
            @was_error = true
            next
          end
        end
      end
      exit false if @was_error
    end

    def convert_dir(source_dir)
      source_glob = File.join(source_dir, '*.{ape,flac,wav}')

      unless Dir.glob(source_glob).empty?
        Dir.glob(source_glob) do |file|
          m4a_file = file.chomp(File.extname(file)) + '.m4a'

          if !File.exists?(m4a_file) || @options[:force]
            command = 'ffmpeg -y -i "' + file + '" -c:a alac "' + m4a_file + '"'
            stdout_str, stderr_str, status = Open3.capture3(command)

            if status.success?
              puts "#{file} converted."
            else
              $stderr.puts "Error: #{file}: File could not be converted."
              $stderr.puts stderr_str.split("\n").last
              next
            end
          else
            $stderr.puts "Error: #{m4a_file} exists. Use --force option to overwrite."
            next
          end
        end
      else
        $stderr.puts 'Error: No APE, FLAC, or WAV files found.'
        return
      end
    end

    def convert_file(file)
      if File.extname(file) =~ /(\.ape|\.flac|\.wav)/i
        if File.exists? file
          m4a_file = file.chomp(File.extname(file)) + '.m4a'

          if !File.exists?(m4a_file) || @options[:force]
            command = 'ffmpeg -y -i "' + file + '" -acodec alac "' + m4a_file + '"'
            stdout_str, stderr_str, status = Open3.capture3(command)

            if status.success?
              puts "#{file} converted."
            else
              $stderr.puts "Error: #{file}: File could not be converted."
              $stderr.puts stderr_str.split("\n").last
              return
            end
          else
            $stderr.puts "Error: #{m4a_file} exists."
            return
          end
        else
          $stderr.puts "Error: #{file}: No such file."
          return
        end
      else
        $stderr.puts "Error: #{file}: Not an APE, FLAC, or WAV file."
        return
      end
    end
  end
end

if File.basename($PROGRAM_NAME) == 'alacit'
  # If statement prevents this from running when running the test suite.
  AlacIt::Converter.new.convert
end
