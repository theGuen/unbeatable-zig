# My first zig project
Hopefully it will become a drum machine

zig is version 0.9.0 (asdf)

Dependencies installed with brew:
* libsundio (not used right now)
* libsndfile (not used right now)
* raylib

miniaudio copy of the split version included in ./miniaudio
* link: https://github.com/mackron/miniaudio

faust copy of the CInterface.h included in ./multifx
* link: https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/CInterface.h

For Faust Effects compile with c

e.g. 
```
>faust multifx2.dsp -lang c > multifx2.h
```

then make the folllowing changes to multifx2.h
 ```
 #include "CInterface.h"
 ```
 
 and patch the computemydsp function... i should write a wrapper for this...

```
-- void computemydsp(mydsp* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
++ // count is the number of samples not frames    
++ void computemydsp(mydsp* dsp, int countFrames, FAUSTFLOAT* inputs, FAUSTFLOAT* outputs) {    
       --  FAUSTFLOAT* input0 = inputs[0];
       -- FAUSTFLOAT* input1 = inputs[1];
       -- FAUSTFLOAT* output0 = outputs[0];
       -- FAUSTFLOAT* output1 = outputs[1];
        ...
        /* C99 loop */
        {
                int i0;
                -- for (i0 = 0; (i0 < count); i0 = (i0 + 1)) {
                ++ for (i0 = 0; (i0 < count); i0 = (i0 + 2)) {    
                    -- float fTemp2 = (float)input0[i0];
                    ++ float fTemp2 = (float)inputs[i0];
                    -- float fTemp79 = (float)input1[i0];
                    ++ float fTemp79 = (float)inputs[i0+1];
                    -- output0[i0] = (FAUSTFLOAT)(iSlow0 ? fTemp77 : fThen31);
                    ++ outputs[i0] = (FAUSTFLOAT)(iSlow0 ? fTemp77 : fThen31);
                    -- output1[i0] = (FAUSTFLOAT)(iSlow0 ? fTemp106 : fThen32);
                    ++ outputs[i0+1] = (FAUSTFLOAT)(iSlow0 ? fTemp106 : fThen32);
                    ...
```

The buildUserInterfacemydsp should build a simple cursor menu. KEY_ENTER to enter KEY_BACKSPACE to leave ...

For now only a few items are supported and NO nested Boxes!
 - HorizontalBox
 - CheckButton
 - NumEntry

 TODO: the state of the multifx has to be added to the projectfile and saved on exit... yeah handling projects is also open

The Sampler Menu has 
 - reverse
 - loop
 - gate
 - mutegroup
 - pitch (shitty)
 - start
 - end
 - gain (linear)
 - lazystart (hit up while playing sets the new start NOW. Hit down to reset)
 - lazyend (hit up while playing sets the new end NOW. Hit down to reset)
 - move (up/down moves the start and end point by end-start)
 - copy (hit up to select a src... hit a pad to select dest... hit up to copy. Down is back)

which are affecting the last triggered sample

The Recorder Menu has only one item...
select a destination pad and start recording.
 - Hit up for lock in a destination pad. 
 - Hit up again for start recording.
 - Hit down for stop recording.
 - Recording will loaded on the destination pad
 - You can still use the old pad while recording...

for now you can load samples on startup

```
>zig-out/bin/unbeatable-zig testdata/drum.wav ...
```
A Project Folder will be created "Project1". 

If you close the window a project file and all loaded samples with settings will be saved.

On the next run load without additional arguments, and your project will be loaded
```
>zig-out/bin/unbeatable-zig
```
If you don't want to overwrite the Project use CTRL-C...

Shitty Workflow... but ok for testing purposes

I am confident that zig won't let me down... So maybe it's time to commit to this project...

I am dreaming about getting this on a hardwarebox with 16 Buttons, two encoders and an oled

powered by a raspberry pi zero2 and a hifiberry dac+ zero

Today i made my first little lofi beat.
 - 8 prechopped melodic samples 
 - 4 drumsounds
 - resampled the hihat with some silence at the end
 - trimmed the length of that hat to make 1/8 metronome while looping
 - recorded a 4 bar drum loop on that metronome
 - recorded 2 Parts over that drumloop
 - resampled the two parts while using pitch and phaser from the multifx (faust effects are really nice :) )
 - added some reverse tricks and filtersweeps while recording

 Since the samples were prechopped... Sample chopping is the next thing to implement
 
 Sample chopping is done...
 Now we handle left/right seperate. TODO:unpatch faust fx
