require 'formula'

class HpnSsh < Formula
  desc "OpenBSD freely-licensed SSH connectivity tools"
  homepage "http://www.openssh.com/"
  url "http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.2p2.tar.gz"
  mirror "https://www.mirrorservice.org/pub/OpenBSD/OpenSSH/portable/openssh-7.2p2.tar.gz"
  version "7.2p2"
  sha256 "a72781d1a043876a224ff1b0032daa4094d87565a68528759c1c2cab5482548c"

  option 'with-brewed-openssl', 'Build with Homebrew OpenSSL instead of the system version'
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

    # Patch for SSH tunnelling issues caused by launchd changes on Yosemite
    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/d8b2d8c2/OpenSSH/launchd.patch"
      Sha256 "df61404042385f2491dd7389c83c3ae827bf3997b1640252b018f9230eab3db3"
    end
  end

  # yaz hpn
  patch do
    url "http://www.honeyplanet.jp/openssh_72p2_hpn14v10_progressbar.diff"
    sha256 "405b56b7078f50a8e9745f4b444c6e352a5e82cff1b4041087592f855d6b9775"
  end

  patch do
    url "http://www.honeyplanet.jp/openssh_72p2_hpn14v10_none_cipher.diff"
    sha256 "cacbf00b5e3dc10ccb8c8ca4ffc58634e18db19f11123f67d091e7a99536bab5"
  end

  patch do
    url "http://www.honeyplanet.jp/openssh_72p2_hpn14v10_multi_threaded_cipher.diff"
    sha256 "2e98c4b68d6d7a05f8803a7a4f5d4db15a2647bee74340a54f9529b4ea7020ff"
  end

  patch do
    url "http://www.honeyplanet.jp/openssh_72p2_hpn14v10_dynamically_sized_receive_buffers.diff"
    sha256 "17dd2c66615612997862296ccf175e5364e3e08b6643d4f3a378039085d62bcb"
  end

  # yaz keychain
  if build.with? 'keychain-support'
    patch do
      url "http://www.honeyplanet.jp/openssh_72p2_post_hpn14v10_keychain.diff"
      sha256 "e79197d2ea59f50dcd5696abd3db70dae710313c978a2c867b3336e23ebfb283"
    end
  end

  def install
    if build.with? "keychain-support"
      ENV.append "CPPFLAGS", "-D__APPLE_LAUNCHD__ -D__APPLE_KEYCHAIN__"
      ENV.append "LDFLAGS", "-framework CoreFoundation -framework SecurityFoundation -framework Security"
    end

    args = %W[
      --with-libedit
      --with-kerberos5
      --prefix=#{prefix}
      --sysconfdir=#{etc}/ssh
    ]

    args << "--with-ssl-dir=#{Formula.factory('openssl').opt_prefix}" if build.with? 'brewed-openssl'
    args << "--with-ldns" if build.with? "ldns"
    args << "--without-openssl-header-check"

    system "/usr/local/bin/autoreconf -i" if build.with? 'keychain-support'
    system "./configure", *args
    system "make"
    system "make install"
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
