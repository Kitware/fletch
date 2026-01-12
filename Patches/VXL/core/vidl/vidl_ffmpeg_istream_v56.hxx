// This is core/vidl/vidl_ffmpeg_istream_v56.hxx
#ifndef vidl_ffmpeg_istream_v56_hxx_
#define vidl_ffmpeg_istream_v56_hxx_
#pragma once

//:
// \file
// \author Johan Andruejol
// \author Gehua Yang
// \author Matt Leotta
// \author Amitha Perera
// \date   6 April 2015
//
// Update implementation based on FFMPEG release version 2.8.4
// Updated for FFmpeg 5.x compatibility

//-----------------------------------------------------------------------------

#include <string>
#include <iostream>
#include "vidl_ffmpeg_istream.h"
#include "vidl_ffmpeg_pixel_format.h"
#include "vidl_ffmpeg_init.h"
#include "vidl_frame.h"
#include "vidl_ffmpeg_convert.h"

#include <vcl_compiler.h>

extern "C" {
#if FFMPEG_IN_SEVERAL_DIRECTORIES
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
#else
#include <ffmpeg/avcodec.h>
#include <ffmpeg/avformat.h>
#include <ffmpeg/swscale.h>
#endif
}

//--------------------------------------------------------------------------------

struct vidl_ffmpeg_istream::pimpl
{
  pimpl()
  : fmt_cxt_( NULL ),
    vid_index_( -1 ),
    data_index_( -1 ),
    vid_str_( NULL ),
    video_enc_( NULL ),
    frame_( NULL ),
    num_frames_( -2 ), // sentinel value to indicate not yet computed
    sws_context_( NULL ),
    cur_frame_( NULL ),
    metadata_( 0 ),
    frame_number_offset_( 0 ),
    pts_( 0 )
  {
    packet_ = NULL;
  }

  AVFormatContext* fmt_cxt_;
  int vid_index_;
  int data_index_;
  AVStream* vid_str_;

  AVCodecContext *video_enc_;

  //: Start time of the stream, to offset the pts when computing the frame number.
  //  (in stream time base)
  int64_t start_time_;

  //: The last successfully read frame.
  //
  // If frame_->data[0] is not NULL, then the frame corresponds to
  // the codec state, so that codec.width and so on apply to the
  // frame data.
  AVFrame* frame_;

  //: The last successfully read packet (before decoding).
  //  This must not be freed if the packet contains the raw image,
  //  in which case the frame_ will have only a shallow copy
  AVPacket* packet_;

  //: number of counted frames
  int num_frames_;

  //: A software scaling context
  //
  // This is the context used for the software scaling and colour
  // conversion routines. Since the conversion is likely to be the
  // same for each frame, we save the context to avoid re-creating it
  // every time.
  SwsContext* sws_context_;

  //: A contiguous memory buffer to store the current image data
  vil_memory_chunk_sptr contig_memory_;

  //: The last successfully decoded frame.
  mutable vidl_frame_sptr cur_frame_;

  //: the buffer of metadata from the data stream
  std::deque<vxl_byte> metadata_;

  //: Some codec/file format combinations need a frame number offset.
  // These codecs have a delay between reading packets and generating frames.
  unsigned frame_number_offset_;

  //: Presentation timestamp (in stream time base)
  int64_t pts_;

  //: Returns the double value to convert from a stream time base to
  //  a frame number
  double stream_time_base_to_frame()
    {
    assert(this->vid_str_);
    if(this->vid_str_->avg_frame_rate.num == 0.0)
    {
      return av_q2d(av_inv_q(av_mul_q(this->vid_str_->time_base,
                                      this->vid_str_->r_frame_rate)));
    }
    return av_q2d(
      av_inv_q(
        av_mul_q(this->vid_str_->time_base, this->vid_str_->avg_frame_rate)));
    }
};


//--------------------------------------------------------------------------------

//: Constructor
vidl_ffmpeg_istream::
vidl_ffmpeg_istream()
  : is_( new vidl_ffmpeg_istream::pimpl )
{
  vidl_ffmpeg_init();
}


//: Constructor - from a filename
vidl_ffmpeg_istream::
vidl_ffmpeg_istream(const std::string& filename)
  : is_( new vidl_ffmpeg_istream::pimpl )
{
  vidl_ffmpeg_init();
  open(filename);
}


