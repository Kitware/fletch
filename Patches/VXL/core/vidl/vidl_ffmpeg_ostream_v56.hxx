// This is core/vidl/vidl_ffmpeg_ostream_v56.hxx
#ifndef vidl_ffmpeg_ostream_v56_hxx_
#define vidl_ffmpeg_ostream_v56_hxx_
#pragma once

#include <cstring>
#include "vidl_ffmpeg_ostream.h"
//:
// \file
// \author Johan Andruejol
// \author Gehua Yang
// \author Matt Leotta
// \author Amitha Perera
// \author David Law
// \date   6 April 2015
//
// Update implementation based on FFMPEG release version 2.8.4
// Updated for FFmpeg 5.x compatibility
//
//-----------------------------------------------------------------------------

#include "vidl_ffmpeg_init.h"
#include "vidl_ffmpeg_convert.h"
#include "vidl_ffmpeg_pixel_format.h"
#include "vidl_frame.h"
#include "vidl_convert.h"
#include <vcl_compiler.h>
#include <vcl_climits.h>
#include <vil/vil_memory_chunk.h>

extern "C" {
#if FFMPEG_IN_SEVERAL_DIRECTORIES
#include <libavformat/avformat.h>
#include <libavutil/imgutils.h>
#include <libavutil/opt.h>
#else
#include <ffmpeg/avformat.h>
#include <ffmpeg/opt.h>
#endif
}

//-----------------------------------------------------------------------------


struct vidl_ffmpeg_ostream::pimpl
{
  pimpl()
  : fmt_cxt_( NULL ),
  video_enc_( NULL ),
  file_opened_( false ),
  codec_opened_( false ),
  cur_frame_( 0 )
  { }

  AVFormatContext* fmt_cxt_;
  AVCodecContext* video_enc_;
  bool file_opened_;
  bool codec_opened_;
  unsigned int cur_frame_;
};


//-----------------------------------------------------------------------------


//: Constructor
vidl_ffmpeg_ostream::
vidl_ffmpeg_ostream()
  : os_( new vidl_ffmpeg_ostream::pimpl )
{
  vidl_ffmpeg_init();
}


//: Destructor
vidl_ffmpeg_ostream::
~vidl_ffmpeg_ostream()
{
  close();
  delete os_;
}


//: Constructor - opens a stream
vidl_ffmpeg_ostream::
vidl_ffmpeg_ostream(const std::string& filename,
                    const vidl_ffmpeg_ostream_params& params)
  : os_( new vidl_ffmpeg_ostream::pimpl ),
    filename_(filename), params_(params)
{
  vidl_ffmpeg_init();
}


