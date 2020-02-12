FROM debian:latest
RUN apt-get update && apt-get install -y gpac ffmpeg
RUN mkdir -p /opt/mp4/in /opt/mp4/out /opt/mp4/tmp
WORKDIR /opt/mp4/
COPY mp4-to-dash.sh /opt/mp4/
RUN chmod 755 /opt/mp4/mp4-to-dash.sh
CMD /opt/mp4/mp4-to-dash.sh