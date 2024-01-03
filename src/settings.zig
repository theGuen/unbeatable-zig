//Sequencer
pub var bpm: c_int = 85;
pub var minute: c_int = 60000000;
pub var ppq: c_int = 96;

//Sampler
pub const defaultProj: []u8 = @constCast("project1");

//Audio
pub const coreaudioDefaultDevice: []u8 = @constCast("Externe Kopfhörer");
pub const defaultDeviceIndex = 1;

//ui
pub const gamePadMapping: []u8 = @constCast("15000000010000000500000000010000,mkarcadejoystick GPIO Controller,platform:Linux,a:b1,b:b0,x:b3,y:b2,back:b7,start:b6,leftshoulder:b5,rightshoulder:b4,leftx:a0,lefty:a1,");