//: Open the stream
bool
vidl_ffmpeg_ostream::
open()
{
  // Close any open files
  close();

  os_->fmt_cxt_ = avformat_alloc_context();

  const AVOutputFormat* file_oformat = NULL;
  if ( params_.file_format_ == vidl_ffmpeg_ostream_params::GUESS ) {
    file_oformat = av_guess_format(NULL, filename_.c_str(), NULL);
    if (!file_oformat) {
      std::cerr << "ffmpeg: Unable for find a suitable output format for "
               << filename_ << '\n';
      close();
      return false;
    }
  }
  else {
    close();
    return false;
  }

  os_->fmt_cxt_->oformat = file_oformat;
  os_->fmt_cxt_->nb_streams = 0;

  // Create stream
  AVStream* st = avformat_new_stream( os_->fmt_cxt_, NULL );
  if ( !st ) {
    std::cerr << "ffmpeg: could not alloc stream\n";
    close();
    return false;
  }

  // Determine codec ID
  AVCodecID codec_id;
  switch ( params_.encoder_ )
  {
   case vidl_ffmpeg_ostream_params::DEFAULT:
    codec_id = file_oformat->video_codec;
    break;
   case vidl_ffmpeg_ostream_params::MPEG4:
    codec_id = AV_CODEC_ID_MPEG4;
    break;
   case vidl_ffmpeg_ostream_params::MPEG2VIDEO:
    codec_id = AV_CODEC_ID_MPEG2VIDEO;
    break;
   case vidl_ffmpeg_ostream_params::MSMPEG4V2:
    codec_id = AV_CODEC_ID_MSMPEG4V2;
    break;
   case vidl_ffmpeg_ostream_params::RAWVIDEO:
    codec_id = AV_CODEC_ID_RAWVIDEO;
    break;
   case vidl_ffmpeg_ostream_params::LJPEG:
    codec_id = AV_CODEC_ID_LJPEG;
    break;
   case vidl_ffmpeg_ostream_params::HUFFYUV:
    codec_id = AV_CODEC_ID_HUFFYUV;
    break;
   case vidl_ffmpeg_ostream_params::DVVIDEO:
    codec_id = AV_CODEC_ID_DVVIDEO;
    break;
   default:
    std::cout << "ffmpeg: Unknown encoder type\n";
    return false;
  }

  // Find encoder
  const AVCodec* codec = avcodec_find_encoder(codec_id);
  if ( !codec )
  {
    std::cerr << "ffmpeg_writer:: couldn't find encoder for " << codec_id << '\n';
    return false;
  }

  // Allocate codec context
  os_->video_enc_ = avcodec_alloc_context3(codec);
  if (!os_->video_enc_) {
    std::cerr << "ffmpeg: couldn't allocate codec context\n";
    close();
    return false;
  }

  AVCodecContext *video_enc = os_->video_enc_;

  // Set codec parameters
  video_enc->codec_id = codec_id;
  video_enc->codec_type = AVMEDIA_TYPE_VIDEO;

  if (std::strcmp(file_oformat->name, "mp4") != 0 ||
      std::strcmp(file_oformat->name, "mov") != 0 ||
      std::strcmp(file_oformat->name, "3gp") != 0 )
    video_enc->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;

  video_enc->bit_rate = params_.bit_rate_ * 1000;
  video_enc->time_base.num = 1000;
  video_enc->time_base.den = int(params_.frame_rate_*1000);

  if ( codec && codec->supported_framerates )
  {
    AVRational const* p = codec->supported_framerates;
    AVRational req = { video_enc->time_base.den, video_enc->time_base.num };
    AVRational const* best = NULL;
    AVRational best_error = { INT_MAX, 1 };
    for (; p->den!=0; p++)
    {
      AVRational error = av_sub_q(req, *p);
      if ( error.num < 0 )   error.num *= -1;
      if ( av_cmp_q( error, best_error ) < 0 )
      {
        best_error= error;
        best= p;
      }
    }
    video_enc->time_base.den= best->num;
    video_enc->time_base.num= best->den;
  }

  video_enc->width  = params_.ni_;
  video_enc->height = params_.nj_;
  video_enc->sample_aspect_ratio = av_d2q(params_.frame_aspect_ratio_*params_.ni_/params_.nj_, 255);

  // Our source is packed RGB. Use that if possible.
  video_enc->pix_fmt = AV_PIX_FMT_RGB24;
  if ( codec && codec->pix_fmts )
  {
    const enum AVPixelFormat* p= codec->pix_fmts;
    for ( ; *p != -1; p++ )
    {
      if ( *p == video_enc->pix_fmt )
        break;
    }
    if ( *p == -1 )
      video_enc->pix_fmt = codec->pix_fmts[0];
  }
  else if ( codec && ( codec->id == AV_CODEC_ID_RAWVIDEO ||
                      codec->id == AV_CODEC_ID_HUFFYUV ) )
  {
    // these formats only support the YUV input image formats
    video_enc->pix_fmt = AV_PIX_FMT_YUV420P;
  }

  if (!params_.intra_only_)
    video_enc->gop_size = params_.gop_size_;
  else
    video_enc->gop_size = 0;

  if (params_.video_qscale_ || params_.same_quality_)
  {
    video_enc->flags |= AV_CODEC_FLAG_QSCALE;
    video_enc->global_quality = FF_QP2LAMBDA * params_.video_qscale_;
  }

  video_enc->mb_decision = params_.mb_decision_;

  if (params_.use_4mv_)
  {
    video_enc->flags |= AV_CODEC_FLAG_4MV;
  }
  if (params_.use_loop_)
  {
    video_enc->flags |= AV_CODEC_FLAG_LOOP_FILTER;
  }
  if (params_.closed_gop_)
  {
    video_enc->flags |= AV_CODEC_FLAG_CLOSED_GOP;
  }
  if (params_.use_qpel_)
  {
    video_enc->flags |= AV_CODEC_FLAG_QPEL;
  }
  if (params_.b_frames_)
  {
    video_enc->max_b_frames = params_.b_frames_;
    video_enc->b_quant_factor = 2.0;
  }
  if (params_.do_interlace_dct_)
  {
    video_enc->flags |= AV_CODEC_FLAG_INTERLACED_DCT;
  }
  if (params_.do_interlace_me_)
  {
    video_enc->flags |= AV_CODEC_FLAG_INTERLACED_ME;
  }

  video_enc->qmin = params_.video_qmin_;
  video_enc->qmax = params_.video_qmax_;
  video_enc->max_qdiff = params_.video_qdiff_;
  video_enc->qblur = params_.video_qblur_;
  video_enc->qcompress = params_.video_qcomp_;
  video_enc->thread_count = 1;
  video_enc->rc_max_rate = params_.video_rc_max_rate_;
  video_enc->rc_min_rate = params_.video_rc_min_rate_;
  video_enc->i_quant_factor = params_.video_i_qfactor_;
  video_enc->b_quant_factor = params_.video_b_qfactor_;
  video_enc->i_quant_offset = params_.video_i_qoffset_;
  video_enc->b_quant_offset = params_.video_b_qoffset_;
  video_enc->dct_algo = params_.dct_algo_;
  video_enc->idct_algo = params_.idct_algo_;
  video_enc->strict_std_compliance = params_.strict_;
  video_enc->me_range = params_.me_range_;

  if (params_.do_psnr_)
    video_enc->flags |= AV_CODEC_FLAG_PSNR;

  // two pass mode
  if (params_.do_pass_)
  {
    if (params_.do_pass_ == 1)
    {
      video_enc->flags |= AV_CODEC_FLAG_PASS1;
    }
    else
    {
      video_enc->flags |= AV_CODEC_FLAG_PASS2;
    }
  }

  // Copy parameters to stream
  avcodec_parameters_from_context(st->codecpar, video_enc);

  // Set stream time base
  st->time_base = video_enc->time_base;

  // Open the output file
  if ( avio_open( &os_->fmt_cxt_->pb, filename_.c_str(), AVIO_FLAG_WRITE ) < 0 )
  {
    std::cerr << "ffmpeg: couldn't open " << filename_ << " for writing\n";
    close();
    return false;
  }
  os_->file_opened_ = true;

  // Open the codec
  if ( avcodec_open2( video_enc, codec, NULL ) < 0 )
  {
    std::cerr << "ffmpeg: couldn't open codec\n";
    close();
    return false;
  }
  os_->codec_opened_ = true;

  if ( avformat_write_header( os_->fmt_cxt_, NULL ) < 0 )
  {
    std::cerr << "ffmpeg: couldn't write header\n";
    close();
    return false;
  }

  return true;
}