//: Destructor
vidl_ffmpeg_istream::
~vidl_ffmpeg_istream()
{
  close();
  delete is_;
}

//: Open a new stream using a filename
bool
vidl_ffmpeg_istream::
open(const std::string& filename)
{
  // Close any currently opened file
  close();

  // Open the file
  int err;
  if ( ( err = avformat_open_input( &is_->fmt_cxt_, filename.c_str(), NULL, NULL ) ) != 0 ) {
    return false;
  }

  // Get the stream information by reading a bit of the file
  if ( avformat_find_stream_info( is_->fmt_cxt_, NULL ) < 0 ) {
    return false;
  }

  // Find a video stream, and optionally a data stream.
  // Use the first ones we find.
  is_->vid_index_ = -1;
  is_->data_index_ = -1;
  AVCodecParameters* codec_params = NULL;
  for (unsigned i = 0; i < is_->fmt_cxt_->nb_streams; ++i) {
    AVCodecParameters* const par = is_->fmt_cxt_->streams[i]->codecpar;
    if (par->codec_type == AVMEDIA_TYPE_VIDEO && is_->vid_index_ < 0) {
      is_->vid_index_ = i;
      codec_params = par;
    }
    else if (par->codec_type == AVMEDIA_TYPE_DATA && is_->data_index_ < 0) {
      is_->data_index_ = i;
    }
  }

  // Fallback for the DATA stream if incorrectly coded as UNKNOWN.
  for (unsigned i = 0; i < is_->fmt_cxt_->nb_streams && is_->data_index_ < 0; ++i) {
    AVCodecParameters* par = is_->fmt_cxt_->streams[i]->codecpar;
    if (par->codec_type == AVMEDIA_TYPE_UNKNOWN ) {
      is_->data_index_ = i;
    }
  }

  if (is_->vid_index_ == -1) {
    return false;
  }
  assert(codec_params);

  av_dump_format( is_->fmt_cxt_, 0, filename.c_str(), 0 );

  // Find decoder for the stream
  const AVCodec* codec = avcodec_find_decoder(codec_params->codec_id);
  if (!codec)
    return false;

  // Allocate codec context
  is_->video_enc_ = avcodec_alloc_context3(codec);
  if (!is_->video_enc_)
    return false;

  // Copy codec parameters to context
  if (avcodec_parameters_to_context(is_->video_enc_, codec_params) < 0)
    return false;

  // Open codec
  if (avcodec_open2(is_->video_enc_, codec, NULL) < 0)
    return false;

  is_->vid_str_ = is_->fmt_cxt_->streams[ is_->vid_index_ ];
  is_->frame_ = av_frame_alloc();

  if ( is_->vid_str_->start_time == int64_t(1)<<63 ) {
    is_->start_time_ = 0;
  }
  else {
    is_->start_time_ = is_->vid_str_->start_time;
  }

  // The MPEG 2 codec has a latency of 1 frame when encoded in an AVI
  // stream, so the pts of the last packet (stored in pts) is
  // actually the next frame's pts.
  if ( is_->video_enc_->codec_id == AV_CODEC_ID_MPEG2VIDEO &&
       std::string("avi") == is_->fmt_cxt_->iformat->name ) {
    is_->frame_number_offset_ = 1;
  }

  // Allocate packet
  is_->packet_ = av_packet_alloc();
  if (!is_->packet_)
    return false;

  return true;
}


//: Close the stream
void
vidl_ffmpeg_istream::
close()
{
  if (is_->packet_) {
    av_packet_free(&is_->packet_);
    is_->packet_ = NULL;
  }

  if (is_->frame_) {
    av_frame_free(&is_->frame_);
    is_->frame_ = NULL;
  }

  if (is_->video_enc_) {
    avcodec_free_context(&is_->video_enc_);
    is_->video_enc_ = NULL;
  }

  is_->num_frames_ = -2;
  is_->contig_memory_ = 0;
  is_->vid_index_ = -1;
  is_->data_index_ = -1;
  is_->metadata_.clear();
  is_->vid_str_ = NULL;

  if ( is_->fmt_cxt_ ) {
    avformat_close_input( &is_->fmt_cxt_ );
    is_->fmt_cxt_ = NULL;
  }
}


//: Return true if the stream is open for reading
bool
vidl_ffmpeg_istream::
is_open() const
{
  return ! ! is_->frame_;
}


