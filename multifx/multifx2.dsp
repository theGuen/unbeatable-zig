
import("stdfaust.lib");
echo(d,f) = +~de.delay(48000,del)*f
with {
  del = d*ma.SR;
};

pitchGroup(x) = vgroup("Pitch",x);
sw_transpose = pitchGroup(nentry("sw_pitch",1,0,1,1));
tr_semis = pitchGroup(nentry("pi_semis",0,-12,12,1));

echoGroup(x) = vgroup("Delay",x);
sw_echo=echoGroup(nentry("sw_echo",1,0,1,1));
ec_delay = echoGroup(nentry("delay",0.25,0,1,0.01) : si.smoo);
ec_feedback = echoGroup(nentry("feedback",0.5,0,1,0.01) : si.smoo);

lowpassGroup(x) = vgroup("LowPass",x);
sw_lowpass = lowpassGroup(nentry("sw_lowpass",1,0,1,1));
lp_Q = lowpassGroup(nentry("lp_Q",1,0,1000,1) : si.smoo);
lp_freq = lowpassGroup(nentry("lp_freq",20000,100,20000,100) : si.smoo);

highpassGroup(x) = vgroup("HighPass",x);
sw_highpass = highpassGroup(nentry("sw_highpass",1,0,1,1));
hp_Q = highpassGroup(nentry("hp_Q",1,0,1000,1) : si.smoo);
hp_freq = highpassGroup(nentry("hp_freq",20000,100,20000,100) : si.smoo);

flangerGroup(x) = vgroup("Flanger",x);
sw_flange= flangerGroup(nentry("sw_flange",1,0,1,1));
fl_del = flangerGroup(nentry("fl_delay",10,0,1024,10) : si.smoo);
fl_depth = flangerGroup(nentry("fl_depth",0,0,1,0.01) : si.smoo);
fl_fb = flangerGroup(nentry("fl_fb",0.5,0,1,0.01) : si.smoo);

phaserGroup(x) = vgroup("Phaser",x);
sw_phase= phaserGroup(nentry("sw_phase",1,0,1,1));
ph_depth = phaserGroup(nentry("ph_depth",0,0,2,1) : si.smoo);
ph_speed= phaserGroup(nentry("ph_speed",0.5,0,120,1) : si.smoo);
ph_ratio= phaserGroup(nentry("ph_ratio",0.5,0,1,0.1) : si.smoo);

DriveGroup(x) = vgroup("Distortion",x);
sw_drive = DriveGroup(nentry("sw_drive",1,0,1,1));
dr_drive = DriveGroup(nentry("dr_drive",0, 0, 1, 0.01) : si.smoo);
dr_offset = DriveGroup(nentry("dr_offset",0, 0, 1, 0.01) : si.smoo);

CompGroup(x) = vgroup("Compressor",x);
sw_comp=CompGroup(nentry("sw_comp",1,0,1,1));

process = 
    ba.bypass2(sw_transpose,par(i,2,ef.transpose(512,512,tr_semis))):
    ba.bypass2(sw_lowpass,par(i,2,fi.resonlp(lp_freq,lp_Q,1))):
    ba.bypass2(sw_highpass,par(i,2,fi.resonhp(hp_freq,hp_Q,1))):   
    ba.bypass2(sw_flange,pf.flanger_stereo(1024,fl_del,fl_del,fl_depth,fl_fb,0)): 
    ba.bypass2(sw_phase,pf.phaser2_stereo(12,100,500,ph_ratio,2000,ph_speed,ph_depth,0,0)):
    ba.bypass2(sw_echo,par(i,2,echo(ec_delay,ec_feedback))):  
    ba.bypass2(sw_drive,par(i,2,ef.cubicnl_nodc(dr_drive,dr_offset))):
    ba.bypass2(sw_comp,co.compressor_stereo(4,-6,0.0008,0.5));


