# Dockerized MP4-Dash Generator

Converts movies in the source-folder `in/` to DASH-Videos (including manifest) in the folder `out/`.


## Start

```
docker-compose run mp4-to-dash
```

After successful conversion, a set of files is created for each input movie:

* `${Title}_stream.mp4`: 540 Pixel high video with 1.5 Mbps average bandwith, with 96 kbps audio
* `${Title}_540_1500.mp4`: 540 Pixel high video with 1.5 Mbps average bandwith, without audio
* `${Title}_540_0500.mp4`: 540 Pixel high video with 0.5 Mbps average bandwith, without audio
* `${Title}_180_0200.mp4`: 180 Pixel high video with 0.2 Mbps average bandwith, without audio
* `${Title}_audio_96.m4a`: 96 kbps Audio Track
* `${Title}_audio_48.m4a`: 48 kbps Audio Track

If you need different resolutions/bandwidths, feel free to edit `mp4-to-dash.sh`.

## Usage in HTML

For playing within HTML, [`dash.js`](https://github.com/Dash-Industry-Forum/dash.js/wiki) can be used:


*Initialization of dash player only after click on the image:*

```
<script src="jquery.js"></script>
<script src="dash.js"></script>
<script>
window.dashjs = {skipAutoCreate: true};
$(document).ready(function () {
    $(".video-trigger").click(
        function () {
            var videoId = $(this).data("video-id");
            $(this).hide();
            var video = $("#" + videoId);
            video.show();
            if (window.MediaSource) {
                var player = dashjs.MediaPlayer().create();
                video.remove("source");
                player.initialize(video[0], video.data("src"), true);
            } else {
                video.find("source").attr("src", video.data("compat-src"));
                video[0].play();
            }
        }
    )
});
</script>
<style>
.video-trigger { position: relative; }
.play-button {  
    color: rgba(0, 0, 0, 0.5);
    position: absolute; top: 50%; left: 50%;    
    transform: translate(-50%, -50%); 
}
</style>
```

Corresponding HTML-Code:

```
<div data-video-id="video-1" class="video-trigger">
  <img src="${Poster}.jpg" width="960" height="540" />
  <i class="fa fa-5x fa-play play-button"></i>
</div>
<video data-dashjs-player id="video-1"
   width="960" height="540"
   controls="controls"
   preload="auto"
   data-src="${Title}_mp4.mpd"
   data-compat-src="${Title}_stream.mp4" >
    <source />
</video>
```



