class Phash < Formula
  desc "Perceptual hash library"
  homepage "http://www.phash.org/"
  url "http://phash.org/releases/pHash-0.9.6.tar.gz"
  sha256 "3c8258a014f9c2491fb1153010984606805638a45d00498864968a9a30102935"
  revision 1

  option "without-image-hash", "Disable image hash"
  option "without-video-hash", "Disable video hash"
  option "without-audio-hash", "Disable audio hash"

  deprecated_option "disable-image-hash" => "without-image-hash"
  deprecated_option "disable-video-hash" => "without-video-hash"
  deprecated_option "disable-audio-hash" => "without-audio-hash"

  depends_on "cimg" if build.with?("image-hash") || build.with?("video-hash")
  depends_on "ffmpeg" if build.with? "video-hash"
  depends_on 'autoconf'

  if build.with? "audio-hash"
    depends_on "libsndfile"
    depends_on "libsamplerate"
    depends_on "mpg123"
  end

  fails_with :clang do
    build 318
    cause "configure: WARNING: CImg.h: present but cannot be compiled"
  end

  patch :DATA

  def install
    inreplace "src/ph_fft.h", "/usr/include/complex.h", "#{MacOS.sdk_path}/usr/include/complex.h"

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-shared
    ]

    args << "--disable-image-hash" if build.without? "image-hash"
    args << "--disable-video-hash" if build.without? "video-hash"
    args << "--disable-audio-hash" if build.without? "audio-hash"

    system "/usr/local/bin/automake"
    system "/usr/local/bin/autoreconf"
    system "./configure", *args
    system "make", "install"
  end
end

__END__
diff -r 16bd3c87a566 configure.ac
--- a/configure.ac	Mon Jul 07 16:04:00 2014 +0900
+++ b/configure.ac	Fri Nov 11 14:51:03 2016 +0900
@@ -122,7 +122,7 @@ fi])
 AC_DEFUN([AC_CHECK_FFMPEG],
 [
 AC_MSG_CHECKING([whether FFmpeg is present])
-AC_CHECK_LIB([avcodec], [avcodec_alloc_frame], [], [AC_MSG_ERROR([
+AC_CHECK_LIB([avcodec], [av_frame_alloc], [], [AC_MSG_ERROR([
 
 *** libavcodec not found.
 You need FFmpeg. Get it at <http://ffmpeg.org/>])])
diff -r 16bd3c87a566 src/cimgffmpeg.cpp
--- a/src/cimgffmpeg.cpp	Mon Jul 07 16:04:00 2014 +0900
+++ b/src/cimgffmpeg.cpp	Fri Nov 11 14:51:03 2016 +0900
@@ -39,11 +39,11 @@ void vfinfo_close(VFInfo  *vfinfo){
 int ReadFrames(VFInfo *st_info, CImgList<uint8_t> *pFrameList, unsigned int low_index, unsigned int hi_index)
 {
         //target pixel format
-	PixelFormat ffmpeg_pixfmt;
+	AVPixelFormat ffmpeg_pixfmt;
 	if (st_info->pixelformat == 0)
-	    ffmpeg_pixfmt = PIX_FMT_GRAY8;
+	    ffmpeg_pixfmt = AV_PIX_FMT_GRAY8;
 	else 
-	    ffmpeg_pixfmt = PIX_FMT_RGB24;
+	    ffmpeg_pixfmt = AV_PIX_FMT_RGB24;
 
 	st_info->next_index = low_index;
 
@@ -100,12 +100,12 @@ int ReadFrames(VFInfo *st_info, CImgList
         AVFrame *pFrame;
 
 	// Allocate video frame
-	pFrame=avcodec_alloc_frame();
+	pFrame=av_frame_alloc();
 	if (pFrame==NULL)
 	    return -1;
 
 	// Allocate an AVFrame structure
-	AVFrame *pConvertedFrame = avcodec_alloc_frame();
+	AVFrame *pConvertedFrame = av_frame_alloc();
 	if(pConvertedFrame==NULL)
 	  return -1;
 		
@@ -123,7 +123,7 @@ int ReadFrames(VFInfo *st_info, CImgList
 	int size = 0;
 	
 
-        int channels = ffmpeg_pixfmt == PIX_FMT_GRAY8 ? 1 : 3;
+        int channels = ffmpeg_pixfmt == AV_PIX_FMT_GRAY8 ? 1 : 3;
 
 	AVPacket packet;
 	int result = 1;
@@ -189,11 +189,11 @@ int ReadFrames(VFInfo *st_info, CImgList
 
 int NextFrames(VFInfo *st_info, CImgList<uint8_t> *pFrameList)
 {
-        PixelFormat ffmpeg_pixfmt;
+        AVPixelFormat ffmpeg_pixfmt;
 	if (st_info->pixelformat == 0)
-	    ffmpeg_pixfmt = PIX_FMT_GRAY8;
+	    ffmpeg_pixfmt = AV_PIX_FMT_GRAY8;
         else 
-	    ffmpeg_pixfmt = PIX_FMT_RGB24;
+	    ffmpeg_pixfmt = AV_PIX_FMT_RGB24;
 
 	if (st_info->pFormatCtx == NULL)
 	{
@@ -254,10 +254,10 @@ int NextFrames(VFInfo *st_info, CImgList
 	AVFrame *pFrame;
 
 	// Allocate video frame
-	pFrame=avcodec_alloc_frame();
+	pFrame=av_frame_alloc();
 		
 	// Allocate an AVFrame structure
-	AVFrame *pConvertedFrame = avcodec_alloc_frame();
+	AVFrame *pConvertedFrame = av_frame_alloc();
 	if(pConvertedFrame==NULL){
 	  return -1;
 	}
@@ -287,7 +287,7 @@ int NextFrames(VFInfo *st_info, CImgList
 			break;
 		if(packet.stream_index == st_info->videoStream) {
 			
-		int channels = ffmpeg_pixfmt == PIX_FMT_GRAY8 ? 1 : 3;
+		int channels = ffmpeg_pixfmt == AV_PIX_FMT_GRAY8 ? 1 : 3;
  		AVPacket avpkt;
                 av_init_packet(&avpkt);
                 avpkt.data = packet.data;
