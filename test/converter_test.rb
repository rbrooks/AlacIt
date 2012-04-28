require 'pathname'
require 'tmpdir'
require 'alacit'
require 'minitest/autorun'

class AlacItTest < MiniTest::Unit::TestCase
  def setup
    # Before each test.
    @temp_dir = Pathname.new Dir.mktmpdir('alacit')
    @app = AlacIt::Converter.new
  end

  def teardown
    # After each test.
    @temp_dir.rmtree
    @app = nil
  end

  def test_no_args
    ARGV.clear
    _, err = capture_io do
      assert_raises(SystemExit) { @app.convert }
    end
    assert_match /You must supply one or more file or directory names/, err
  end

  def test_nonexistant_directory
    ARGV.clear
    ARGV << '/bogus/dir'
    _, err = capture_io do
      assert_raises(SystemExit) { @app.convert }
    end
    assert_match /Not a file or directory/, err
  ensure
    ARGV.clear
  end

  def test_single_ape
    FileUtils.cp 'test/fixtures/test.ape', @temp_dir
    ARGV.clear
    ARGV << File.join(@temp_dir, 'test.ape')
    out, = capture_io { @app.convert }
    assert_match /test\.ape converted/, out
    assert_equal File.exists?(File.join(@temp_dir, 'test.m4a')), true
  end

  def test_single_flac
    FileUtils.cp 'test/fixtures/test.flac', @temp_dir
    ARGV.clear
    ARGV << File.join(@temp_dir, 'test.flac')
    out, = capture_io { @app.convert }
    assert_match /test\.flac converted/, out
    assert_equal File.exists?(File.join(@temp_dir, 'test.m4a')), true
  end

  def test_single_wav
    FileUtils.cp 'test/fixtures/test2.wav', @temp_dir
    ARGV.clear
    ARGV << File.join(@temp_dir, 'test2.wav')
    out, = capture_io { @app.convert }
    assert_match /test2\.wav converted/, out
    assert_equal File.exists?(File.join(@temp_dir, 'test2.m4a')), true
  end

  def test_mixed_directory
    FileUtils.cp 'test/fixtures/test.flac', @temp_dir
    FileUtils.cp 'test/fixtures/test2.wav', @temp_dir
    ARGV.clear
    ARGV << @temp_dir
    out, = capture_io { @app.convert }
    assert_match /test\.flac converted/, out
    assert_match /test2\.wav converted/, out
    assert_equal File.exists?(File.join(@temp_dir, 'test.m4a')), true
    assert_equal File.exists?(File.join(@temp_dir, 'test2.m4a')), true
  end

  def test_single_flac_file_exists
    FileUtils.cp 'test/fixtures/test.flac', @temp_dir
    FileUtils.cp 'test/fixtures/test.m4a', @temp_dir
    ARGV.clear
    ARGV << File.join(@temp_dir, 'test.flac')
    out, err = capture_io { @app.convert }
    assert_match /test\.m4a exists/, err
  end

  def test_single_flac_file_exists_force_overwrite
    FileUtils.cp 'test/fixtures/test.flac', @temp_dir
    FileUtils.cp 'test/fixtures/test.m4a', @temp_dir
    ARGV.clear
    ARGV << '--force' << File.join(@temp_dir, 'test.flac')
    out, = capture_io { @app.convert }
    assert_match /test\.flac converted/, out
    assert_equal File.exists?(File.join(@temp_dir, 'test.m4a')), true
  end

  def test_mixed_directory_file_exists
    FileUtils.cp 'test/fixtures/test.flac', @temp_dir
    FileUtils.cp 'test/fixtures/test2.wav', @temp_dir
    FileUtils.cp 'test/fixtures/test.m4a', @temp_dir
    ARGV.clear
    ARGV << File.join(@temp_dir)
    out, err = capture_io { @app.convert }
    assert_match /test\.m4a exists/, err
    assert_match /test2\.wav converted/, out
    assert_equal File.exists?(File.join(@temp_dir, 'test2.m4a')), true
  end

  def test_mixed_directory_file_exists_force_overwrite
    FileUtils.cp 'test/fixtures/test.flac', @temp_dir
    FileUtils.cp 'test/fixtures/test2.wav', @temp_dir
    FileUtils.cp 'test/fixtures/test.m4a', @temp_dir
    ARGV.clear
    ARGV << '--force' << File.join(@temp_dir)
    out, = capture_io { @app.convert }
    assert_match /test\.flac converted/, out
    assert_match /test2\.wav converted/, out
    assert_equal File.exists?(File.join(@temp_dir, 'test.m4a')), true
    assert_equal File.exists?(File.join(@temp_dir, 'test2.m4a')), true
  end

  def test_standard_exception_handling_invalid_option
    app = AlacIt::Application.new
    out, err = capture_io do
      e = assert_raises SystemExit do
        app.standard_exception_handling do
          raise OptionParser::InvalidOption, 'foo'
        end
      end
      assert_equal 1, e.status
    end
    assert_empty out
    assert_equal "invalid option: foo\n", err
  end
end
