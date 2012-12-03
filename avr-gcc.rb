require 'formula'

# Atmel distributes a complete tarball of patches.
class AtmelPatches < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-Toolchain-3.4.1.830/avr/avr-patches.tar.gz'
  homepage 'http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx'
  sha1 '08208bdc9ddb6b4b328c1b4c94a2b81f1d750289'
end

# print avr-gcc's builtin include paths
# `avr-gcc -print-prog-name=cc1plus` -v

class AvrGcc < Formula
  homepage 'http://gcc.gnu.org'
  url 'http://ftp.gnu.org/gnu/gcc/gcc-4.6.2/gcc-4.6.2.tar.bz2'
  sha1 '691974613b1c1f15ed0182ec539fa54a12dd6f93'

  depends_on 'avr-binutils'
  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'

  option 'disable-cxx', "Don't build the g++ compiler"

  def patches
    mkdir buildpath/'patches'
    AtmelPatches.new.brew { cp Dir['gcc/*'], buildpath/'patches' }
    { :p0 => Dir[buildpath/'patches/*'] }
  end

  def install
    gmp = Formula.factory 'gmp'
    mpfr = Formula.factory 'mpfr'
    libmpc = Formula.factory 'libmpc'

    # brew's build environment is in our way
    ENV.delete 'CFLAGS'
    ENV.delete 'CXXFLAGS'
    ENV.delete 'AS'
    ENV.delete 'LD'
    ENV.delete 'NM'
    ENV.delete 'RANLIB'

    if MacOS.lion?
      ENV['CC'] = 'llvm-gcc'
    end

    args = [
            "LDFLAGS=-L#{prefix}/lib",
            "--target=avr",
            "--with-dwarf2",
            "--disable-shared",
            "--disable-libada",
            "--disable-libssp",
            "--disable-nls",
            # Sandbox everything...
            "--prefix=#{prefix}",
            "--with-gmp=#{gmp.prefix}",
            "--with-mpfr=#{mpfr.prefix}",
            "--with-mpc=#{libmpc.prefix}",
            # ...except the stuff in share...
            "--datarootdir=#{share}",
            # ...and the binaries...
            "--bindir=#{bin}",
            # This shouldn't be necessary
            "--with-as=/usr/local/bin/avr-as",
            # Not sure if this is really needed.
            "--enable-fixed-point"
           ]

    # The C compiler is always built, C++ can be disabled
    languages = %w[c]
    languages << 'c++' unless build.include? 'disable-cxx'

    # Pick up any autotools changes.
    ENV['AUTOCONF'] = '/usr/local/bin/autoconf264'
    ENV['AUTOM4TE'] = '/usr/local/bin/autom4te264'
    system "autoconf"

    Dir.mkdir 'build'
    Dir.chdir 'build' do
      system '../configure', "--enable-languages=#{languages.join(',')}", *args
      system 'make'

      # At this point `make check` could be invoked to run the testsuite. The
      # deja-gnu and autogen formulae must be installed in order to do this.

      system 'make install'
    end
  end
end

 
