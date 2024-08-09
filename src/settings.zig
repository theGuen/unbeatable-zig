//Sequencer
pub var bpm: c_int = 85;
pub const minute: c_int = 60000000;
pub const ppq: c_int = 96;

//Sampler
//pub const defaultProj: []u8 = @constCast("project1");
pub var currentProj: []u8 = @constCast("project1.asd");

pub const script_path = "./shutdown.sh";

//Audio
//pub const coreaudioDefaultDevice: []u8 = @constCast("Externe Kopfhörer");
pub const coreaudioDefaultDevice: []u8 = @constCast("USB Audio CODEC");
pub const alsaDefaultDevice: []u8 = @constCast("USB Audio CODEC, USB Audio");
pub const pulseDefaultDevice: []u8 = @constCast("PCM2902 Audio Codec Analog Stereo");

//ui
pub const gamePadMapping: []u8 = @constCast("15000000010000000500000000010000,mkarcadejoystick GPIO Controller,platform:Linux,a:b1,b:b0,x:b3,y:b2,back:b7,start:b6,leftshoulder:b5,rightshoulder:b4,leftx:a0,lefty:a1,");

// global exit
pub var exit = false;
