FROM alpine:edge AS build

ARG ffmpeg_version="4.4.1"

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk add --update \
  build-base \
  coreutils \
  fdk-aac-dev \
  freetype-dev \
  gcc \
  lame-dev \
  libogg-dev \
  libass \
  libass-dev \
  libvpx-dev \
  libvorbis-dev \
  libwebp-dev \
  libtheora-dev \
  openssl-dev \
  opus-dev \
  pkgconf \
  pkgconfig \
  rtmpdump-dev \
  wget \
  x264-dev \
  x265-dev \
  yasm

RUN mkdir /usr/local/src && \
  cd /usr/local/src && \
  wget https://ffmpeg.org/releases/ffmpeg-${ffmpeg_version}.tar.gz && \
  tar zxf ffmpeg-${ffmpeg_version}.tar.gz

RUN cd /usr/local/src/ffmpeg-${ffmpeg_version} && \
  ./configure \
  --enable-version3 \
  --enable-gpl \
  --enable-nonfree \
  --enable-small \
  --enable-libmp3lame \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libopus \
  --enable-libfdk-aac \
  --enable-libass \
  --enable-libwebp \
  --enable-librtmp \
  --enable-postproc \
  --enable-avresample \
  --enable-libfreetype \
  --enable-openssl \
  --enable-shared \
  --disable-debug \
  --disable-doc \
  --disable-ffplay \
  --extra-libs="-lpthread -lm" &&  \
  make && make install && make distclean

FROM alpine:edge

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk add --update \
  ca-certificates \
  fdk-aac \
  openssl \
  pcre \
  lame \
  libogg \
  libass \
  libvpx \
  libvorbis \
  libwebp \
  libtheora \
  opus \
  rtmpdump \
  x264-dev \
  x265-dev && \
  rm -rf /var/cache/apk/*

COPY --from=build /usr/local/bin/* /usr/local/bin/
COPY --from=build /usr/local/share/ffmpeg /usr/local/share/ffmpeg
COPY --from=build /usr/local/lib/lib* /usr/local/lib/
COPY --from=build /usr/local/lib/pkgconfig/* /usr/local/lib/pkgconfig/
COPY --from=build /usr/local/include/libavcodec /usr/local/include/libavcodec
COPY --from=build /usr/local/include/libavdevice /usr/local/include/libavdevice
COPY --from=build /usr/local/include/libavfilter /usr/local/include/libavfilter
COPY --from=build /usr/local/include/libavformat /usr/local/include/libavformat
COPY --from=build /usr/local/include/libavresample /usr/local/include/libavresample
COPY --from=build /usr/local/include/libavutil /usr/local/include/libavutil
COPY --from=build /usr/local/include/libpostproc /usr/local/include/libpostproc
COPY --from=build /usr/local/include/libswresample /usr/local/include/libswresample
COPY --from=build /usr/local/include/libswscale /usr/local/include/libswscale

CMD ["/usr/local/bin/ffmpeg"]