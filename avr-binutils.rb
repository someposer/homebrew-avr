require 'formula'

class AvrBinutils < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-GNU-Toolchain/3.4.3/avr-binutils-2.23.2.tar.gz'
  homepage 'http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx'
  sha1 '657174514e56b524f523bfbee4912f2878fca161'

  depends_on :autoconf
  depends_on :automake

  def patches
      # Patch the config script to ignore autoconf version
      DATA
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

    if MacOS.version >= :lion
      ENV['CC'] = 'clang'
    end

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