//: Return true if the stream is in a valid state
bool
vidl_ffmpeg_istream::
is_valid() const
{
  return is_open() && is_->frame_->data[0] != 0;
}


//: Return true if the stream support seeking
bool
vidl_ffmpeg_istream::
is_seekable() const
{
  return true;
}


//: Return the number of frames if known
//  returns -1 for non-seekable streams
int
vidl_ffmpeg_istream::num_frames() const
{
  // to get an accurate frame count, quickly run through the entire
  // video.  We'll only do this if the user hasn't read any frames,
  // because we have no guarantee that we can successfully seek back
  // to anywhere but the beginning.  There is logic in advance() to
  // ensure this.
  vidl_ffmpeg_istream* mutable_this = const_cast<vidl_ffmpeg_istream*>(this);
  if ( mutable_this->is_->num_frames_ == -2 ) {
    mutable_this->is_->num_frames_ = 0;
    while (mutable_this->advance()) {
      ++mutable_this->is_->num_frames_;
    }
    av_seek_frame( mutable_this->is_->fmt_cxt_,
                   mutable_this->is_->vid_index_,
                   0,
                   AVSEEK_FLAG_BACKWARD );
  }

  return is_->num_frames_;
}


//: Return the current frame number
unsigned int
vidl_ffmpeg_istream::
frame_number() const
{
  // Quick return if the stream isn't open.
  if ( !is_valid() ) {
    return static_cast<unsigned int>(-1);
  }

  unsigned int frame_number = static_cast<unsigned int>(
    (is_->pts_ - is_->start_time_) / is_->stream_time_base_to_frame()
    - static_cast<int>(is_->frame_number_offset_));
  return frame_number;
}


//: Return the width of each frame
unsigned int
vidl_ffmpeg_istream
::width() const
{
  // Quick return if the stream isn't open.
  if ( !is_open() ) {
    return 0;
  }

  return is_->video_enc_->width;
}


//: Return the height of each frame
unsigned int
vidl_ffmpeg_istream
::height() const
{
  // Quick return if the stream isn't open.
  if ( !is_open() ) {
    return 0;
  }

  return is_->video_enc_->height;
}


//: Return the pixel format
vidl_pixel_format
vidl_ffmpeg_istream
::format() const
{
  // Quick return if the stream isn't open.
  if ( !is_open() ) {
    return VIDL_PIXEL_FORMAT_UNKNOWN;
  }

  vidl_pixel_format fmt = vidl_pixel_format_from_ffmpeg(is_->video_enc_->pix_fmt);
  if (fmt == VIDL_PIXEL_FORMAT_UNKNOWN)
    return VIDL_PIXEL_FORMAT_RGB_24;
  return fmt;
}


//: Return the frame rate (0.0 if unspecified)
double
vidl_ffmpeg_istream
::frame_rate() const
{
  // Quick return if the stream isn't open.
  if ( !is_open() ) {
    return 0.0;
  }

  AVRational frame_rate = is_->vid_str_->avg_frame_rate;
  return av_q2d(frame_rate);
}


//: Return the duration in seconds (0.0 if unknown)
double
vidl_ffmpeg_istream
::duration() const
{
  // Quick return if the stream isn't open.
  if ( !is_open() ) {
    return 0.0;
  }
  return av_q2d(is_->vid_str_->time_base)
    * static_cast<double>(is_->vid_str_->duration);
}


