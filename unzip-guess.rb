require 'formula'

class UnzipGuess < Formula
  homepage 'http://www.info-zip.org/pub/infozip/UnZip.html'
  url 'https://downloads.sourceforge.net/project/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz'
  version '6.0'
  sha1 'abf7de8a4018a983590ed6f5cbd990d4740f8a22'

  keg_only :provided_by_osx

  patch do
    url "http://www.honeyplanet.jp/unzip60.patch"
    sha1 "18149b4d87857f314da86146dced39e7481b8494"
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