//: Close the stream
void
vidl_ffmpeg_ostream::
close()
{
  if ( os_->fmt_cxt_ ) {

    // flush out remaining packets using the new API
    if (os_->video_enc_ && os_->codec_opened_) {
      // Send flush signal
      avcodec_send_frame(os_->video_enc_, NULL);

      // Receive any remaining packets
      AVPacket* pkt = av_packet_alloc();
      while (avcodec_receive_packet(os_->video_enc_, pkt) == 0) {
        pkt->stream_index = 0;
        av_interleaved_write_frame(os_->fmt_cxt_, pkt);
        av_packet_unref(pkt);
      }
      av_packet_free(&pkt);
    }

    if ( os_->file_opened_ ) {
      av_write_trailer( os_->fmt_cxt_ );
      avio_close( os_->fmt_cxt_->pb );
      os_->file_opened_ = false;
    }

    if ( os_->codec_opened_ && os_->video_enc_ ) {
      avcodec_free_context(&os_->video_enc_);
      os_->video_enc_ = NULL;
    }
    os_->codec_opened_ = false;

    avformat_free_context(os_->fmt_cxt_);
    os_->fmt_cxt_ = NULL;
  }
}


//: Return true if the stream is open for writing
bool
vidl_ffmpeg_ostream::
is_open() const
{
  return os_->file_opened_;
}


