class Libsndfile < Formula
  desc "C library for files containing sampled sound"
  homepage "http://www.mega-nerd.com/libsndfile/"
  url "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.26.tar.gz"
  sha256 "cd6520ec763d1a45573885ecb1f8e4e42505ac12180268482a44b28484a25092"

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "flac"
  depends_on "libogg"
  depends_on "libvorbis"

  #
  # yaz added the genre patch for wav
  #
  patch :DATA

  def install
    ENV.universal_binary if build.universal?

    system "autoreconf", "-i"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end

__END__
--- a/programs/sndfile-metadata-get.c	2011-03-21 08:06:59.000000000 +0900
+++ b/programs/sndfile-metadata-get.c	2012-07-05 23:05:37.104941613 +0900
@@ -120,6 +120,7 @@ usage_exit (const char *progname, int ex
 		"    --str-date            Print the creation date metadata.\n"
 		"    --str-album           Print the album metadata.\n"
 		"    --str-license         Print the license metadata.\n"
+		"    --str-genre           Print the genre metadata.\n"
 		) ;
 
 	printf ("Using %s.\n\n", sf_version_string ()) ;
@@ -164,6 +165,7 @@ process_args (SNDFILE * file, const SF_B
 		HANDLE_STR_ARG ("--str-date", "Create date", SF_STR_DATE) ;
 		HANDLE_STR_ARG ("--str-album", "Album", SF_STR_ALBUM) ;
 		HANDLE_STR_ARG ("--str-license", "License", SF_STR_LICENSE) ;
+		HANDLE_STR_ARG ("--str-genre", "Genre", SF_STR_GENRE) ;
 
 		if (! do_all)
 		{	printf ("Error : Don't know what to do with command line arg '%s'.\n\n", argv [k]) ;
