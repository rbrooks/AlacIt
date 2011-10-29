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
  class Converter
    def initialize(source)
      abort "Usage: #{$0} <source_dir_or_file>" unless ARGV.length == 1
      if !command?('ffmpeg')
        error = 'Error: FFmpeg executable not found.'
        error += ' Install Homebrew and type `brew install ffmpeg`.' if os_is_mac?
        abort error
      end
      if File.directory? source
        convert_dir source
      elsif File.file? source
        convert_file source
      else
        abort 'Error: Path provided is not a file or directory.'
      end
    end

    def convert_dir(source_dir)
      source_glob = File.join(source_dir, '*.{flac,wav}')

      unless Dir.glob(source_glob).empty?
        Dir.glob(source_glob) do |file|
          puts "\nConverting: #{file}\n"
          m4a_filename = file.chomp(File.extname(file)) + '.m4a'
          m4a_filepath = File.join(source_dir, m4a_filename)

          `ffmpeg  -i "#{file}" -acodec alac "#{m4a_filepath}"`

          puts "\nFile \"#{file}\" converted successfully.\n" if $?.success?
        end
      else
        abort 'Error: No FLAC or WAV files found.'
      end
    end

    def convert_file(file)
      if File.extname(file) =~ /(\.flac|\.wav)/i
        if File.exists? file
          puts "\nConverting: #{file}\n"
          m4a_filename = file.chomp(File.extname(file)) + '.m4a'
          m4a_filepath =  File.join(File.dirname(file), m4a_filename)

          `ffmpeg  -i "#{file}" -acodec alac "#{m4a_filepath}"`

          puts "\nFile \"#{file}\" converted successfully.\n" if $?.success?
        else
          abort 'Error: File not found.'
        end
      else
        abort 'Error: Not a FLAC or WAV file.'
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

c = AlacIt::Converter.new ARGV[0]
