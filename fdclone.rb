class Fdclone < Formula
  desc "Console-based file manager"
  homepage "http://hp.vector.co.jp/authors/VA012337/soft/fd/"
  #url "http://hp.vector.co.jp/authors/VA012337/soft/fd/FD-3.01e.tar.gz"
  url "http://www.honeyplanet.jp/FD-3.01e.tar.gz"
  sha256 "0ddabfdbab6c26fb54fc0d84ea9203ac5f29ea3f99b39f13a4f4537b2bd9c300"

  depends_on "nkf" => :build

  patch :DATA

  def install
    ENV.deparallelize
    system "make", "PREFIX=#{prefix}", "all"
    system "make", "MANTOP=#{man}", "install"

    %w[README FAQ HISTORY LICENSES TECHKNOW ToAdmin].each do |file|
      system "nkf", "-w", "--overwrite", file
      prefix.install "#{file}.eng" => file
      prefix.install file => "#{file}.ja"
    end

    share.install "_fdrc" => "fd2rc.dist"
  end

  def caveats; <<~EOS
    To install the initial config file:
        install -c -m 0644 #{share}/fd2rc.dist ~/.fd2rc
    To set application messages to Japanese, edit your .fd2rc:
        MESSAGELANG="ja"
    EOS
  end
end

__END__
diff --git a/machine.h b/machine.h
index 8bc70ab..39b0d28 100644
--- a/machine.h
+++ b/machine.h
@@ -1449,4 +1449,6 @@ typedef unsigned long		u_long;
 #define	GETTODARGS		2
 #endif

+#define USEDATADIR
+
 #endif	/* !__MACHINE_H_ */
diff --git a/custom.c b/custom.c
index d7a995f..45b96c6 100644
--- a/custom.c
+++ b/custom.c
@@ -566,7 +566,7 @@ static CONST envtable envlist[] = {
 	{"FD_URLKCODE", &urlkcode, DEFVAL(NOCNV), URLKC_E, T_KNAM},
 #endif
 #if	!defined (_NOENGMES) && !defined (_NOJPNMES)
-	{"FD_MESSAGELANG", &messagelang, DEFVAL(NOCNV), MESL_E, T_MESLANG},
+	{"FD_MESSAGELANG", &messagelang, DEFVAL("C"), MESL_E, T_MESLANG},
 #endif
 #ifdef	DEP_FILECONV
 	{"FD_SJISPATH", &sjispath, DEFVAL(SJISPATH), SJSP_E, T_KPATHS},
@@ -862,7 +862,9 @@ int no;
 #if	defined (DEP_KCONV) || (!defined (_NOENGMES) && !defined (_NOJPNMES))
 		case T_MESLANG:
 # ifndef	_NOCATALOG
+			if (!cp) cp = def_str(no);
 			catname = cp;
+			chkcatalog();
 /*FALLTHRU*/
 # endif
 		case T_KIN:
diff --git a/fd.h b/fd.h
index 08de84b..63cdaeb 100644
--- a/fd.h
+++ b/fd.h
@@ -104,16 +104,16 @@ extern char *_mtrace_file;
  *	variables nor run_com file nor command line option	*
  ****************************************************************/
 #define	BASICCUSTOM		0
-#define	SORTTYPE		0
-#define	DISPLAYMODE		0
-#define	SORTTREE		0
+#define	SORTTYPE		1
+#define	DISPLAYMODE		3
+#define	SORTTREE		1
 #define	WRITEFS			0
 #define	IGNORECASE		0
 #define	VERSIONCOMP		0
 #define	INHERITCOPY		0
 #define	PROGRESSBAR		0
 #define	PRECOPYMENU		0
-#define	ADJTTY			0
+#define	ADJTTY			1
 #define	USEGETCURSOR		0
 #define	DEFCOLUMNS		2
 #define	MINFILENAME		12
@@ -155,7 +155,7 @@ extern char *_mtrace_file;
 #define	FREQFILE		"~/.fd_freq"
 #endif	/* !MSDOS */
 #define	FREQUMASK		022
-#define	ANSICOLOR		0
+#define	ANSICOLOR		1
 #define	ANSIPALETTE		""
 #define	EDITMODE		"emacs"
 #define	LOOPCURSOR		0
@@ -193,7 +193,7 @@ extern char *_mtrace_file;
 #define	HTTPPROXY		""
 #define	HTTPLOGFILE		""
 #define	HTMLLOGFILE		""
-#define	UNICODEBUFFER		0
+#define	UNICODEBUFFER		1
 #define	SJISPATH		""
 #define	EUCPATH			""
 #define	JISPATH			""
diff --git a/_fdrc b/_fdrc
index 97aec7b..0a81bb9 100644
--- a/_fdrc
+++ b/_fdrc
@@ -7,8 +7,8 @@
 #BASICCUSTOM=0
 
 # default sort type
-#	0: not sort (Default)
-#	1: alphabetical	9: alphabetical (reversal)
+#	0: not sort
+#	1: alphabetical	(Default) 9: alphabetical (reversal)
 #	2: extension	10: extension (reversal)
 #	3: size		11: size (reversal)
 #	4: date		12: date (reversal)
@@ -16,23 +16,23 @@
 #	100-113: preserve previous sort type
 #	200-213: preserve previous sort type also in the archive browser
 #		(the least 2 digits are effective just after initialize)
-#SORTTYPE=0
+#SORTTYPE=1
 
 # default display mode
-#	0: normal (Default)
+#	0: normal
 #	1: sym-link status
 #	2: 			file type symbol
-#	3: sym-link status &	file type symbol
+#	3: sym-link status &	file type symbol (Default)
 #	4: 						invisible dot file
 #	5: sym-link status &				invisible dot file
 #	6: 			file type symbol &	invisible dot file
 #	7: sym-link status &	file type symbol &	invisible dot file
-#DISPLAYMODE=0
+#DISPLAYMODE=3
 
 # whether if sort or not in tree mode
-#	0: not sort (Default)
-#	>= 1: sort according to SORTTYPE
-#SORTTREE=0
+#	0: not sort
+#	>= 1: sort according to SORTTYPE (Default)
+#SORTTREE=1
 
 # behavior about writing over directory on file system
 #	0: confirm to write or not, after directory arranged (Default)
@@ -61,9 +61,9 @@
 #PRECOPYMENU=0
 
 # whether if adjust tty or not when exiting
-#	0: not adjust (Default)
-#	>= 1: adjust
-#ADJTTY=0
+#	0: not adjust
+#	>= 1: adjust (Default)
+#ADJTTY=1
 
 # whether if prioritize VT100 escape sequence or not for getting terminal size
 #	0: not prioritize (Default)
@@ -179,11 +179,11 @@
 #FREQUMASK=022
 
 # whether if support ANSI color escape sequence
-#	0: monochrome (Default)
-#	1: color
+#	0: monochrome
+#	1: color (Default)
 #	2: color & force background to blacken
 #	3: color & force foreground to blacken
-#ANSICOLOR=0
+#ANSICOLOR=1
 
 # color palette in the ANSI color mode
 #	Default: none
@@ -374,9 +374,9 @@
 #HTMLLOGFILE=""
 
 # whether if hold the UNICODE translation table on memory
-#	0: not hold (Default)
-#	>= 1: hold
-#UNICODEBUFFER=0
+#	0: not hold
+#	>= 1: hold (Default)
+#UNICODEBUFFER=1
 
 # language code to be displayed
 #	Default: No convert
diff --git a/mkunitbl.c b/mkunitbl.c
--- a/mkunitbl.c
+++ b/mkunitbl.c
@@ -222,7 +222,10 @@
 	{0x221e, 0x8187},
 	{0x221f, 0x8798},
 	{0x2220, 0x81da},
-	{0x2225, 0x8161},
+
+//	{0x2225, 0x8161},
+	{0x2225, 0x2225},
+
 	{0x2227, 0x81c8},
 	{0x2228, 0x81c9},
 	{0x2229, 0x81bf},
@@ -9254,6 +9257,7 @@
 	{0xffe5, 0x818f},
 };
 #define	UNILISTSIZ		arraysize(unilist)