//: Write and image to the stream
// \retval false if the image could not be written
bool
vidl_ffmpeg_ostream::
write_frame(const vidl_frame_sptr& frame)
{
  if (!is_open()) {
    // resize to the first frame
    params_.size(frame->ni(),frame->nj());
    open();
  }

  AVCodecContext* codec = os_->video_enc_;
  if (!codec) {
    std::cerr << "ffmpeg: codec not initialized\n";
    return false;
  }

  if (unsigned( codec->width ) != frame->ni() ||
      unsigned( codec->height) != frame->nj() ) {
    std::cerr << "ffmpeg: Input image has wrong size. Expecting ("
             << codec->width << 'x' << codec->height << "), got ("
             << frame->ni() << 'x' << frame->nj() << ")\n";
    return false;
  }

  AVPixelFormat fmt = vidl_pixel_format_to_ffmpeg(frame->pixel_format());

  vidl_pixel_format target_fmt = vidl_pixel_format_from_ffmpeg(codec->pix_fmt);
  static vidl_frame_sptr temp_frame = new vidl_shared_frame(NULL,frame->ni(),frame->nj(),target_fmt);

  AVFrame* out_frame = av_frame_alloc();

  // The frame is in the correct format to encode directly
  if ( codec->pix_fmt == fmt )
  {
    av_image_fill_arrays(out_frame->data, out_frame->linesize,
                         (uint8_t*) frame->data(),
                         fmt, frame->ni(), frame->nj(), 1);
  }
  else
  {
    if (!temp_frame->data()) {
      unsigned ni = frame->ni();
      unsigned nj = frame->nj();
      unsigned out_size = vidl_pixel_format_buffer_size(ni,nj,target_fmt);
      temp_frame = new vidl_memory_chunk_frame(ni, nj, target_fmt,
                                               new vil_memory_chunk(out_size, VIL_PIXEL_FORMAT_BYTE));
    }
    // try conversion with FFMPEG functions
    if (!vidl_ffmpeg_convert(frame, temp_frame)) {
      // try conversion with vidl functions
      if (!vidl_convert_frame(*frame, *temp_frame)) {
        std::cout << "unable to convert " << frame->pixel_format() << " to "<<target_fmt<<std::endl;
        av_frame_free(&out_frame);
        return false;
      }
    }
    av_image_fill_arrays(out_frame->data, out_frame->linesize,
                         (uint8_t*) temp_frame->data(),
                         codec->pix_fmt, frame->ni(), frame->nj(), 1);
  }

  out_frame->pts = os_->cur_frame_;
  out_frame->width = codec->width;
  out_frame->height = codec->height;
  out_frame->format = codec->pix_fmt;

  // Send frame to encoder
  int ret = avcodec_send_frame(codec, out_frame);
  if (ret < 0) {
    std::cerr << "FFMPEG video encoding failed (send_frame)" << std::endl;
    av_frame_free(&out_frame);
    return false;
  }

  // Receive encoded packets
  AVPacket* pkt = av_packet_alloc();
  while (ret >= 0) {
    ret = avcodec_receive_packet(codec, pkt);
    if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
      break;
    }
    else if (ret < 0) {
      std::cerr << "FFMPEG video encoding failed (receive_packet)" << std::endl;
      av_packet_free(&pkt);
      av_frame_free(&out_frame);
      return false;
    }

    pkt->stream_index = 0;
    av_interleaved_write_frame(os_->fmt_cxt_, pkt);
    av_packet_unref(pkt);
  }
  av_packet_free(&pkt);
  av_frame_free(&out_frame);

  ++os_->cur_frame_;
  return true;
}

#endif // vidl_ffmpeg_ostream_v56_hxx_
