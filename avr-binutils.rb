require 'formula'

# Atmel distributes a complete tarball of patches.
class AtmelPatches < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-Toolchain-3.4.1.830/avr/avr-patches.tar.gz'
  homepage 'http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx'
  sha1 '08208bdc9ddb6b4b328c1b4c94a2b81f1d750289'
end

class AvrBinutils < Formula
  url 'http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.bz2'
  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  md5 'ee0f10756c84979622b992a4a61ea3f5'

  depends_on 'autoconf264'
  depends_on :automake

  def patches
    mkdir buildpath/'patches'
    AtmelPatches.new.brew { cp Dir['binutils/*'], buildpath/'patches' }
    { :p0 => Dir[buildpath/'patches/*'] }
  end

  def install

    ENV['CPPFLAGS'] = "-I#{include}"

    args = ["--prefix=#{prefix}",
            "--infodir=#{info}",
            "--mandir=#{man}",
            "--disable-werror",
            "--disable-nls",
            "--enable-install-libiberty",
            "--enable-install-libbfd"]

    # brew's build environment is in our way
    ENV.delete 'CFLAGS'
    ENV.delete 'CXXFLAGS'
    ENV.delete 'LD'
    ENV.delete 'CC'
    ENV.delete 'CXX'

    if MacOS.lion?
      ENV['CC'] = 'clang'
    end

    # Pick up any autotools changes.
    ENV['AUTOCONF'] = '/usr/local/bin/autoconf264'
    ENV['AUTOM4TE'] = '/usr/local/bin/autom4te264'
    system "autoconf"
    system "autoreconf", "ld"

    system "./configure", "--target=avr", *args

    system "make", "all-bfd", "TARGET-bfd=headers"
    rm 'bfd/Makefile'

    system "make", "configure-host"

    system "make"
    system "make install"
  end
end
