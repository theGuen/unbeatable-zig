//-------------------------------------------------------------
//  Multieffect based on various examples
//  
//  echodelay
//  resonant lowpass
//  flanger_stereo
//  compressor (limiter)
//-------------------------------------------------------------
import("stdfaust.lib");
echo(d,f) = +~de.delay(44100,del)*f
with {
  del = d*ma.SR;
};
sw1=nentry("s1",1,0,1,1);
delay = nentry("delay",0.25,0,1,0.01) : si.smoo;
feedback = nentry("feedback",0.5,0,1,0.01) : si.smoo;

sw2=nentry("sw2",1,0,1,1);
Q = nentry("Q",1,1,1000,1) : si.smoo;
fc = nentry("frequency",20000,100,20000,100) : si.smoo;

sw3=nentry("sw3",1,0,1,1);
fl_del = nentry("fl_delay",10,0,1024,10) : si.smoo;
fl_depth = nentry("fl_depth",0,0,1,0.01) : si.smoo;
fl_fb = nentry("fl_fb",0.5,0,1,0.01) : si.smoo;

sw4=nentry("sw4",1,0,1,1);

process = 
    ba.bypass2(sw1,par(i,2,echo(delay,feedback))):
    ba.bypass2(sw2,par(i,2,fi.resonlp(fc,Q,1))):   
    ba.bypass2(sw3,pf.flanger_stereo(1024,fl_del,fl_del,fl_depth,fl_fb,0)):
    ba.bypass2(sw4,co.compressor_stereo(4,-6,0.0008,0.5));