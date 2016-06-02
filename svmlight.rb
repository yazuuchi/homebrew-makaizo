require 'formula'

class Svmlight < Formula
  url 'http://osmot.cs.cornell.edu/svm_light/v6.02/svm_light.tar.gz'
  version '6.02'
  homepage 'http://svmlight.joachims.org/'
  sha256 'aa48985a4c77eecd84d293de40d4731da767e49a1d2323c6198180652aa8724e'

  def install
    system "make", "CFLAGS=#{ENV.cflags}"
    mv 'libsvmlight.so', 'libsvmlight.dylib'
    bin.install 'svm_learn', 'svm_classify'
    lib.install 'libsvmlight.dylib'
    include.install 'kernel.h', 'svm_common.h', 'svm_learn.h'
  end

  def patches
    DATA
  end

end

__END__
diff --git a/Makefile b/Makefile
--- a/Makefile
+++ b/Makefile
@@ -4,6 +4,9 @@
 # Thorsten Joachims, 2002
 #
 
+#Destination
+DEST=HOMEBREW_PREFIX
+
 #Use the following to compile under unix or cygwin
 CC = gcc
 LD = gcc
@@ -11,13 +14,17 @@ LD = gcc
 #Uncomment the following line to make CYGWIN produce stand-alone Windows executables
 #SFLAGS= -mno-cygwin
 
-CFLAGS=  $(SFLAGS) -O3                     # release C-Compiler flags
-LFLAGS=  $(SFLAGS) -O3                     # release linker flags
-#CFLAGS= $(SFLAGS) -pg -Wall -pedantic      # debugging C-Compiler flags
-#LFLAGS= $(SFLAGS) -pg                      # debugging linker flags
+#CFLAGS=  $(SFLAGS) -O3                     # release C-Compiler flags
+#LFLAGS=  $(SFLAGS) -O3                     # release linker flags
+##CFLAGS= $(SFLAGS) -pg -Wall -pedantic      # debugging C-Compiler flags
+##LFLAGS= $(SFLAGS) -pg                      # debugging linker flags
+CFLAGS=  $(SFLAGS) -O1 -fPIC                     # release C-Compiler flags
+LFLAGS=  $(SFLAGS) -O1                     # release linker flags
+
+
 LIBS=-L. -lm                               # used libraries
 
-all: svm_learn_hideo svm_classify
+all: svm_learn_hideo svm_classify libsvmlight_hideo
 
 tidy: 
 	rm -f *.o 
@@ -27,6 +34,7 @@ clean:	tidy
 	rm -f svm_learn
 	rm -f svm_classify
 	rm -f libsvmlight.so
+	rm -f libsvmlight.a
 
 help:   info
 
@@ -72,6 +80,7 @@ svm_learn_hideo_noexe: svm_learn_main.o 
 
 libsvmlight_hideo: svm_learn_main.o svm_learn.o svm_common.o svm_hideo.o 
 	$(LD) -shared svm_learn.o svm_common.o svm_hideo.o -o libsvmlight.so
+	ar cr libsvmlight.a svm_learn.o svm_common.o svm_hideo.o
 
 #svm_learn_loqo_noexe: svm_learn_main.o svm_learn.o svm_common.o svm_loqo.o loqo
 
@@ -103,3 +112,10 @@ svm_classify.o: svm_classify.c svm_commo
 #pr_loqo/pr_loqo.o: pr_loqo/pr_loqo.c
 #	$(CC) -c $(CFLAGS) pr_loqo/pr_loqo.c -o pr_loqo/pr_loqo.o
 
+install: all
+	install -m755 svm_classify $(DEST)/bin
+	install -m755 svm_learn $(DEST)/bin
+	install -m755 libsvmlight.so $(DEST)/lib
+	install -m644 libsvmlight.a $(DEST)/lib
+	mkdir -p $(DEST)/include/svmlight
+	install -m644 kernel.h svm_common.h svm_learn.h $(DEST)/include/svmlight