//: Advance to the next frame (but don't acquire an image)
bool
vidl_ffmpeg_istream::
advance()
{
  // Quick return if the file isn't open.
  if ( !is_open() ) {
    return false;
  }

  // See the comment in num_frames().  This is to make sure that once
  // we start reading frames, we'll never try to march to the end to
  // figure out how many frames there are.
  if ( is_->num_frames_ == -2 ) {
    is_->num_frames_ = -1;
  }

  int got_picture = 0;

  // clear the metadata from the previous frame
  is_->metadata_.clear();

  while (got_picture == 0 && av_read_frame(is_->fmt_cxt_, is_->packet_) >= 0)
  {
    // Make sure that the packet is from the actual video stream.
    if (is_->packet_->stream_index == is_->vid_index_)
    {
      // Send packet to decoder
      int ret = avcodec_send_packet(is_->video_enc_, is_->packet_);
      if (ret == AVERROR_INVALIDDATA) {
        // Ignore invalid data and move to the next packet
        av_packet_unref(is_->packet_);
        continue;
      }
      if (ret < 0 && ret != AVERROR(EAGAIN) && ret != AVERROR_EOF) {
        std::cerr << "vidl_ffmpeg_istream: Error sending packet for decoding!\n";
        av_packet_unref(is_->packet_);
        return false;
      }

      // Receive decoded frame
      ret = avcodec_receive_frame(is_->video_enc_, is_->frame_);
      if (ret == 0) {
        got_picture = 1;
        // Use best_effort_timestamp directly (av_frame_get_best_effort_timestamp deprecated)
        is_->pts_ = is_->frame_->best_effort_timestamp;
        if (is_->pts_ == AV_NOPTS_VALUE)
          is_->pts_ = 0;
      }
      else if (ret != AVERROR(EAGAIN) && ret != AVERROR_EOF) {
        std::cerr << "vidl_ffmpeg_istream: Error receiving frame!\n";
        av_packet_unref(is_->packet_);
        return false;
      }
    }
    // grab the metadata from this packet if from the metadata stream
    else if (is_->packet_->stream_index == is_->data_index_)
    {
      is_->metadata_.insert(is_->metadata_.end(), is_->packet_->data,
        is_->packet_->data + is_->packet_->size);
    }

    av_packet_unref(is_->packet_);
  }

  // From ffmpeg apiexample.c: some codecs, such as MPEG, transmit the
  // I and P frame with a latency of one frame. You must do the
  // following to have a chance to get the last frame of the video.
  if ( !got_picture ) {
    // Flush the decoder
    avcodec_send_packet(is_->video_enc_, NULL);
    int ret = avcodec_receive_frame(is_->video_enc_, is_->frame_);
    if (ret == 0) {
      got_picture = 1;
      is_->pts_ += static_cast<int64_t>(is_->stream_time_base_to_frame());
    }
  }

  // The cached frame is out of date, whether we managed to get a new
  // frame or not.
  if (is_->cur_frame_)
    is_->cur_frame_->invalidate();
  is_->cur_frame_ = 0;

  if ( ! got_picture ) {
    is_->frame_->data[0] = NULL;
  }

  return got_picture != 0;
}


//: Read the next frame from the stream
vidl_frame_sptr
vidl_ffmpeg_istream::read_frame()
{
  if (advance())
    return current_frame();
  return NULL;
}


