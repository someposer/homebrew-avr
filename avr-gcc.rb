require 'formula'

class AvrGcc < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-Toolchain-3.4.1.830/avr/avr-gcc-4.6.2.tar.gz'
  homepage 'http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx'
  sha1 '4b38701bf840b94e9d8d4ccac1b9921508935e15'

  depends_on :autoconf
  depends_on :automake
  depends_on 'avr-binutils'
  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'

  option 'disable-cxx', "Don't build the g++ compiler"

  def patches
      # Patch the config script to ignore autoconf version
      DATA
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

    if MacOS.version >= :lion
      ENV['CC'] = 'llvm-gcc' 
    end

    args = [
            "LDFLAGS=-L#{lib}",
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


__END__
diff --git a/config/override.m4 b/config/override.m4
index 52bd1c3..0066780 100644
--- a/config/override.m4
+++ b/config/override.m4
@@ -41,7 +41,7 @@ dnl Or for updating the whole tree at once with the definition above.
 AC_DEFUN([_GCC_AUTOCONF_VERSION_CHECK],
 [m4_if(m4_defn([_GCC_AUTOCONF_VERSION]),
   m4_defn([m4_PACKAGE_VERSION]), [],
-  [m4_fatal([Please use exactly Autoconf ]_GCC_AUTOCONF_VERSION[ instead of ]m4_defn([m4_PACKAGE_VERSION])[.])])
+  [m4_errprintn([Please use exactly Autoconf ]_GCC_AUTOCONF_VERSION[ instead of ]m4_defn([m4_PACKAGE_VERSION])[.])])
 ])
 m4_define([AC_INIT], m4_defn([AC_INIT])[
 _GCC_AUTOCONF_VERSION_CHECK
