class Emacs < Formula
  desc "GNU Emacs text editor"
  homepage "https://www.gnu.org/software/emacs/"
  url "https://ftpmirror.gnu.org/emacs/emacs-24.5.tar.xz"
  mirror "https://ftp.gnu.org/gnu/emacs/emacs-24.5.tar.xz"
  sha256 "dd47d71dd2a526cf6b47cb49af793ec2e26af69a0951cc40e43ae290eacfc34e"

  devel do
    url "https://alpha.gnu.org/gnu/emacs/pretest/emacs-25.2-rc1.tar.xz"
    sha256 "a94e8e190992627c9b7ef5683d267663bb4c9c2880ef5093988ba42cf8aeae2b"
  end

  head do
    url "https://github.com/emacs-mirror/emacs.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gnu-sed" => :build
    depends_on "texinfo" => :build
  end

  option "with-cocoa", "Build a Cocoa version of emacs"
  option "with-ctags", "Don't remove the ctags executable that emacs provides"
  option "without-libxml2", "Don't build with libxml2 support"
  option "with-modules", "Compile with dynamic modules support"

  deprecated_option "cocoa" => "with-cocoa"
  deprecated_option "keep-ctags" => "with-ctags"
  deprecated_option "with-d-bus" => "with-dbus"

  depends_on "pkg-config" => :build
  depends_on "dbus" => :optional
  depends_on "gnutls" => :optional
  depends_on "librsvg" => :optional
  depends_on "imagemagick" => :optional
  depends_on "mailutils" => :optional

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp
      --infodir=#{info}/emacs
      --prefix=#{prefix}
      --without-x
    ]

    if build.with? "libxml2"
      args << "--with-xml2"
    else
      args << "--without-xml2"
    end

    if build.with? "dbus"
      args << "--with-dbus"
    else
      args << "--without-dbus"
    end

    if build.with? "gnutls"
      args << "--with-gnutls"
    else
      args << "--without-gnutls"
    end

    args << "--with-imagemagick" if build.with? "imagemagick"
    args << "--with-modules" if build.with? "modules"
    args << "--with-rsvg" if build.with? "librsvg"
    args << "--without-pop" if build.with? "mailutils"
    # no need?
    args << "--with-rsvg" if build.with? "librsvg"
    args << "--without-popmail" if build.with? "mailutils"

    #system "./autogen.sh" if build.head? || build.devel?
    if build.head?
      ENV.prepend_path "PATH", Formula["gnu-sed"].opt_libexec/"gnubin"
      system "./autogen.sh"
    end

    if build.with? "cocoa"
      args << "--with-ns" << "--disable-ns-self-contained"
    else
      args << "--without-ns"
    end

    system "./configure", *args
    system "make"
    system "make", "install"

    if build.with? "cocoa"
      ## Remove when 25.1 is released
      #if build.stable?
      #  chmod 0644, %w[nextstep/Emacs.app/Contents/PkgInfo
      #                 nextstep/Emacs.app/Contents/Resources/Credits.html
      #                 nextstep/Emacs.app/Contents/Resources/document.icns
      #                 nextstep/Emacs.app/Contents/Resources/Emacs.icns]
      #end
      prefix.install "nextstep/Emacs.app"

      # Replace the symlink with one that avoids starting Cocoa.
      (bin/"emacs").unlink # Kill the existing symlink
      (bin/"emacs").write <<-EOS.undent
        #!/bin/bash
        exec #{prefix}/Emacs.app/Contents/MacOS/Emacs "$@"
      EOS
    end

    # Follow MacPorts and don't install ctags from Emacs. This allows Vim
    # and Emacs and ctags to play together without violence.
    if build.without? "ctags"
      (bin/"ctags").unlink
      (man1/"ctags.1.gz").unlink
    end
  end

  def caveats
    if build.with? "cocoa" then <<-EOS.undent
      Please try the Cask for a better-supported Cocoa version:
        brew cask install emacs
      EOS
    end
  end

  plist_options :manual => "emacs"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/emacs</string>
        <string>--daemon</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_equal "4", shell_output("#{bin}/emacs --batch --eval=\"(print (+ 2 2))\"").strip
  end
end
