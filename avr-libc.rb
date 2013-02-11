require 'formula'

class AtmelHeaders < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-Toolchain-3.4.1.830/avr/avr-headers-6.1.0.1157.zip'
  sha1 '633d7e8c93d54579b21bb3a76721b1d88572d677'
end


class AvrLibc < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-Toolchain-3.4.1.830/avr/avr-libc-1.8.0.tar.gz'
  homepage 'http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx'
  sha1 '36a74a59b6afda0c62b54a0a0d447d18f73f12c4'

  depends_on :autoconf
  depends_on :automake
  depends_on 'avr-gcc'

  def install
    # brew's build environment is in our way
    ENV.delete 'CFLAGS'
    ENV.delete 'CXXFLAGS'
    ENV.delete 'LD'
    ENV.delete 'CC'
    ENV.delete 'CXX'

    # Pull in the latest Atmel headers.
    AtmelHeaders.new.brew do
      cp Dir['io[0-9a-zA-Z]*.h'], buildpath/'include/avr/'
    end

    # Run the bootstrap script to pull in any changes.
    system "./bootstrap"

    args = [
            "--host=avr",
            "--prefix=#{prefix}",
            "--libdir=#{lib}",
            "--datadir=#{prefix}"
           ]

    system "./configure", *args

    system "make", "install"

    # copy include and lib files where avr-gcc searches for them
    # this wouldn't be necessary with a standard prefix
    # XXX There's got to be a better way, maybe symlinks?
    avr = File.join prefix, 'avr'
    avr_gcc = Formula.factory('avr-gcc')
    ohai "copying #{avr} -> #{avr_gcc.prefix}"
    cp_r avr, avr_gcc.prefix
  end
end