+
 static nftable macunilist[] = {
 	{0x00c0, {0x0041, 0x0300, 0}},
 	{0x00c1, {0x0041, 0x0301, 0}},
@@ -10107,7 +10111,7 @@
 	{0x1ffc, {0x03a9, 0x0345, 0}},
 	{0x1ffd, {0x00b4, 0}},
 	{0x2015, {0x2014, 0}},
-	{0x2225, {0x2016, 0}},
+	{0x2225, {0x2016, 0}},          // "parallel to" to "double vertical line"
 	{0x304c, {0x304b, 0x3099, 0}},
 	{0x304e, {0x304d, 0x3099, 0}},
 	{0x3050, {0x304f, 0x3099, 0}},
@@ -10199,20 +10203,21 @@
 	{0xfb4c, {0x05d1, 0x05bf, 0}},
 	{0xfb4d, {0x05db, 0x05bf, 0}},
 	{0xfb4e, {0x05e4, 0x05bf, 0}},
-	{0xff0d, {0x2212, 0}},
-	{0xff5e, {0x301c, 0}},
-	{0xffe0, {0x00a2, 0}},
-	{0xffe1, {0x00a3, 0}},
-	{0xffe2, {0x00ac, 0}},
+//	{0xff0d, {0x2212, 0}}, //―
+	{0xff5e, {0x301c, 0}}, //〜
+	{0xffe0, {0x00a2, 0}}, //¢
+	{0xffe1, {0x00a3, 0}}, //£
+	{0xffe2, {0x00ac, 0}}, //¬
 };
 #define	MACUNILISTSIZ		arraysize(macunilist)
+
 static nftable iconvunilist[] = {
-	{0x2225, {0x2016, 0}},
-	{0xff0d, {0x2212, 0}},
-	{0xff5e, {0x301c, 0}},
-	{0xffe0, {0x00a2, 0}},
-	{0xffe1, {0x00a3, 0}},
-	{0xffe2, {0x00ac, 0}},
+	{0x2225, {0x2016, 0}}, // "parallel to" to "double vertical line"
+//	{0xff0d, {0x2212, 0}}, //―
+	{0xff5e, {0x301c, 0}}, //〜
+	{0xffe0, {0x00a2, 0}}, //¢
+	{0xffe1, {0x00a3, 0}}, //£
+	{0xffe2, {0x00ac, 0}}, //¬
 };
 #define	ICONVUNILISTSIZ		arraysize(iconvunilist)
 
diff --git a/fd.h b/fd.h
--- a/fd.h
+++ b/fd.h
@@ -408,9 +408,9 @@
 #define	TC_USED			(TC_TOTAL + TW_TOTAL + TD_TOTAL + TW_GAP)
 #define	TC_FREE			(TC_USED + TW_USED + TD_USED + TW_GAP)
 
-#define	WSIZE			9
+#define	WSIZE			11
 #define	WSIZE2			8
-#define	TWSIZE2			10
+#define	TWSIZE2			12
 #define	WDATE			8
 #define	WTIME			5
 #define	WSECOND			2
