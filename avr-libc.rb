require 'formula'

class AtmelHeaders < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-GNU-Toolchain/3.4.3/avr8-headers-6.2.0.142.zip'
  sha1 '82c632cc2b91fed7937f60506bbb83cd0fb1a176'
end


class AvrLibc < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-GNU-Toolchain/3.4.3/avr-libc-1.8.0.tar.gz'
  homepage 'http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx'
  sha1 'e600c02c103c82a2b87102c86b65e53b12a37f39'

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

