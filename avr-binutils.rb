require 'formula'

# Atmel distributes a complete tarball of patches.
class AtmelPatches < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-Toolchain-3.4.1/avr/avr-patches.tar.gz'
  homepage 'http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx'
  sha1 '59a139a42c8dada06fa5e3ebbd3d37f8d16b0d11'
end

class AvrBinutils < Formula
  url 'http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.bz2'
  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  md5 'ee0f10756c84979622b992a4a61ea3f5'

  option 'disable-libbfd', 'Disable installation of libbfd.'

  def patches
    mkdir buildpath/'patches'
    AtmelPatches.new.brew { cp Dir['binutils/*'], buildpath/'patches' }
    { :p0 => Dir[buildpath/'patches/*'] }
  end

  def install

    if MacOS.lion?
      ENV['CC'] = 'clang'
    end

    ENV['CPPFLAGS'] = "-I#{include}"

    args = ["--prefix=#{prefix}",
            "--infodir=#{info}",
            "--mandir=#{man}",
            "--disable-werror",
            "--disable-nls"]

    unless ARGV.include? '--disable-libbfd'
      Dir.chdir "bfd" do
        ohai "building libbfd"
        system "./configure", "--enable-install-libbfd", *args
        system "make"
        system "make install"
      end
    end

    # brew's build environment is in our way
    ENV.delete 'CFLAGS'
    ENV.delete 'CXXFLAGS'
    ENV.delete 'LD'
    ENV.delete 'CC'
    ENV.delete 'CXX'

    if MacOS.lion?
      ENV['CC'] = 'clang'
    end

    system "./configure", "--target=avr", *args

    system "make"
    system "make install"
  end
end