//: Return the current frame in the stream
vidl_frame_sptr
vidl_ffmpeg_istream::current_frame()
{
  // Quick return if the stream isn't valid
  if ( !is_valid() ) {
    return NULL;
  }

  // If we have not already converted this frame, try to convert it
  if ( !is_->cur_frame_ && is_->frame_->data[0] != 0 )
  {
    int width = is_->video_enc_->width;
    int height = is_->video_enc_->height;

    // If the pixel format is not recognized by vidl then convert the data into RGB_24
    vidl_pixel_format fmt = vidl_pixel_format_from_ffmpeg(is_->video_enc_->pix_fmt);
    if (fmt == VIDL_PIXEL_FORMAT_UNKNOWN)
    {
      int size = width*height*3;
      if (!is_->contig_memory_)
        is_->contig_memory_ = new vil_memory_chunk(size, VIL_PIXEL_FORMAT_BYTE);
      else
        is_->contig_memory_->set_size(size, VIL_PIXEL_FORMAT_BYTE);

      // Reuse the previous context if we can.
      is_->sws_context_ = sws_getCachedContext(
        is_->sws_context_,
        width, height, is_->video_enc_->pix_fmt,
        width, height, AV_PIX_FMT_RGB24,
        SWS_BILINEAR,
        NULL, NULL, NULL );

      if ( is_->sws_context_ == NULL ) {
        std::cerr << "vidl_ffmpeg_istream: couldn't create conversion context\n";
        return vidl_frame_sptr();
      }

      uint8_t* rgb_data[4];
      int rgb_linesize[4];
      av_image_fill_arrays(rgb_data, rgb_linesize,
                           (uint8_t*)is_->contig_memory_->data(),
                           AV_PIX_FMT_RGB24, width, height, 1);

      sws_scale( is_->sws_context_,
                 is_->frame_->data, is_->frame_->linesize,
                 0, height,
                 rgb_data, rgb_linesize );

      is_->cur_frame_ = new vidl_shared_frame(is_->contig_memory_->data(),width,height,
                                              VIDL_PIXEL_FORMAT_RGB_24);
    }
    else
    {
      // Test for contiguous memory.  Sometimes FFMPEG uses scanline buffers larger
      // than the image width.  The extra memory is used in optimized decoding routines.
      // This leads to a segmented image buffer, not supported by vidl.
      uint8_t* test_data[4];
      int test_linesize[4];
      av_image_fill_arrays(test_data, test_linesize,
                           is_->frame_->data[0],
                           is_->video_enc_->pix_fmt, width, height, 1);

      if (test_data[1] == is_->frame_->data[1] &&
          test_data[2] == is_->frame_->data[2] &&
          test_linesize[0] == is_->frame_->linesize[0] &&
          test_linesize[1] == is_->frame_->linesize[1] &&
          test_linesize[2] == is_->frame_->linesize[2] )
      {
        is_->cur_frame_ = new vidl_shared_frame(is_->frame_->data[0], width, height, fmt);
      }
      // Copy the image into contiguous memory.
      else
      {
        if (!is_->contig_memory_) {
          int size = av_image_get_buffer_size(is_->video_enc_->pix_fmt, width, height, 1);
          is_->contig_memory_ = new vil_memory_chunk(size, VIL_PIXEL_FORMAT_BYTE);
        }
        av_image_fill_arrays(test_data, test_linesize,
                             (uint8_t*)is_->contig_memory_->data(),
                             is_->video_enc_->pix_fmt, width, height, 1);
        av_image_copy(test_data, test_linesize,
                      (const uint8_t**)is_->frame_->data, is_->frame_->linesize,
                      is_->video_enc_->pix_fmt, width, height);
        // use a shared frame because the vil_memory_chunk is reused for each frame
        is_->cur_frame_ = new vidl_shared_frame(is_->contig_memory_->data(), width, height, fmt);
      }
    }
  }

  return is_->cur_frame_;
}


//: Seek to the given frame number
// \returns true if successful
bool
vidl_ffmpeg_istream::
seek_frame(unsigned int frame)
{
  // Quick return if the stream isn't open.
  if ( !is_open() ) {
    return false;
  }

  // We rely on the initial cast to make sure all the operations happen in int64.
  int64_t req_timestamp =
    static_cast<int64_t>((frame + is_->frame_number_offset_)
    / is_->stream_time_base_to_frame())
    + is_->start_time_;

  // Seek to a keyframe before the timestamp that we want.
  int seek = av_seek_frame( is_->fmt_cxt_, is_->vid_index_, req_timestamp, AVSEEK_FLAG_BACKWARD );

  if ( seek < 0 )
    return false;

  // Flush buffers after seeking
  avcodec_flush_buffers(is_->video_enc_);

  // We got to a key frame. Forward until we get to the frame we want.
  while ( true )
  {
    if ( ! advance() ) {
      return false;
    }
    if (is_->pts_ >= req_timestamp) {
      if (is_->pts_ > req_timestamp) {
        std::cerr << "Warning: seek went into the future!\n";
        return false;
      }
      return true;
    }
  }
}


//: Return the raw metadata bytes obtained while reading the current frame.
//  This deque will be empty if there is no metadata stream
//  Metadata is often encoded as KLV,
//  but no attempt to decode KLV is made here
std::deque<vxl_byte>
vidl_ffmpeg_istream::
current_metadata()
{
  return is_->metadata_;
}


//: Return true if the video also has a metadata stream
bool
vidl_ffmpeg_istream::
has_metadata() const
{
  return is_open() && is_->data_index_ >= 0;
}

double
vidl_ffmpeg_istream::
current_pts() const
{
  return is_->pts_ * av_q2d(is_->vid_str_->time_base);
}

//: Return the current video packet's data, is used to get
//  video stream embeded metadata.
std::vector<vxl_byte>
vidl_ffmpeg_istream::
current_packet_data() const
{
  if (is_->packet_ && is_->packet_->data)
    return std::vector<vxl_byte>(is_->packet_->data, is_->packet_->data + is_->packet_->size);
  return std::vector<vxl_byte>();
}

#endif // vidl_ffmpeg_istream_v56_hxx_
