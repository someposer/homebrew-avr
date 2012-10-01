require 'formula'

# Atmel distributes a complete tarball of patches.
class AtmelPatches < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-Toolchain-3.4.1/avr/avr-patches.tar.gz'
  homepage 'http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx'
  sha1 '59a139a42c8dada06fa5e3ebbd3d37f8d16b0d11'
end

class AtmelHeaders < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-Toolchain-3.4.1/avr/avr-headers-3.2.3.970.zip'
  sha1 '2e8c236e8b10892daf63703fea71172af14f0e11'
end


class AvrLibc < Formula
  url 'http://download.savannah.gnu.org/releases/avr-libc/avr-libc-1.8.0.tar.bz2'
  homepage 'http://www.nongnu.org/avr-libc/'
  md5 '54c71798f24c96bab206be098062344f'

  depends_on 'avr-gcc'

  def patches
    mkdir buildpath/'patches'
    AtmelPatches.new.brew { cp Dir['avr-libc/*'], buildpath/'patches' }
    { :p0 => Dir[buildpath/'patches/*'] }
  end

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
            "--libdir=#{prefix}/lib",
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

