#!/bin/bash
set -x 

BASEDIR="$(cd "`dirname $0`"; pwd)"

# Check programs
if [ -z "$(which ffmpeg)" ]; then
    echo "Error: ffmpeg is not installed"
    exit 1
fi

if [ -z "$(which MP4Box)" ]; then
    echo "Error: MP4Box is not installed"
    exit 1
fi

renderAudio() {
    filename="$1"
    bitrate="$2"
    if [ ! -f "${filename}_audio_${bitrate}.m4a" ]; then 
	ffmpeg -y -i "${inputfile}" -c:a aac -ac 2 -ab "${bitrate}k" -vn "${filename}_audio_${bitrate}.m4a"
    fi 
}

renderVideo() {
    filename="$1"
    bitrate="$2"
    height="$3"
    if [ ! -f "${filename}_${height}_${bitrate}.mp4" ]; then 
#	ffmpeg -y -i "${inputfile}" -an -c:v libx264 -x264opts 'keyint=25:min-keyint=25:no-scenecut' \
#            -movflags frag_keyframe+empty_moov -g 25 -b:v ${bitrate}k -vf "scale=-2:${height}" -f mp4 -pass 1 -y /dev/null
	ffmpeg -y -i "${inputfile}" -an -c:v libx264 -x264opts 'keyint=25:min-keyint=25:no-scenecut' \
	    -movflags frag_keyframe+empty_moov -g 25 -b:v ${bitrate}k -vf "scale=-2:${height}" -f mp4 "${filename}_${height}_${bitrate}.mp4"
    fi 

}
for mov in /opt/mp4/in/*.mov
do
        mp4="$(dirname "$mov")/$(basename "$mov" .mov).mp4"
        if [ ! -f "${mp4}" ]; then 
                ffmpeg -i $"{mov}" -map_metadata -1 -c:v copy -c:a copy  "${mp4}"
        fi
done

for inputfile in /opt/mp4/in/*.mp4
do
    fname=$(basename "${inputfile}") # fullname of the file
    fname="${fname%.*}" # name without extension

    echo "Converting \"${inputfile}\" to multi-bitrate video in MPEG-DASH"

    SAVEDIR="/opt/mp4/tmp"
    renderAudio "${SAVEDIR}/${fname}" 96
    renderAudio "${SAVEDIR}/${fname}" 48
    
    renderVideo "${SAVEDIR}/${fname}" 1500 540
    renderVideo "${SAVEDIR}/${fname}" 0500 540
    # renderVideo "${SAVEDIR}/${fname}" 0300 270
    renderVideo "${SAVEDIR}/${fname}" 0200 180

    ffmpeg -i "${SAVEDIR}/${fname}_540_0500.mp4" -i "${SAVEDIR}/${fname}_audio_96.m4a" \
           -acodec copy -vcodec copy \
           "/opt/mp4/out/${fname}_stream.mp4"
    MP4Box -inter 500 "/opt/mp4/out/${fname}_stream.mp4"

    MP4Box -dash 2000 -min-buffer 3000 -frag 2000 -rap -out "/opt/mp4/out/${fname}_mp4.mpd" \
	"${SAVEDIR}/${fname}_540_1500.mp4" \
	"${SAVEDIR}/${fname}_540_0500.mp4" \
	"${SAVEDIR}/${fname}_180_0200.mp4" \
	"${SAVEDIR}/${fname}_audio_96.m4a" \
	"${SAVEDIR}/${fname}_audio_48.m4a" 
#	"${SAVEDIR}/${fname}_360_0400.mp4" 
#	"${SAVEDIR}/${fname}_audio_32.m4a" 
#	"${SAVEDIR}/${fname}_270_0300.mp4" 


#    rm 	"${SAVEDIR}/${fname}_540_1500.mp4" "${SAVEDIR}/${fname}_540_0500.mp4" \
#	"${SAVEDIR}/${fname}_360_0400.mp4" "${SAVEDIR}/${fname}_270_0300.mp4" \
#	"${SAVEDIR}/${fname}_180_0200.mp4" \
#	"${SAVEDIR}/${fname}_audio_96.m4a" "${SAVEDIR}/${fname}_audio_48.m4a" "${SAVEDIR}/${fname}_audio_32.m4a" 


done

