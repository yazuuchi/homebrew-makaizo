require 'formula'

class HpnSsh < Formula
  desc "OpenBSD freely-licensed SSH connectivity tools"
  homepage "http://www.openssh.com/"
  url "http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.5p1.tar.gz"
  mirror "https://www.mirrorservice.org/pub/OpenBSD/OpenSSH/portable/openssh-7.5p1.tar.gz"
  version "7.5p1"
  sha256 "9846e3c5fab9f0547400b4d2c017992f914222b3fd1f8eee6c7dc6bc5e59f9f0"

  option 'without-brewed-openssl', 'Build without Homebrew OpenSSL. Use the system version'
  option 'without-keychain-support', 'Build without keychain and launch daemon support'
  option "with-libressl", "Build with LibreSSL instead of OpenSSL"

  depends_on 'autoconf' => :build if build.with? 'keychain-support'
  depends_on 'openssl' if build.with? 'brewed-openssl'
  depends_on "libressl" => :optional
  depends_on 'ldns' => :optional
  depends_on 'pkg-config' => :build if build.with? "ldns"
  depends_on "libedit" => :build unless OS.mac?

  conflicts_with 'openssh'

  if OS.mac?
    # Both these patches are applied by Apple.
    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/1860b0a74/openssh/patch-sandbox-darwin.c-apple-sandbox-named-external.diff"
      sha256 "d886b98f99fd27e3157b02b5b57f3fb49f43fd33806195970d4567f12be66e71"
    end

    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/d8b2d8c2/openssh/patch-sshd.c-apple-sandbox-named-external.diff"
      sha256 "3505c58bf1e584c8af92d916fe5f3f1899a6b15cc64a00ddece1dc0874b2f78f"
    end

    resource "com.openssh.sshd.sb" do
      url "https://opensource.apple.com/source/OpenSSH/OpenSSH-209.50.1/com.openssh.sshd.sb"
      sha256 "a273f86360ea5da3910cfa4c118be931d10904267605cdd4b2055ced3a829774"
    end
  end

  # yaz hpn
  patch do
    url "http://www.honeyplanet.jp/openssh-7_5_P1-hpn-14.13"
    sha256 "acac3fa6f0653c4d11f0f78bd975475e5defdfacb8bc1f68d4f985c20bf3df59"
  end

  # yaz keychain
  if build.with? 'keychain-support'
    patch do
      url "http://www.honeyplanet.jp/openssh-7_5_P1-post-hpn14.13-keychain"
      sha256 "148bb75dcd2c5749fb156b18e7246f4c0a7c098c291c76c1fa20283445cb84b9"
    end
  end

  def install
    ENV.append "CPPFLAGS", "-D__APPLE_SANDBOX_NAMED_EXTERNAL__" if OS.mac?

    if build.with? "keychain-support"
      ENV.append "CPPFLAGS", "-D__APPLE_LAUNCHD__ -D__APPLE_KEYCHAIN__"
      ENV.append "LDFLAGS", "-framework CoreFoundation -framework SecurityFoundation -framework Security"
    end

    args = %W[
      --with-libedit
      --with-pam
      --with-kerberos5
      --prefix=#{prefix}
      --sysconfdir=#{etc}/ssh
    ]

    if build.with? "libressl"
      args << "--with-ssl-dir=#{Formula["libressl"].opt_prefix}"
    elsif build.with? "brewed-openssl"
      args << "--with-ssl-dir=#{Formula["openssl"].opt_prefix}"
    else
      args<< "--with-ssl-dir=/usr"
    end

    args << "--with-ldns" if build.with? "ldns"
    args << "--without-openssl-header-check"

    system "/usr/local/bin/autoreconf -i" if build.with? 'keychain-support'
    system "./configure", *args
    system "make"
    system "make install"

    # This was removed by upstream with very little announcement and has
    # potential to break scripts, so recreate it for now.
    # Debian have done the same thing.
    bin.install_symlink bin/"ssh" => "slogin"

    buildpath.install resource("com.openssh.sshd.sb")
    (etc/"ssh").install "com.openssh.sshd.sb" => "org.openssh.sshd.sb"
  end

  def caveats
    if build.with? 'keychain-support' then <<-EOS.undent
      For complete functionality, please modify:
        /System/Library/LaunchAgents/org.openbsd.ssh-agent.plist
      and change ProgramArugments from
        /usr/bin/ssh-agent
      to
        /usr/local/bin/ssh-agent
      After that, you can start storing private key passwords in
      your OS X Keychain.
      EOS
    end
  end

end
