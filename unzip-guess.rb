require 'formula'

class UnzipGuess < Formula
  homepage 'http://www.info-zip.org/pub/infozip/UnZip.html'
  url 'https://downloads.sourceforge.net/project/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz'
  version '6.0'
  sha256 '036d96991646d0449ed0aa952e4fbe21b476ce994abc276e49d30e686708bd37'

  keg_only :provided_by_osx

  patch do
    url 'http://www.honeyplanet.jp/unzip60.patch'
    sha256 'e8cccc1dc20edcb80c8169acf4b95c3ffd9cf9618e9d161d07a252d78f26b08d'
  end

  depends_on 'libguess' => :build

  def install
    system "make -f unix/Makefile CF_NOOPT=\"-I. -D_FILE_OFFSET_BITS=64 -DNO_LCHMOD -D_MBCS -DNO_WORKING_ISPRINT -DUNIX -Wno-format-security -Wno-self-assign\" macosx"
    system "make", "prefix=#{prefix}", "MANDIR=#{man}", "install"
  end

  test do
    system "#{bin}/unzip", "--help"
  end
end
