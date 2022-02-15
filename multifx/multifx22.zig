pub const struct_Soundfile = opaque {};
pub const openTabBoxFun = ?fn (?*anyopaque, [*c]const u8) callconv(.C) void;
pub const openHorizontalBoxFun = ?fn (?*anyopaque, [*c]const u8) callconv(.C) void;
pub const openVerticalBoxFun = ?fn (?*anyopaque, [*c]const u8) callconv(.C) void;
pub const closeBoxFun = ?fn (?*anyopaque) callconv(.C) void;
pub const addButtonFun = ?fn (?*anyopaque, [*c]const u8, [*c]f32) callconv(.C) void;
pub const addCheckButtonFun = ?fn (?*anyopaque, [*c]const u8, [*c]f32) callconv(.C) void;
pub const addVerticalSliderFun = ?fn (?*anyopaque, [*c]const u8, [*c]f32, f32, f32, f32, f32) callconv(.C) void;
pub const addHorizontalSliderFun = ?fn (?*anyopaque, [*c]const u8, [*c]f32, f32, f32, f32, f32) callconv(.C) void;
pub const addNumEntryFun = ?fn (?*anyopaque, [*c]const u8, [*c]f32, f32, f32, f32, f32) callconv(.C) void;
pub const addHorizontalBargraphFun = ?fn (?*anyopaque, [*c]const u8, [*c]f32, f32, f32) callconv(.C) void;
pub const addVerticalBargraphFun = ?fn (?*anyopaque, [*c]const u8, [*c]f32, f32, f32) callconv(.C) void;
pub const addSoundfileFun = ?fn (?*anyopaque, [*c]const u8, [*c]const u8, [*c]?*struct_Soundfile) callconv(.C) void;
pub const declareFun = ?fn (?*anyopaque, [*c]f32, [*c]const u8, [*c]const u8) callconv(.C) void;
pub const UIGlue = extern struct {
    uiInterface: ?*anyopaque,
    openHorizontalBox: openHorizontalBoxFun,
    openVerticalBox: openVerticalBoxFun,
    closeBox: closeBoxFun,
    addCheckButton: addCheckButtonFun,
    addNumEntry: addNumEntryFun,
};
pub const metaDeclareFun = ?fn (?*anyopaque, [*c]const u8, [*c]const u8) callconv(.C) void;
pub const MetaGlue = extern struct {
    metaInterface: ?*anyopaque,
    declare: metaDeclareFun,
};
pub const dsp_imp = u8;
pub const newDspFun = ?fn (...) callconv(.C) [*c]dsp_imp;
pub const destroyDspFun = ?fn ([*c]dsp_imp) callconv(.C) void;
pub const getNumInputsFun = ?fn ([*c]dsp_imp) callconv(.C) c_int;
pub const getNumOutputsFun = ?fn ([*c]dsp_imp) callconv(.C) c_int;
pub const buildUserInterfaceFun = ?fn ([*c]dsp_imp, [*c]UIGlue) callconv(.C) void;
pub const getSampleRateFun = ?fn ([*c]dsp_imp) callconv(.C) c_int;
pub const initFun = ?fn ([*c]dsp_imp, c_int) callconv(.C) void;
pub const classInitFun = ?fn (c_int) callconv(.C) void;
pub const instanceInitFun = ?fn ([*c]dsp_imp, c_int) callconv(.C) void;
pub const instanceConstantsFun = ?fn ([*c]dsp_imp, c_int) callconv(.C) void;
pub const instanceResetUserInterfaceFun = ?fn ([*c]dsp_imp) callconv(.C) void;
pub const instanceClearFun = ?fn ([*c]dsp_imp) callconv(.C) void;
pub const computeFun = ?fn ([*c]dsp_imp, c_int, [*c][*c]f32, [*c][*c]f32) callconv(.C) void;
pub const metadataFun = ?fn ([*c]MetaGlue) callconv(.C) void;
pub const allocateFun = ?fn (?*anyopaque, usize) callconv(.C) ?*anyopaque;
pub const destroyFun = ?fn (?*anyopaque, ?*anyopaque) callconv(.C) void;
pub const MemoryManagerGlue = extern struct {
    managerInterface: ?*anyopaque,
    allocate: allocateFun,
    destroy: destroyFun,
};
pub fn mydsp_faustpower2_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return value * value;
}
pub fn mydsp_faustpower3_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return (value * value) * value;
}
pub fn mydsp_faustpower4_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return ((value * value) * value) * value;
}
pub fn mydsp_faustpower5_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return (((value * value) * value) * value) * value;
}
pub fn mydsp_faustpower6_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return ((((value * value) * value) * value) * value) * value;
}
pub fn mydsp_faustpower7_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return (((((value * value) * value) * value) * value) * value) * value;
}
pub fn mydsp_faustpower8_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return ((((((value * value) * value) * value) * value) * value) * value) * value;
}
pub fn mydsp_faustpower9_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return (((((((value * value) * value) * value) * value) * value) * value) * value) * value;
}
pub fn mydsp_faustpower10_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return ((((((((value * value) * value) * value) * value) * value) * value) * value) * value) * value;
}
pub fn mydsp_faustpower11_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return (((((((((value * value) * value) * value) * value) * value) * value) * value) * value) * value) * value;
}
pub fn mydsp_faustpower12_f(arg_value: f32) callconv(.C) f32 {
    var value = arg_value;
    return ((((((((((value * value) * value) * value) * value) * value) * value) * value) * value) * value) * value) * value;
}
pub const mydsp = extern struct {
    fEntry0: f32,
    fEntry1: f32,
    iVec0: [2]c_int,
    fSampleRate: c_int,
    fConst0: f32,
    fConst1: f32,
    fEntry2: f32,
    fConst2: f32,
    fRec1: [2]f32,
    fEntry3: f32,
    fRec2: [2]f32,
    fEntry4: f32,
    fEntry5: f32,
    fRec4: [2]f32,
    fEntry6: f32,
    fRec5: [2]f32,
    fEntry7: f32,
    fEntry8: f32,
    fEntry9: f32,
    fEntry10: f32,
    fEntry11: f32,
    IOTA: c_int,
    fVec1: [131072]f32,
    fEntry12: f32,
    fRec7: [2]f32,
    fConst3: f32,
    fEntry13: f32,
    fRec8: [2]f32,
    fEntry14: f32,
    fRec9: [2]f32,
    fRec6: [3]f32,
    fEntry15: f32,
    fRec11: [2]f32,
    fEntry16: f32,
    fRec12: [2]f32,
    fRec10: [3]f32,
    fEntry17: f32,
    fRec14: [2]f32,
    fVec2: [2048]f32,
    fEntry18: f32,
    fRec15: [2]f32,
    fRec13: [2]f32,
    fEntry19: f32,
    fRec16: [2]f32,
    fEntry20: f32,
    fRec17: [2]f32,
    fConst5: f32,
    fConst6: f32,
    fConst7: f32,
    fEntry21: f32,
    fRec31: [2]f32,
    fConst8: f32,
    fEntry22: f32,
    fRec34: [2]f32,
    fRec32: [2]f32,
    fRec33: [2]f32,
    fRec30: [3]f32,
    fRec29: [3]f32,
    fRec28: [3]f32,
    fRec27: [3]f32,
    fRec26: [3]f32,
    fRec25: [3]f32,
    fRec24: [3]f32,
    fRec23: [3]f32,
    fRec22: [3]f32,
    fRec21: [3]f32,
    fRec20: [3]f32,
    fRec19: [3]f32,
    fRec3: [65536]f32,
    fVec3: [2]f32,
    fRec0: [2]f32,
    fConst9: f32,
    fConst10: f32,
    fVec4: [131072]f32,
    fRec40: [3]f32,
    fRec41: [3]f32,
    fVec5: [2048]f32,
    fRec42: [2]f32,
    fRec55: [3]f32,
    fRec54: [3]f32,
    fRec53: [3]f32,
    fRec52: [3]f32,
    fRec51: [3]f32,
    fRec50: [3]f32,
    fRec49: [3]f32,
    fRec48: [3]f32,
    fRec47: [3]f32,
    fRec46: [3]f32,
    fRec45: [3]f32,
    fRec44: [3]f32,
    fRec39: [65536]f32,
    fVec6: [2]f32,
    fRec38: [2]f32,
    fConst11: f32,
    fConst12: f32,
    fRec37: [2]f32,
    fRec36: [2]f32,
    fRec35: [2]f32,
};
pub export fn newmydsp() [*c]mydsp {
    var dsp: [*c]mydsp = @ptrCast([*c]mydsp, @alignCast(@import("std").meta.alignment(mydsp), calloc(@bitCast(c_ulong, @as(c_long, @as(c_int, 1))), @sizeOf(mydsp))));
    return dsp;
}
pub export fn deletemydsp(arg_dsp: [*c]mydsp) void {
    var dsp = arg_dsp;
    free(@ptrCast(?*anyopaque, dsp));
}
pub export fn metadatamydsp(arg_m: [*c]MetaGlue) void {
    var m = arg_m;
    m.*.declare.?(m.*.metaInterface, "analyzers.lib/name", "Faust Analyzer Library");
    m.*.declare.?(m.*.metaInterface, "analyzers.lib/version", "0.1");
    m.*.declare.?(m.*.metaInterface, "basics.lib/name", "Faust Basic Element Library");
    m.*.declare.?(m.*.metaInterface, "basics.lib/version", "0.2");
    m.*.declare.?(m.*.metaInterface, "compile_options", "-lang c -es 1 -single -ftz 0");
    m.*.declare.?(m.*.metaInterface, "compressors.lib/compression_gain_mono:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "compressors.lib/compression_gain_mono:copyright", "Copyright (C) 2014-2020 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "compressors.lib/compression_gain_mono:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "compressors.lib/compressor_stereo:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "compressors.lib/compressor_stereo:copyright", "Copyright (C) 2014-2020 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "compressors.lib/compressor_stereo:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "compressors.lib/name", "Faust Compressor Effect Library");
    m.*.declare.?(m.*.metaInterface, "compressors.lib/version", "0.1");
    m.*.declare.?(m.*.metaInterface, "delays.lib/name", "Faust Delay Library");
    m.*.declare.?(m.*.metaInterface, "delays.lib/version", "0.1");
    m.*.declare.?(m.*.metaInterface, "filename", "multifx2.dsp");
    m.*.declare.?(m.*.metaInterface, "filters.lib/dcblocker:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "filters.lib/dcblocker:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/dcblocker:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "filters.lib/fir:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "filters.lib/fir:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/fir:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "filters.lib/iir:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "filters.lib/iir:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/iir:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "filters.lib/lowpass0_highpass1", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/name", "Faust Filters Library");
    m.*.declare.?(m.*.metaInterface, "filters.lib/nlf2:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "filters.lib/nlf2:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/nlf2:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "filters.lib/pole:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "filters.lib/pole:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/pole:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "filters.lib/resonhp:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "filters.lib/resonhp:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/resonhp:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "filters.lib/resonlp:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "filters.lib/resonlp:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/resonlp:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "filters.lib/tf2:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "filters.lib/tf2:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/tf2:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "filters.lib/tf2s:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "filters.lib/tf2s:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/tf2s:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "filters.lib/version", "0.3");
    m.*.declare.?(m.*.metaInterface, "filters.lib/zero:author", "Julius O. Smith III");
    m.*.declare.?(m.*.metaInterface, "filters.lib/zero:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
    m.*.declare.?(m.*.metaInterface, "filters.lib/zero:license", "MIT-style STK-4.3 license");
    m.*.declare.?(m.*.metaInterface, "maths.lib/author", "GRAME");
    m.*.declare.?(m.*.metaInterface, "maths.lib/copyright", "GRAME");
    m.*.declare.?(m.*.metaInterface, "maths.lib/license", "LGPL with exception");
    m.*.declare.?(m.*.metaInterface, "maths.lib/name", "Faust Math Library");
    m.*.declare.?(m.*.metaInterface, "maths.lib/version", "2.5");
    m.*.declare.?(m.*.metaInterface, "misceffects.lib/name", "Misc Effects Library");
    m.*.declare.?(m.*.metaInterface, "misceffects.lib/version", "2.0");
    m.*.declare.?(m.*.metaInterface, "name", "multifx2");
    m.*.declare.?(m.*.metaInterface, "oscillators.lib/name", "Faust Oscillator Library");
    m.*.declare.?(m.*.metaInterface, "oscillators.lib/version", "0.1");
    m.*.declare.?(m.*.metaInterface, "phaflangers.lib/name", "Faust Phaser and Flanger Library");
    m.*.declare.?(m.*.metaInterface, "phaflangers.lib/version", "0.1");
    m.*.declare.?(m.*.metaInterface, "platform.lib/name", "Generic Platform Library");
    m.*.declare.?(m.*.metaInterface, "platform.lib/version", "0.2");
    m.*.declare.?(m.*.metaInterface, "routes.lib/name", "Faust Signal Routing Library");
    m.*.declare.?(m.*.metaInterface, "routes.lib/version", "0.2");
    m.*.declare.?(m.*.metaInterface, "signals.lib/name", "Faust Signal Routing Library");
    m.*.declare.?(m.*.metaInterface, "signals.lib/version", "0.1");
}
pub export fn getSampleRatemydsp(arg_dsp: [*c]mydsp) c_int {
    var dsp = arg_dsp;
    return dsp.*.fSampleRate;
}
pub export fn getNumInputsmydsp(arg_dsp: [*c]mydsp) c_int {
    var dsp = arg_dsp;
    _ = dsp;
    return 2;
}
pub export fn getNumOutputsmydsp(arg_dsp: [*c]mydsp) c_int {
    var dsp = arg_dsp;
    _ = dsp;
    return 2;
}
pub export fn classInitmydsp(arg_sample_rate: c_int) void {
    var sample_rate = arg_sample_rate;
    _ = sample_rate;
}
pub export fn instanceResetUserInterfacemydsp(arg_dsp: [*c]mydsp) void {
    var dsp = arg_dsp;
    dsp.*.fEntry0 = 1.0;
    dsp.*.fEntry1 = 1.0;
    dsp.*.fEntry2 = 0.0;
    dsp.*.fEntry3 = 0.0;
    dsp.*.fEntry4 = 1.0;
    dsp.*.fEntry5 = 0.5;
    dsp.*.fEntry6 = 0.25;
    dsp.*.fEntry7 = 1.0;
    dsp.*.fEntry8 = 1.0;
    dsp.*.fEntry9 = 1.0;
    dsp.*.fEntry10 = 1.0;
    dsp.*.fEntry11 = 1.0;
    dsp.*.fEntry12 = 0.0;
    dsp.*.fEntry13 = 20000.0;
    dsp.*.fEntry14 = 1.0;
    dsp.*.fEntry15 = 20000.0;
    dsp.*.fEntry16 = 1.0;
    dsp.*.fEntry17 = 0.5;
    dsp.*.fEntry18 = 10.0;
    dsp.*.fEntry19 = 0.0;
    dsp.*.fEntry20 = 0.0;
    dsp.*.fEntry21 = 0.5;
    dsp.*.fEntry22 = 0.5;
}
pub export fn instanceClearmydsp(arg_dsp: [*c]mydsp) void {
    var dsp = arg_dsp;
    {
        var l0: c_int = undefined;
        {
            l0 = 0;
            while (l0 < @as(c_int, 2)) : (l0 = l0 + @as(c_int, 1)) {
                dsp.*.iVec0[@intCast(c_uint, l0)] = 0;
            }
        }
    }
    {
        var l1: c_int = undefined;
        {
            l1 = 0;
            while (l1 < @as(c_int, 2)) : (l1 = l1 + @as(c_int, 1)) {
                dsp.*.fRec1[@intCast(c_uint, l1)] = 0.0;
            }
        }
    }
    {
        var l2: c_int = undefined;
        {
            l2 = 0;
            while (l2 < @as(c_int, 2)) : (l2 = l2 + @as(c_int, 1)) {
                dsp.*.fRec2[@intCast(c_uint, l2)] = 0.0;
            }
        }
    }
    {
        var l3: c_int = undefined;
        {
            l3 = 0;
            while (l3 < @as(c_int, 2)) : (l3 = l3 + @as(c_int, 1)) {
                dsp.*.fRec4[@intCast(c_uint, l3)] = 0.0;
            }
        }
    }
    {
        var l4: c_int = undefined;
        {
            l4 = 0;
            while (l4 < @as(c_int, 2)) : (l4 = l4 + @as(c_int, 1)) {
                dsp.*.fRec5[@intCast(c_uint, l4)] = 0.0;
            }
        }
    }
    dsp.*.IOTA = 0;
    {
        var l5: c_int = undefined;
        {
            l5 = 0;
            while (l5 < @as(c_int, 131072)) : (l5 = l5 + @as(c_int, 1)) {
                dsp.*.fVec1[@intCast(c_uint, l5)] = 0.0;
            }
        }
    }
    {
        var l6: c_int = undefined;
        {
            l6 = 0;
            while (l6 < @as(c_int, 2)) : (l6 = l6 + @as(c_int, 1)) {
                dsp.*.fRec7[@intCast(c_uint, l6)] = 0.0;
            }
        }
    }
    {
        var l7: c_int = undefined;
        {
            l7 = 0;
            while (l7 < @as(c_int, 2)) : (l7 = l7 + @as(c_int, 1)) {
                dsp.*.fRec8[@intCast(c_uint, l7)] = 0.0;
            }
        }
    }
    {
        var l8: c_int = undefined;
        {
            l8 = 0;
            while (l8 < @as(c_int, 2)) : (l8 = l8 + @as(c_int, 1)) {
                dsp.*.fRec9[@intCast(c_uint, l8)] = 0.0;
            }
        }
    }
    {
        var l9: c_int = undefined;
        {
            l9 = 0;
            while (l9 < @as(c_int, 3)) : (l9 = l9 + @as(c_int, 1)) {
                dsp.*.fRec6[@intCast(c_uint, l9)] = 0.0;
            }
        }
    }
    {
        var l10: c_int = undefined;
        {
            l10 = 0;
            while (l10 < @as(c_int, 2)) : (l10 = l10 + @as(c_int, 1)) {
                dsp.*.fRec11[@intCast(c_uint, l10)] = 0.0;
            }
        }
    }
    {
        var l11: c_int = undefined;
        {
            l11 = 0;
            while (l11 < @as(c_int, 2)) : (l11 = l11 + @as(c_int, 1)) {
                dsp.*.fRec12[@intCast(c_uint, l11)] = 0.0;
            }
        }
    }
    {
        var l12: c_int = undefined;
        {
            l12 = 0;
            while (l12 < @as(c_int, 3)) : (l12 = l12 + @as(c_int, 1)) {
                dsp.*.fRec10[@intCast(c_uint, l12)] = 0.0;
            }
        }
    }
    {
        var l13: c_int = undefined;
        {
            l13 = 0;
            while (l13 < @as(c_int, 2)) : (l13 = l13 + @as(c_int, 1)) {
                dsp.*.fRec14[@intCast(c_uint, l13)] = 0.0;
            }
        }
    }
    {
        var l14: c_int = undefined;
        {
            l14 = 0;
            while (l14 < @as(c_int, 2048)) : (l14 = l14 + @as(c_int, 1)) {
                dsp.*.fVec2[@intCast(c_uint, l14)] = 0.0;
            }
        }
    }
    {
        var l15: c_int = undefined;
        {
            l15 = 0;
            while (l15 < @as(c_int, 2)) : (l15 = l15 + @as(c_int, 1)) {
                dsp.*.fRec15[@intCast(c_uint, l15)] = 0.0;
            }
        }
    }
    {
        var l16: c_int = undefined;
        {
            l16 = 0;
            while (l16 < @as(c_int, 2)) : (l16 = l16 + @as(c_int, 1)) {
                dsp.*.fRec13[@intCast(c_uint, l16)] = 0.0;
            }
        }
    }
    {
        var l17: c_int = undefined;
        {
            l17 = 0;
            while (l17 < @as(c_int, 2)) : (l17 = l17 + @as(c_int, 1)) {
                dsp.*.fRec16[@intCast(c_uint, l17)] = 0.0;
            }
        }
    }
    {
        var l18: c_int = undefined;
        {
            l18 = 0;
            while (l18 < @as(c_int, 2)) : (l18 = l18 + @as(c_int, 1)) {
                dsp.*.fRec17[@intCast(c_uint, l18)] = 0.0;
            }
        }
    }
    {
        var l19: c_int = undefined;
        {
            l19 = 0;
            while (l19 < @as(c_int, 2)) : (l19 = l19 + @as(c_int, 1)) {
                dsp.*.fRec31[@intCast(c_uint, l19)] = 0.0;
            }
        }
    }
    {
        var l20: c_int = undefined;
        {
            l20 = 0;
            while (l20 < @as(c_int, 2)) : (l20 = l20 + @as(c_int, 1)) {
                dsp.*.fRec34[@intCast(c_uint, l20)] = 0.0;
            }
        }
    }
    {
        var l21: c_int = undefined;
        {
            l21 = 0;
            while (l21 < @as(c_int, 2)) : (l21 = l21 + @as(c_int, 1)) {
                dsp.*.fRec32[@intCast(c_uint, l21)] = 0.0;
            }
        }
    }
    {
        var l22: c_int = undefined;
        {
            l22 = 0;
            while (l22 < @as(c_int, 2)) : (l22 = l22 + @as(c_int, 1)) {
                dsp.*.fRec33[@intCast(c_uint, l22)] = 0.0;
            }
        }
    }
    {
        var l23: c_int = undefined;
        {
            l23 = 0;
            while (l23 < @as(c_int, 3)) : (l23 = l23 + @as(c_int, 1)) {
                dsp.*.fRec30[@intCast(c_uint, l23)] = 0.0;
            }
        }
    }
    {
        var l24: c_int = undefined;
        {
            l24 = 0;
            while (l24 < @as(c_int, 3)) : (l24 = l24 + @as(c_int, 1)) {
                dsp.*.fRec29[@intCast(c_uint, l24)] = 0.0;
            }
        }
    }
    {
        var l25: c_int = undefined;
        {
            l25 = 0;
            while (l25 < @as(c_int, 3)) : (l25 = l25 + @as(c_int, 1)) {
                dsp.*.fRec28[@intCast(c_uint, l25)] = 0.0;
            }
        }
    }
    {
        var l26: c_int = undefined;
        {
            l26 = 0;
            while (l26 < @as(c_int, 3)) : (l26 = l26 + @as(c_int, 1)) {
                dsp.*.fRec27[@intCast(c_uint, l26)] = 0.0;
            }
        }
    }
    {
        var l27: c_int = undefined;
        {
            l27 = 0;
            while (l27 < @as(c_int, 3)) : (l27 = l27 + @as(c_int, 1)) {
                dsp.*.fRec26[@intCast(c_uint, l27)] = 0.0;
            }
        }
    }
    {
        var l28: c_int = undefined;
        {
            l28 = 0;
            while (l28 < @as(c_int, 3)) : (l28 = l28 + @as(c_int, 1)) {
                dsp.*.fRec25[@intCast(c_uint, l28)] = 0.0;
            }
        }
    }
    {
        var l29: c_int = undefined;
        {
            l29 = 0;
            while (l29 < @as(c_int, 3)) : (l29 = l29 + @as(c_int, 1)) {
                dsp.*.fRec24[@intCast(c_uint, l29)] = 0.0;
            }
        }
    }
    {
        var l30: c_int = undefined;
        {
            l30 = 0;
            while (l30 < @as(c_int, 3)) : (l30 = l30 + @as(c_int, 1)) {
                dsp.*.fRec23[@intCast(c_uint, l30)] = 0.0;
            }
        }
    }
    {
        var l31: c_int = undefined;
        {
            l31 = 0;
            while (l31 < @as(c_int, 3)) : (l31 = l31 + @as(c_int, 1)) {
                dsp.*.fRec22[@intCast(c_uint, l31)] = 0.0;
            }
        }
    }
    {
        var l32: c_int = undefined;
        {
            l32 = 0;
            while (l32 < @as(c_int, 3)) : (l32 = l32 + @as(c_int, 1)) {
                dsp.*.fRec21[@intCast(c_uint, l32)] = 0.0;
            }
        }
    }
    {
        var l33: c_int = undefined;
        {
            l33 = 0;
            while (l33 < @as(c_int, 3)) : (l33 = l33 + @as(c_int, 1)) {
                dsp.*.fRec20[@intCast(c_uint, l33)] = 0.0;
            }
        }
    }
    {
        var l34: c_int = undefined;
        {
            l34 = 0;
            while (l34 < @as(c_int, 3)) : (l34 = l34 + @as(c_int, 1)) {
                dsp.*.fRec19[@intCast(c_uint, l34)] = 0.0;
            }
        }
    }
    {
        var l35: c_int = undefined;
        {
            l35 = 0;
            while (l35 < @as(c_int, 65536)) : (l35 = l35 + @as(c_int, 1)) {
                dsp.*.fRec3[@intCast(c_uint, l35)] = 0.0;
            }
        }
    }
    {
        var l36: c_int = undefined;
        {
            l36 = 0;
            while (l36 < @as(c_int, 2)) : (l36 = l36 + @as(c_int, 1)) {
                dsp.*.fVec3[@intCast(c_uint, l36)] = 0.0;
            }
        }
    }
    {
        var l37: c_int = undefined;
        {
            l37 = 0;
            while (l37 < @as(c_int, 2)) : (l37 = l37 + @as(c_int, 1)) {
                dsp.*.fRec0[@intCast(c_uint, l37)] = 0.0;
            }
        }
    }
    {
        var l38: c_int = undefined;
        {
            l38 = 0;
            while (l38 < @as(c_int, 131072)) : (l38 = l38 + @as(c_int, 1)) {
                dsp.*.fVec4[@intCast(c_uint, l38)] = 0.0;
            }
        }
    }
    {
        var l39: c_int = undefined;
        {
            l39 = 0;
            while (l39 < @as(c_int, 3)) : (l39 = l39 + @as(c_int, 1)) {
                dsp.*.fRec40[@intCast(c_uint, l39)] = 0.0;
            }
        }
    }
    {
        var l40: c_int = undefined;
        {
            l40 = 0;
            while (l40 < @as(c_int, 3)) : (l40 = l40 + @as(c_int, 1)) {
                dsp.*.fRec41[@intCast(c_uint, l40)] = 0.0;
            }
        }
    }
    {
        var l41: c_int = undefined;
        {
            l41 = 0;
            while (l41 < @as(c_int, 2048)) : (l41 = l41 + @as(c_int, 1)) {
                dsp.*.fVec5[@intCast(c_uint, l41)] = 0.0;
            }
        }
    }
    {
        var l42: c_int = undefined;
        {
            l42 = 0;
            while (l42 < @as(c_int, 2)) : (l42 = l42 + @as(c_int, 1)) {
                dsp.*.fRec42[@intCast(c_uint, l42)] = 0.0;
            }
        }
    }
    {
        var l43: c_int = undefined;
        {
            l43 = 0;
            while (l43 < @as(c_int, 3)) : (l43 = l43 + @as(c_int, 1)) {
                dsp.*.fRec55[@intCast(c_uint, l43)] = 0.0;
            }
        }
    }
    {
        var l44: c_int = undefined;
        {
            l44 = 0;
            while (l44 < @as(c_int, 3)) : (l44 = l44 + @as(c_int, 1)) {
                dsp.*.fRec54[@intCast(c_uint, l44)] = 0.0;
            }
        }
    }
    {
        var l45: c_int = undefined;
        {
            l45 = 0;
            while (l45 < @as(c_int, 3)) : (l45 = l45 + @as(c_int, 1)) {
                dsp.*.fRec53[@intCast(c_uint, l45)] = 0.0;
            }
        }
    }
    {
        var l46: c_int = undefined;
        {
            l46 = 0;
            while (l46 < @as(c_int, 3)) : (l46 = l46 + @as(c_int, 1)) {
                dsp.*.fRec52[@intCast(c_uint, l46)] = 0.0;
            }
        }
    }
    {
        var l47: c_int = undefined;
        {
            l47 = 0;
            while (l47 < @as(c_int, 3)) : (l47 = l47 + @as(c_int, 1)) {
                dsp.*.fRec51[@intCast(c_uint, l47)] = 0.0;
            }
        }
    }
    {
        var l48: c_int = undefined;
        {
            l48 = 0;
            while (l48 < @as(c_int, 3)) : (l48 = l48 + @as(c_int, 1)) {
                dsp.*.fRec50[@intCast(c_uint, l48)] = 0.0;
            }
        }
    }
    {
        var l49: c_int = undefined;
        {
            l49 = 0;
            while (l49 < @as(c_int, 3)) : (l49 = l49 + @as(c_int, 1)) {
                dsp.*.fRec49[@intCast(c_uint, l49)] = 0.0;
            }
        }
    }
    {
        var l50: c_int = undefined;
        {
            l50 = 0;
            while (l50 < @as(c_int, 3)) : (l50 = l50 + @as(c_int, 1)) {
                dsp.*.fRec48[@intCast(c_uint, l50)] = 0.0;
            }
        }
    }
    {
        var l51: c_int = undefined;
        {
            l51 = 0;
            while (l51 < @as(c_int, 3)) : (l51 = l51 + @as(c_int, 1)) {
                dsp.*.fRec47[@intCast(c_uint, l51)] = 0.0;
            }
        }
    }
    {
        var l52: c_int = undefined;
        {
            l52 = 0;
            while (l52 < @as(c_int, 3)) : (l52 = l52 + @as(c_int, 1)) {
                dsp.*.fRec46[@intCast(c_uint, l52)] = 0.0;
            }
        }
    }
    {
        var l53: c_int = undefined;
        {
            l53 = 0;
            while (l53 < @as(c_int, 3)) : (l53 = l53 + @as(c_int, 1)) {
                dsp.*.fRec45[@intCast(c_uint, l53)] = 0.0;
            }
        }
    }
    {
        var l54: c_int = undefined;
        {
            l54 = 0;
            while (l54 < @as(c_int, 3)) : (l54 = l54 + @as(c_int, 1)) {
                dsp.*.fRec44[@intCast(c_uint, l54)] = 0.0;
            }
        }
    }
    {
        var l55: c_int = undefined;
        {
            l55 = 0;
            while (l55 < @as(c_int, 65536)) : (l55 = l55 + @as(c_int, 1)) {
                dsp.*.fRec39[@intCast(c_uint, l55)] = 0.0;
            }
        }
    }
    {
        var l56: c_int = undefined;
        {
            l56 = 0;
            while (l56 < @as(c_int, 2)) : (l56 = l56 + @as(c_int, 1)) {
                dsp.*.fVec6[@intCast(c_uint, l56)] = 0.0;
            }
        }
    }
    {
        var l57: c_int = undefined;
        {
            l57 = 0;
            while (l57 < @as(c_int, 2)) : (l57 = l57 + @as(c_int, 1)) {
                dsp.*.fRec38[@intCast(c_uint, l57)] = 0.0;
            }
        }
    }
    {
        var l58: c_int = undefined;
        {
            l58 = 0;
            while (l58 < @as(c_int, 2)) : (l58 = l58 + @as(c_int, 1)) {
                dsp.*.fRec37[@intCast(c_uint, l58)] = 0.0;
            }
        }
    }
    {
        var l59: c_int = undefined;
        {
            l59 = 0;
            while (l59 < @as(c_int, 2)) : (l59 = l59 + @as(c_int, 1)) {
                dsp.*.fRec36[@intCast(c_uint, l59)] = 0.0;
            }
        }
    }
    {
        var l60: c_int = undefined;
        {
            l60 = 0;
            while (l60 < @as(c_int, 2)) : (l60 = l60 + @as(c_int, 1)) {
                dsp.*.fRec35[@intCast(c_uint, l60)] = 0.0;
            }
        }
    }
}
pub export fn instanceConstantsmydsp(arg_dsp: [*c]mydsp, arg_sample_rate: c_int) void {
    var dsp = arg_dsp;
    var sample_rate = arg_sample_rate;
    dsp.*.fSampleRate = sample_rate;
    dsp.*.fConst0 = fminf(192000.0, fmaxf(1.0, @intToFloat(f32, dsp.*.fSampleRate)));
    dsp.*.fConst1 = 44.099998474121094 / dsp.*.fConst0;
    dsp.*.fConst2 = 1.0 - dsp.*.fConst1;
    dsp.*.fConst3 = 3.1415927410125732 / dsp.*.fConst0;
    var fConst4: f32 = expf(0.0 - (314.1592712402344 / dsp.*.fConst0));
    dsp.*.fConst5 = mydsp_faustpower2_f(fConst4);
    dsp.*.fConst6 = 0.0 - (2.0 * fConst4);
    dsp.*.fConst7 = 1.0 / dsp.*.fConst0;
    dsp.*.fConst8 = 6.2831854820251465 / dsp.*.fConst0;
    dsp.*.fConst9 = expf(0.0 - (2500.0 / dsp.*.fConst0));
    dsp.*.fConst10 = 1.0 - dsp.*.fConst9;
    dsp.*.fConst11 = expf(0.0 - (1250.0 / dsp.*.fConst0));
    dsp.*.fConst12 = expf(0.0 - (2.0 / dsp.*.fConst0));
}
pub export fn instanceInitmydsp(arg_dsp: [*c]mydsp, arg_sample_rate: c_int) void {
    var dsp = arg_dsp;
    var sample_rate = arg_sample_rate;
    instanceConstantsmydsp(dsp, sample_rate);
    instanceResetUserInterfacemydsp(dsp);
    instanceClearmydsp(dsp);
}
pub export fn initmydsp(arg_dsp: [*c]mydsp, arg_sample_rate: c_int) void {
    var dsp = arg_dsp;
    var sample_rate = arg_sample_rate;
    classInitmydsp(sample_rate);
    instanceInitmydsp(dsp, sample_rate);
}
pub export fn buildUserInterfacemydsp(arg_dsp: [*c]mydsp, arg_ui_interface: [*c]UIGlue) void {
    var dsp = arg_dsp;
    var ui_interface = arg_ui_interface;
    ui_interface.*.openVerticalBox.?(ui_interface.*.uiInterface, "multifx2");
    ui_interface.*.openVerticalBox.?(ui_interface.*.uiInterface, "Compressor");
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "sw_comp", &dsp.*.fEntry0, 1.0, 0.0, 1.0, 1.0);
    ui_interface.*.closeBox.?(ui_interface.*.uiInterface);
    ui_interface.*.openVerticalBox.?(ui_interface.*.uiInterface, "Delay");
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "delay", &dsp.*.fEntry6, 0.25, 0.0, 1.0, 0.009999999776482582);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "feedback", &dsp.*.fEntry5, 0.5, 0.0, 1.0, 0.009999999776482582);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "sw_echo", &dsp.*.fEntry4, 1.0, 0.0, 1.0, 1.0);
    ui_interface.*.closeBox.?(ui_interface.*.uiInterface);
    ui_interface.*.openVerticalBox.?(ui_interface.*.uiInterface, "Distortion");
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "dr_drive", &dsp.*.fEntry3, 0.0, 0.0, 1.0, 0.009999999776482582);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "dr_offset", &dsp.*.fEntry2, 0.0, 0.0, 1.0, 0.009999999776482582);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "sw_drive", &dsp.*.fEntry1, 1.0, 0.0, 1.0, 1.0);
    ui_interface.*.closeBox.?(ui_interface.*.uiInterface);
    ui_interface.*.openVerticalBox.?(ui_interface.*.uiInterface, "Flanger");
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "fl_delay", &dsp.*.fEntry18, 10.0, 0.0, 1024.0, 10.0);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "fl_depth", &dsp.*.fEntry19, 0.0, 0.0, 1.0, 0.009999999776482582);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "fl_fb", &dsp.*.fEntry17, 0.5, 0.0, 1.0, 0.009999999776482582);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "sw_flange", &dsp.*.fEntry8, 1.0, 0.0, 1.0, 1.0);
    ui_interface.*.closeBox.?(ui_interface.*.uiInterface);
    ui_interface.*.openVerticalBox.?(ui_interface.*.uiInterface, "HighPass");
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "hp_Q", &dsp.*.fEntry16, 1.0, 0.0, 1000.0, 1.0);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "hp_freq", &dsp.*.fEntry15, 20000.0, 100.0, 20000.0, 100.0);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "sw_highpass", &dsp.*.fEntry9, 1.0, 0.0, 1.0, 1.0);
    ui_interface.*.closeBox.?(ui_interface.*.uiInterface);
    ui_interface.*.openVerticalBox.?(ui_interface.*.uiInterface, "LowPass");
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "lp_Q", &dsp.*.fEntry14, 1.0, 0.0, 1000.0, 1.0);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "lp_freq", &dsp.*.fEntry13, 20000.0, 100.0, 20000.0, 100.0);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "sw_lowpass", &dsp.*.fEntry10, 1.0, 0.0, 1.0, 1.0);
    ui_interface.*.closeBox.?(ui_interface.*.uiInterface);
    ui_interface.*.openVerticalBox.?(ui_interface.*.uiInterface, "Phaser");
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "ph_depth", &dsp.*.fEntry20, 0.0, 0.0, 2.0, 1.0);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "ph_ratio", &dsp.*.fEntry21, 0.5, 0.0, 1.0, 0.10000000149011612);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "ph_speed", &dsp.*.fEntry22, 0.5, 0.0, 120.0, 1.0);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "sw_phase", &dsp.*.fEntry7, 1.0, 0.0, 1.0, 1.0);
    ui_interface.*.closeBox.?(ui_interface.*.uiInterface);
    ui_interface.*.openVerticalBox.?(ui_interface.*.uiInterface, "Pitch");
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "pi_semis", &dsp.*.fEntry12, 0.0, -12.0, 12.0, 1.0);
    ui_interface.*.addNumEntry.?(ui_interface.*.uiInterface, "sw_pitch", &dsp.*.fEntry11, 1.0, 0.0, 1.0, 1.0);
    ui_interface.*.closeBox.?(ui_interface.*.uiInterface);
    ui_interface.*.closeBox.?(ui_interface.*.uiInterface);
}
pub export fn computemydsp(arg_dsp: [*c]mydsp, arg_count: c_int, arg_inputs: [*c][*c]f32, arg_outputs: [*c][*c]f32) void {
    var dsp = arg_dsp;
    var count = arg_count;
    var inputs = arg_inputs;
    var outputs = arg_outputs;
    var input0: [*c]f32 = inputs[@intCast(c_uint, @as(c_int, 0))];
    var input1: [*c]f32 = inputs[@intCast(c_uint, @as(c_int, 1))];
    var output0: [*c]f32 = outputs[@intCast(c_uint, @as(c_int, 0))];
    var output1: [*c]f32 = outputs[@intCast(c_uint, @as(c_int, 1))];
    var iSlow0: c_int = @floatToInt(c_int, dsp.*.fEntry0);
    var iSlow1: c_int = @floatToInt(c_int, dsp.*.fEntry1);
    var fSlow2: f32 = dsp.*.fConst1 * dsp.*.fEntry2;
    var fSlow3: f32 = dsp.*.fConst1 * dsp.*.fEntry3;
    var iSlow4: c_int = @floatToInt(c_int, dsp.*.fEntry4);
    var fSlow5: f32 = dsp.*.fConst1 * dsp.*.fEntry5;
    var fSlow6: f32 = dsp.*.fConst1 * dsp.*.fEntry6;
    var iSlow7: c_int = @floatToInt(c_int, dsp.*.fEntry7);
    var iSlow8: c_int = @floatToInt(c_int, dsp.*.fEntry8);
    var iSlow9: c_int = @floatToInt(c_int, dsp.*.fEntry9);
    var iSlow10: c_int = @floatToInt(c_int, dsp.*.fEntry10);
    var iSlow11: c_int = @floatToInt(c_int, dsp.*.fEntry11);
    var fSlow12: f32 = powf(2.0, 0.0833333358168602 * dsp.*.fEntry12);
    var fSlow13: f32 = dsp.*.fConst1 * dsp.*.fEntry13;
    var fSlow14: f32 = dsp.*.fConst1 * dsp.*.fEntry14;
    var fSlow15: f32 = dsp.*.fConst1 * dsp.*.fEntry15;
    var fSlow16: f32 = dsp.*.fConst1 * dsp.*.fEntry16;
    var fSlow17: f32 = dsp.*.fConst1 * dsp.*.fEntry17;
    var fSlow18: f32 = dsp.*.fConst1 * dsp.*.fEntry18;
    var fSlow19: f32 = dsp.*.fConst1 * dsp.*.fEntry19;
    var fSlow20: f32 = dsp.*.fConst1 * dsp.*.fEntry20;
    var fSlow21: f32 = dsp.*.fConst1 * dsp.*.fEntry21;
    var fSlow22: f32 = dsp.*.fConst1 * dsp.*.fEntry22;
    {
        var @"i0": c_int = undefined;
        {
            @"i0" = 0;
            while (@"i0" < count) : (@"i0" = @"i0" + @as(c_int, 1)) {
                dsp.*.iVec0[@intCast(c_uint, @as(c_int, 0))] = 1;
                dsp.*.fRec1[@intCast(c_uint, @as(c_int, 0))] = fSlow2 + (dsp.*.fConst2 * dsp.*.fRec1[@intCast(c_uint, @as(c_int, 1))]);
                dsp.*.fRec2[@intCast(c_uint, @as(c_int, 0))] = fSlow3 + (dsp.*.fConst2 * dsp.*.fRec2[@intCast(c_uint, @as(c_int, 1))]);
                var fTemp0: f32 = powf(10.0, 2.0 * dsp.*.fRec2[@intCast(c_uint, @as(c_int, 0))]);
                dsp.*.fRec4[@intCast(c_uint, @as(c_int, 0))] = fSlow5 + (dsp.*.fConst2 * dsp.*.fRec4[@intCast(c_uint, @as(c_int, 1))]);
                dsp.*.fRec5[@intCast(c_uint, @as(c_int, 0))] = fSlow6 + (dsp.*.fConst2 * dsp.*.fRec5[@intCast(c_uint, @as(c_int, 1))]);
                var iTemp1: c_int = @floatToInt(c_int, fminf(48000.0, fmaxf(0.0, dsp.*.fConst0 * dsp.*.fRec5[@intCast(c_uint, @as(c_int, 0))]))) + @as(c_int, 1);
                var fTemp2: f32 = (blk: {
                    const tmp = @"i0";
                    if (tmp >= 0) break :blk input0 + @intCast(usize, tmp) else break :blk input0 - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*;
                var fTemp3: f32 = if (iSlow11 != 0) 0.0 else fTemp2;
                dsp.*.fVec1[@intCast(c_uint, dsp.*.IOTA & @as(c_int, 131071))] = fTemp3;
                dsp.*.fRec7[@intCast(c_uint, @as(c_int, 0))] = fmodf((dsp.*.fRec7[@intCast(c_uint, @as(c_int, 1))] + 513.0) - fSlow12, 512.0);
                var iTemp4: c_int = @floatToInt(c_int, dsp.*.fRec7[@intCast(c_uint, @as(c_int, 0))]);
                var iTemp5: c_int = min(@as(c_int, 65537), max(@as(c_int, 0), iTemp4));
                var fTemp6: f32 = floorf(dsp.*.fRec7[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp7: f32 = fTemp6 + (1.0 - dsp.*.fRec7[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp8: f32 = dsp.*.fRec7[@intCast(c_uint, @as(c_int, 0))] - fTemp6;
                var iTemp9: c_int = min(@as(c_int, 65537), max(@as(c_int, 0), iTemp4 + @as(c_int, 1)));
                var fTemp10: f32 = fminf(0.001953125 * dsp.*.fRec7[@intCast(c_uint, @as(c_int, 0))], 1.0);
                var fTemp11: f32 = dsp.*.fRec7[@intCast(c_uint, @as(c_int, 0))] + 512.0;
                var iTemp12: c_int = @floatToInt(c_int, fTemp11);
                var iTemp13: c_int = min(@as(c_int, 65537), max(@as(c_int, 0), iTemp12));
                var fTemp14: f32 = floorf(fTemp11);
                var fTemp15: f32 = fTemp14 + (-511.0 - dsp.*.fRec7[@intCast(c_uint, @as(c_int, 0))]);
                var iTemp16: c_int = min(@as(c_int, 65537), max(@as(c_int, 0), iTemp12 + @as(c_int, 1)));
                var fTemp17: f32 = dsp.*.fRec7[@intCast(c_uint, @as(c_int, 0))] + (512.0 - fTemp14);
                var fTemp18: f32 = 1.0 - fTemp10;
                var fThen1: f32 = (((dsp.*.fVec1[@intCast(c_uint, (dsp.*.IOTA - iTemp5) & @as(c_int, 131071))] * fTemp7) + (fTemp8 * dsp.*.fVec1[@intCast(c_uint, (dsp.*.IOTA - iTemp9) & @as(c_int, 131071))])) * fTemp10) + (((dsp.*.fVec1[@intCast(c_uint, (dsp.*.IOTA - iTemp13) & @as(c_int, 131071))] * fTemp15) + (dsp.*.fVec1[@intCast(c_uint, (dsp.*.IOTA - iTemp16) & @as(c_int, 131071))] * fTemp17)) * fTemp18);
                var fTemp19: f32 = if (iSlow11 != 0) fTemp2 else fThen1;
                dsp.*.fRec8[@intCast(c_uint, @as(c_int, 0))] = fSlow13 + (dsp.*.fConst2 * dsp.*.fRec8[@intCast(c_uint, @as(c_int, 1))]);
                var fTemp20: f32 = tanf(dsp.*.fConst3 * dsp.*.fRec8[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp21: f32 = 1.0 / fTemp20;
                dsp.*.fRec9[@intCast(c_uint, @as(c_int, 0))] = fSlow14 + (dsp.*.fConst2 * dsp.*.fRec9[@intCast(c_uint, @as(c_int, 1))]);
                var fTemp22: f32 = 1.0 / dsp.*.fRec9[@intCast(c_uint, @as(c_int, 0))];
                var fTemp23: f32 = ((fTemp21 - fTemp22) / fTemp20) + 1.0;
                var fTemp24: f32 = 1.0 - (1.0 / mydsp_faustpower2_f(fTemp20));
                var fTemp25: f32 = ((fTemp22 + fTemp21) / fTemp20) + 1.0;
                dsp.*.fRec6[@intCast(c_uint, @as(c_int, 0))] = (if (iSlow10 != 0) 0.0 else fTemp19) - (((dsp.*.fRec6[@intCast(c_uint, @as(c_int, 2))] * fTemp23) + (2.0 * (dsp.*.fRec6[@intCast(c_uint, @as(c_int, 1))] * fTemp24))) / fTemp25);
                var fThen3: f32 = (dsp.*.fRec6[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fRec6[@intCast(c_uint, @as(c_int, 0))] + (2.0 * dsp.*.fRec6[@intCast(c_uint, @as(c_int, 1))]))) / fTemp25;
                var fTemp26: f32 = if (iSlow10 != 0) fTemp19 else fThen3;
                var fTemp27: f32 = if (iSlow9 != 0) 0.0 else fTemp26;
                dsp.*.fRec11[@intCast(c_uint, @as(c_int, 0))] = fSlow15 + (dsp.*.fConst2 * dsp.*.fRec11[@intCast(c_uint, @as(c_int, 1))]);
                var fTemp28: f32 = tanf(dsp.*.fConst3 * dsp.*.fRec11[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp29: f32 = 1.0 / fTemp28;
                dsp.*.fRec12[@intCast(c_uint, @as(c_int, 0))] = fSlow16 + (dsp.*.fConst2 * dsp.*.fRec12[@intCast(c_uint, @as(c_int, 1))]);
                var fTemp30: f32 = 1.0 / dsp.*.fRec12[@intCast(c_uint, @as(c_int, 0))];
                var fTemp31: f32 = ((fTemp29 - fTemp30) / fTemp28) + 1.0;
                var fTemp32: f32 = 1.0 - (1.0 / mydsp_faustpower2_f(fTemp28));
                var fTemp33: f32 = ((fTemp30 + fTemp29) / fTemp28) + 1.0;
                dsp.*.fRec10[@intCast(c_uint, @as(c_int, 0))] = fTemp27 - (((dsp.*.fRec10[@intCast(c_uint, @as(c_int, 2))] * fTemp31) + (2.0 * (dsp.*.fRec10[@intCast(c_uint, @as(c_int, 1))] * fTemp32))) / fTemp33);
                var fThen5: f32 = fTemp27 - ((dsp.*.fRec10[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fRec10[@intCast(c_uint, @as(c_int, 0))] + (2.0 * dsp.*.fRec10[@intCast(c_uint, @as(c_int, 1))]))) / fTemp33);
                var fTemp34: f32 = if (iSlow9 != 0) fTemp26 else fThen5;
                var fTemp35: f32 = if (iSlow8 != 0) 0.0 else fTemp34;
                dsp.*.fRec14[@intCast(c_uint, @as(c_int, 0))] = fSlow17 + (dsp.*.fConst2 * dsp.*.fRec14[@intCast(c_uint, @as(c_int, 1))]);
                var fTemp36: f32 = (dsp.*.fRec14[@intCast(c_uint, @as(c_int, 0))] * dsp.*.fRec13[@intCast(c_uint, @as(c_int, 1))]) - fTemp35;
                dsp.*.fVec2[@intCast(c_uint, dsp.*.IOTA & @as(c_int, 2047))] = fTemp36;
                dsp.*.fRec15[@intCast(c_uint, @as(c_int, 0))] = fSlow18 + (dsp.*.fConst2 * dsp.*.fRec15[@intCast(c_uint, @as(c_int, 1))]);
                var iTemp37: c_int = @floatToInt(c_int, dsp.*.fRec15[@intCast(c_uint, @as(c_int, 0))]);
                var iTemp38: c_int = min(@as(c_int, 1025), max(@as(c_int, 0), iTemp37));
                var fTemp39: f32 = floorf(dsp.*.fRec15[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp40: f32 = fTemp39 + (1.0 - dsp.*.fRec15[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp41: f32 = dsp.*.fRec15[@intCast(c_uint, @as(c_int, 0))] - fTemp39;
                var iTemp42: c_int = min(@as(c_int, 1025), max(@as(c_int, 0), iTemp37 + @as(c_int, 1)));
                dsp.*.fRec13[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fVec2[@intCast(c_uint, (dsp.*.IOTA - iTemp38) & @as(c_int, 2047))] * fTemp40) + (fTemp41 * dsp.*.fVec2[@intCast(c_uint, (dsp.*.IOTA - iTemp42) & @as(c_int, 2047))]);
                dsp.*.fRec16[@intCast(c_uint, @as(c_int, 0))] = fSlow19 + (dsp.*.fConst2 * dsp.*.fRec16[@intCast(c_uint, @as(c_int, 1))]);
                var fThen7: f32 = 0.5 * (fTemp35 + (dsp.*.fRec13[@intCast(c_uint, @as(c_int, 0))] * dsp.*.fRec16[@intCast(c_uint, @as(c_int, 0))]));
                var fTemp43: f32 = if (iSlow8 != 0) fTemp34 else fThen7;
                var fTemp44: f32 = if (iSlow7 != 0) 0.0 else fTemp43;
                dsp.*.fRec17[@intCast(c_uint, @as(c_int, 0))] = fSlow20 + (dsp.*.fConst2 * dsp.*.fRec17[@intCast(c_uint, @as(c_int, 1))]);
                var fTemp45: f32 = 1.0 - (0.5 * dsp.*.fRec17[@intCast(c_uint, @as(c_int, 0))]);
                dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))] = fSlow21 + (dsp.*.fConst2 * dsp.*.fRec31[@intCast(c_uint, @as(c_int, 1))]);
                dsp.*.fRec34[@intCast(c_uint, @as(c_int, 0))] = fSlow22 + (dsp.*.fConst2 * dsp.*.fRec34[@intCast(c_uint, @as(c_int, 1))]);
                var fTemp46: f32 = dsp.*.fConst8 * dsp.*.fRec34[@intCast(c_uint, @as(c_int, 0))];
                var fTemp47: f32 = sinf(fTemp46);
                var fTemp48: f32 = cosf(fTemp46);
                dsp.*.fRec32[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fRec33[@intCast(c_uint, @as(c_int, 1))] * fTemp47) + (dsp.*.fRec32[@intCast(c_uint, @as(c_int, 1))] * fTemp48);
                dsp.*.fRec33[@intCast(c_uint, @as(c_int, 0))] = (@intToFloat(f32, @as(c_int, 1) - dsp.*.iVec0[@intCast(c_uint, @as(c_int, 1))]) + (dsp.*.fRec33[@intCast(c_uint, @as(c_int, 1))] * fTemp48)) - (fTemp47 * dsp.*.fRec32[@intCast(c_uint, @as(c_int, 1))]);
                var fTemp49: f32 = (4712.38916015625 * (1.0 - dsp.*.fRec32[@intCast(c_uint, @as(c_int, 0))])) + 3141.5927734375;
                var fTemp50: f32 = dsp.*.fRec30[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))] * fTemp49));
                dsp.*.fRec30[@intCast(c_uint, @as(c_int, 0))] = fTemp44 - ((dsp.*.fConst6 * fTemp50) + (dsp.*.fConst5 * dsp.*.fRec30[@intCast(c_uint, @as(c_int, 2))]));
                var fTemp51: f32 = mydsp_faustpower2_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp52: f32 = dsp.*.fRec29[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp51 * fTemp49));
                dsp.*.fRec29[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec30[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec29[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec30[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp50 - fTemp52)));
                var fTemp53: f32 = mydsp_faustpower3_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp54: f32 = dsp.*.fRec28[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp53 * fTemp49));
                dsp.*.fRec28[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec29[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec28[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec29[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp52 - fTemp54)));
                var fTemp55: f32 = mydsp_faustpower4_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp56: f32 = dsp.*.fRec27[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp55 * fTemp49));
                dsp.*.fRec27[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec28[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec27[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec28[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp54 - fTemp56)));
                var fTemp57: f32 = mydsp_faustpower5_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp58: f32 = dsp.*.fRec26[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp57 * fTemp49));
                dsp.*.fRec26[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec27[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec26[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec27[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp56 - fTemp58)));
                var fTemp59: f32 = mydsp_faustpower6_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp60: f32 = dsp.*.fRec25[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp59 * fTemp49));
                dsp.*.fRec25[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec26[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec25[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec26[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp58 - fTemp60)));
                var fTemp61: f32 = mydsp_faustpower7_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp62: f32 = dsp.*.fRec24[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp61 * fTemp49));
                dsp.*.fRec24[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec25[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec24[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec25[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp60 - fTemp62)));
                var fTemp63: f32 = mydsp_faustpower8_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp64: f32 = dsp.*.fRec23[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp63 * fTemp49));
                dsp.*.fRec23[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec24[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec23[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec24[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp62 - fTemp64)));
                var fTemp65: f32 = mydsp_faustpower9_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp66: f32 = dsp.*.fRec22[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp65 * fTemp49));
                dsp.*.fRec22[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec23[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec22[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec23[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp64 - fTemp66)));
                var fTemp67: f32 = mydsp_faustpower10_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp68: f32 = dsp.*.fRec21[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp67 * fTemp49));
                dsp.*.fRec21[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec22[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec21[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec22[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp66 - fTemp68)));
                var fTemp69: f32 = mydsp_faustpower11_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp70: f32 = dsp.*.fRec20[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp69 * fTemp49));
                dsp.*.fRec20[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec21[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec20[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec21[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp68 - fTemp70)));
                var fTemp71: f32 = mydsp_faustpower12_f(dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))]);
                var fTemp72: f32 = dsp.*.fRec19[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp71 * fTemp49));
                dsp.*.fRec19[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec20[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec19[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec20[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp70 - fTemp72)));
                var fRec18: f32 = (dsp.*.fConst5 * dsp.*.fRec19[@intCast(c_uint, @as(c_int, 0))]) + ((dsp.*.fConst6 * fTemp72) + dsp.*.fRec19[@intCast(c_uint, @as(c_int, 2))]);
                var fThen9: f32 = (fTemp44 * fTemp45) + (0.5 * (dsp.*.fRec17[@intCast(c_uint, @as(c_int, 0))] * fRec18));
                var fTemp73: f32 = if (iSlow7 != 0) fTemp43 else fThen9;
                dsp.*.fRec3[@intCast(c_uint, dsp.*.IOTA & @as(c_int, 65535))] = (dsp.*.fRec4[@intCast(c_uint, @as(c_int, 0))] * dsp.*.fRec3[@intCast(c_uint, (dsp.*.IOTA - iTemp1) & @as(c_int, 65535))]) + (if (iSlow4 != 0) 0.0 else fTemp73);
                var fThen11: f32 = dsp.*.fRec3[@intCast(c_uint, (dsp.*.IOTA - @as(c_int, 0)) & @as(c_int, 65535))];
                var fTemp74: f32 = if (iSlow4 != 0) fTemp73 else fThen11;
                var fTemp75: f32 = fmaxf(-1.0, fminf(1.0, dsp.*.fRec1[@intCast(c_uint, @as(c_int, 0))] + (fTemp0 * (if (iSlow1 != 0) 0.0 else fTemp74))));
                var fTemp76: f32 = fTemp75 * (1.0 - (0.3333333432674408 * mydsp_faustpower2_f(fTemp75)));
                dsp.*.fVec3[@intCast(c_uint, @as(c_int, 0))] = fTemp76;
                dsp.*.fRec0[@intCast(c_uint, @as(c_int, 0))] = ((0.9950000047683716 * dsp.*.fRec0[@intCast(c_uint, @as(c_int, 1))]) + fTemp76) - dsp.*.fVec3[@intCast(c_uint, @as(c_int, 1))];
                var fTemp77: f32 = if (iSlow1 != 0) fTemp74 else dsp.*.fRec0[@intCast(c_uint, @as(c_int, 0))];
                var fTemp78: f32 = if (iSlow0 != 0) 0.0 else fTemp77;
                var fTemp79: f32 = (blk: {
                    const tmp = @"i0";
                    if (tmp >= 0) break :blk input1 + @intCast(usize, tmp) else break :blk input1 - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*;
                var fTemp80: f32 = if (iSlow11 != 0) 0.0 else fTemp79;
                dsp.*.fVec4[@intCast(c_uint, dsp.*.IOTA & @as(c_int, 131071))] = fTemp80;
                var fThen16: f32 = (fTemp10 * ((dsp.*.fVec4[@intCast(c_uint, (dsp.*.IOTA - iTemp5) & @as(c_int, 131071))] * fTemp7) + (fTemp8 * dsp.*.fVec4[@intCast(c_uint, (dsp.*.IOTA - iTemp9) & @as(c_int, 131071))]))) + (fTemp18 * ((dsp.*.fVec4[@intCast(c_uint, (dsp.*.IOTA - iTemp13) & @as(c_int, 131071))] * fTemp15) + (dsp.*.fVec4[@intCast(c_uint, (dsp.*.IOTA - iTemp16) & @as(c_int, 131071))] * fTemp17)));
                var fTemp81: f32 = if (iSlow11 != 0) fTemp79 else fThen16;
                dsp.*.fRec40[@intCast(c_uint, @as(c_int, 0))] = (if (iSlow10 != 0) 0.0 else fTemp81) - (((fTemp23 * dsp.*.fRec40[@intCast(c_uint, @as(c_int, 2))]) + (2.0 * (fTemp24 * dsp.*.fRec40[@intCast(c_uint, @as(c_int, 1))]))) / fTemp25);
                var fThen18: f32 = (dsp.*.fRec40[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fRec40[@intCast(c_uint, @as(c_int, 0))] + (2.0 * dsp.*.fRec40[@intCast(c_uint, @as(c_int, 1))]))) / fTemp25;
                var fTemp82: f32 = if (iSlow10 != 0) fTemp81 else fThen18;
                var fTemp83: f32 = if (iSlow9 != 0) 0.0 else fTemp82;
                dsp.*.fRec41[@intCast(c_uint, @as(c_int, 0))] = fTemp83 - (((fTemp31 * dsp.*.fRec41[@intCast(c_uint, @as(c_int, 2))]) + (2.0 * (fTemp32 * dsp.*.fRec41[@intCast(c_uint, @as(c_int, 1))]))) / fTemp33);
                var fThen20: f32 = fTemp83 - ((dsp.*.fRec41[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fRec41[@intCast(c_uint, @as(c_int, 0))] + (2.0 * dsp.*.fRec41[@intCast(c_uint, @as(c_int, 1))]))) / fTemp33);
                var fTemp84: f32 = if (iSlow9 != 0) fTemp82 else fThen20;
                var fTemp85: f32 = if (iSlow8 != 0) 0.0 else fTemp84;
                var fTemp86: f32 = (dsp.*.fRec14[@intCast(c_uint, @as(c_int, 0))] * dsp.*.fRec42[@intCast(c_uint, @as(c_int, 1))]) - fTemp85;
                dsp.*.fVec5[@intCast(c_uint, dsp.*.IOTA & @as(c_int, 2047))] = fTemp86;
                dsp.*.fRec42[@intCast(c_uint, @as(c_int, 0))] = (fTemp40 * dsp.*.fVec5[@intCast(c_uint, (dsp.*.IOTA - iTemp38) & @as(c_int, 2047))]) + (fTemp41 * dsp.*.fVec5[@intCast(c_uint, (dsp.*.IOTA - iTemp42) & @as(c_int, 2047))]);
                var fThen22: f32 = 0.5 * (fTemp85 + (dsp.*.fRec16[@intCast(c_uint, @as(c_int, 0))] * dsp.*.fRec42[@intCast(c_uint, @as(c_int, 0))]));
                var fTemp87: f32 = if (iSlow8 != 0) fTemp84 else fThen22;
                var fTemp88: f32 = if (iSlow7 != 0) 0.0 else fTemp87;
                var fTemp89: f32 = (4712.38916015625 * (1.0 - dsp.*.fRec33[@intCast(c_uint, @as(c_int, 0))])) + 3141.5927734375;
                var fTemp90: f32 = dsp.*.fRec55[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))] * fTemp89));
                dsp.*.fRec55[@intCast(c_uint, @as(c_int, 0))] = fTemp88 - ((dsp.*.fConst6 * fTemp90) + (dsp.*.fConst5 * dsp.*.fRec55[@intCast(c_uint, @as(c_int, 2))]));
                var fTemp91: f32 = dsp.*.fRec54[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp51 * fTemp89));
                dsp.*.fRec54[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec55[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec54[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec55[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp90 - fTemp91)));
                var fTemp92: f32 = dsp.*.fRec53[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp53 * fTemp89));
                dsp.*.fRec53[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec54[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec53[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec54[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp91 - fTemp92)));
                var fTemp93: f32 = dsp.*.fRec52[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp55 * fTemp89));
                dsp.*.fRec52[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec53[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec52[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec53[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp92 - fTemp93)));
                var fTemp94: f32 = dsp.*.fRec51[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp57 * fTemp89));
                dsp.*.fRec51[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec52[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec51[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec52[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp93 - fTemp94)));
                var fTemp95: f32 = dsp.*.fRec50[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp59 * fTemp89));
                dsp.*.fRec50[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec51[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec50[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec51[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp94 - fTemp95)));
                var fTemp96: f32 = dsp.*.fRec49[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp61 * fTemp89));
                dsp.*.fRec49[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec50[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec49[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec50[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp95 - fTemp96)));
                var fTemp97: f32 = dsp.*.fRec48[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp63 * fTemp89));
                dsp.*.fRec48[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec49[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec48[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec49[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp96 - fTemp97)));
                var fTemp98: f32 = dsp.*.fRec47[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp65 * fTemp89));
                dsp.*.fRec47[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec48[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec47[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec48[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp97 - fTemp98)));
                var fTemp99: f32 = dsp.*.fRec46[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp67 * fTemp89));
                dsp.*.fRec46[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec47[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec46[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec47[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp98 - fTemp99)));
                var fTemp100: f32 = dsp.*.fRec45[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp69 * fTemp89));
                dsp.*.fRec45[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec46[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec45[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec46[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp99 - fTemp100)));
                var fTemp101: f32 = dsp.*.fRec44[@intCast(c_uint, @as(c_int, 1))] * cosf(dsp.*.fConst7 * (fTemp71 * fTemp89));
                dsp.*.fRec44[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst5 * (dsp.*.fRec45[@intCast(c_uint, @as(c_int, 0))] - dsp.*.fRec44[@intCast(c_uint, @as(c_int, 2))])) + (dsp.*.fRec45[@intCast(c_uint, @as(c_int, 2))] + (dsp.*.fConst6 * (fTemp100 - fTemp101)));
                var fRec43: f32 = (dsp.*.fConst5 * dsp.*.fRec44[@intCast(c_uint, @as(c_int, 0))]) + ((dsp.*.fConst6 * fTemp101) + dsp.*.fRec44[@intCast(c_uint, @as(c_int, 2))]);
                var fThen24: f32 = (fTemp45 * fTemp88) + (0.5 * (dsp.*.fRec17[@intCast(c_uint, @as(c_int, 0))] * fRec43));
                var fTemp102: f32 = if (iSlow7 != 0) fTemp87 else fThen24;
                dsp.*.fRec39[@intCast(c_uint, dsp.*.IOTA & @as(c_int, 65535))] = (dsp.*.fRec4[@intCast(c_uint, @as(c_int, 0))] * dsp.*.fRec39[@intCast(c_uint, (dsp.*.IOTA - iTemp1) & @as(c_int, 65535))]) + (if (iSlow4 != 0) 0.0 else fTemp102);
                var fThen26: f32 = dsp.*.fRec39[@intCast(c_uint, (dsp.*.IOTA - @as(c_int, 0)) & @as(c_int, 65535))];
                var fTemp103: f32 = if (iSlow4 != 0) fTemp102 else fThen26;
                var fTemp104: f32 = fmaxf(-1.0, fminf(1.0, dsp.*.fRec1[@intCast(c_uint, @as(c_int, 0))] + (fTemp0 * (if (iSlow1 != 0) 0.0 else fTemp103))));
                var fTemp105: f32 = fTemp104 * (1.0 - (0.3333333432674408 * mydsp_faustpower2_f(fTemp104)));
                dsp.*.fVec6[@intCast(c_uint, @as(c_int, 0))] = fTemp105;
                dsp.*.fRec38[@intCast(c_uint, @as(c_int, 0))] = ((0.9950000047683716 * dsp.*.fRec38[@intCast(c_uint, @as(c_int, 1))]) + fTemp105) - dsp.*.fVec6[@intCast(c_uint, @as(c_int, 1))];
                var fTemp106: f32 = if (iSlow1 != 0) fTemp103 else dsp.*.fRec38[@intCast(c_uint, @as(c_int, 0))];
                var fTemp107: f32 = if (iSlow0 != 0) 0.0 else fTemp106;
                var fTemp108: f32 = fabsf(fabsf(fTemp78) + fabsf(fTemp107));
                var fTemp109: f32 = if (dsp.*.fRec36[@intCast(c_uint, @as(c_int, 1))] > fTemp108) dsp.*.fConst12 else dsp.*.fConst11;
                dsp.*.fRec37[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fRec37[@intCast(c_uint, @as(c_int, 1))] * fTemp109) + (fTemp108 * (1.0 - fTemp109));
                dsp.*.fRec36[@intCast(c_uint, @as(c_int, 0))] = dsp.*.fRec37[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec35[@intCast(c_uint, @as(c_int, 0))] = (dsp.*.fConst9 * dsp.*.fRec35[@intCast(c_uint, @as(c_int, 1))]) + (dsp.*.fConst10 * (0.0 - (0.75 * fmaxf((20.0 * log10f(fmaxf(0.000000000000000000000000000000000000011754943508222875, dsp.*.fRec36[@intCast(c_uint, @as(c_int, 0))]))) + 6.0, 0.0))));
                var fTemp110: f32 = powf(10.0, 0.05000000074505806 * dsp.*.fRec35[@intCast(c_uint, @as(c_int, 0))]);
                var fThen31: f32 = fTemp78 * fTemp110;
                (blk: {
                    const tmp = @"i0";
                    if (tmp >= 0) break :blk output0 + @intCast(usize, tmp) else break :blk output0 - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).* = if (iSlow0 != 0) fTemp77 else fThen31;
                var fThen32: f32 = fTemp107 * fTemp110;
                (blk: {
                    const tmp = @"i0";
                    if (tmp >= 0) break :blk output1 + @intCast(usize, tmp) else break :blk output1 - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).* = if (iSlow0 != 0) fTemp106 else fThen32;
                dsp.*.iVec0[@intCast(c_uint, @as(c_int, 1))] = dsp.*.iVec0[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec1[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec1[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec2[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec2[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec4[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec4[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec5[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec5[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.IOTA = dsp.*.IOTA + @as(c_int, 1);
                dsp.*.fRec7[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec7[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec8[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec8[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec9[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec9[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec6[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec6[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec6[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec6[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec11[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec11[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec12[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec12[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec10[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec10[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec10[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec10[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec14[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec14[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec15[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec15[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec13[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec13[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec16[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec16[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec17[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec17[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec31[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec31[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec34[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec34[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec32[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec32[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec33[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec33[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec30[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec30[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec30[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec30[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec29[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec29[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec29[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec29[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec28[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec28[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec28[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec28[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec27[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec27[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec27[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec27[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec26[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec26[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec26[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec26[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec25[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec25[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec25[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec25[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec24[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec24[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec24[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec24[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec23[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec23[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec23[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec23[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec22[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec22[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec22[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec22[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec21[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec21[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec21[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec21[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec20[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec20[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec20[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec20[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec19[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec19[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec19[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec19[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fVec3[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fVec3[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec0[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec0[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec40[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec40[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec40[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec40[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec41[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec41[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec41[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec41[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec42[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec42[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec55[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec55[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec55[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec55[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec54[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec54[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec54[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec54[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec53[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec53[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec53[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec53[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec52[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec52[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec52[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec52[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec51[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec51[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec51[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec51[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec50[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec50[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec50[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec50[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec49[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec49[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec49[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec49[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec48[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec48[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec48[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec48[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec47[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec47[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec47[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec47[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec46[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec46[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec46[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec46[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec45[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec45[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec45[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec45[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec44[@intCast(c_uint, @as(c_int, 2))] = dsp.*.fRec44[@intCast(c_uint, @as(c_int, 1))];
                dsp.*.fRec44[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec44[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fVec6[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fVec6[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec38[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec38[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec37[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec37[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec36[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec36[@intCast(c_uint, @as(c_int, 0))];
                dsp.*.fRec35[@intCast(c_uint, @as(c_int, 1))] = dsp.*.fRec35[@intCast(c_uint, @as(c_int, 0))];
            }
        }
    }
}
