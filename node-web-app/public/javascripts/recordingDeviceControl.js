// create Agora client
var client = AgoraRTC.createClient({ mode: "rtc", codec: "vp8" });
var localTracks = {
  videoTrack: null,
  audioTrack: null
};

var mics = []; // all microphones devices you can use
var cams = []; // all cameras devices you can use
var currentMic; // the microphone you are using
var currentCam; // the camera you are using

let volumeAnimation;

// the demo can auto join channel with params in url
$(async () => {
  document.getElementById("deviceSettings").onclick = async () => {
    await mediaDeviceTest();
  };
  document.getElementById('uidInput').value = Math.floor((Math.random() * 1000) + 1);
  //$('#uidInput').val(Math.floor((Math.random() * 1000) + 1));
  $("#media-device-test").modal("show");
  $(".cam-list").delegate("a", "click", function(e) {
    switchCamera(this.text);
  });
  $(".mic-list").delegate("a", "click", function(e) {
    switchMicrophone(this.text);
  });
  await mediaDeviceTest();
  volumeAnimation = requestAnimationFrame(setVolumeWave);
})

$("#media-device-test").on("hidden.bs.modal", function(e) {
  cancelAnimationFrame(volumeAnimation);
})

async function mediaDeviceTest() {
  // create local tracks
  [localTracks.audioTrack, localTracks.videoTrack] = await Promise.all([
    // create local tracks, using microphone and camera
    AgoraRTC.createMicrophoneAudioTrack(),
    AgoraRTC.createCameraVideoTrack()
  ]);

  // play local track on device detect dialog
  localTracks.videoTrack.play("pre-local-player");
  // localTracks.audioTrack.play();

  // get mics
  mics = await AgoraRTC.getMicrophones();
  currentMic = mics[0];
  $(".mic-input").val(currentMic.label);
  mics.forEach(mic => {
    $(".mic-list").append(`<a class="dropdown-item" href="#">${mic.label}</a>`);
  });

  // get cameras
  cams = await AgoraRTC.getCameras();
  currentCam = cams[0];
  $(".cam-input").val(currentCam.label);
  cams.forEach(cam => {
    $(".cam-list").append(`<a class="dropdown-item" href="#">${cam.label}</a>`);
  });
}

async function switchCamera(label) {
  currentCam = cams.find(cam => cam.label === label);
  $(".cam-input").val(currentCam.label);
  // switch device of local video track.
  await localTracks.videoTrack.setDevice(currentCam.deviceId);
}

async function switchMicrophone(label) {
  currentMic = mics.find(mic => mic.label === label);
  $(".mic-input").val(currentMic.label);
  // switch device of local audio track.
  await localTracks.audioTrack.setDevice(currentMic.deviceId);
}

// show real-time volume while adjusting device. 
function setVolumeWave() {
  volumeAnimation = requestAnimationFrame(setVolumeWave);
  $(".progress-bar").css("width", localTracks.audioTrack.getVolumeLevel() * 100 + "%")
  $(".progress-bar").attr("aria-valuenow", localTracks.audioTrack.getVolumeLevel() * 100)
}