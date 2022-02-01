/* ------------------------------------------------------------
name: "multifx2"
Code generated with Faust 2.37.3 (https://faust.grame.fr)
Compilation options: -lang c -es 1 -single -ftz 0
------------------------------------------------------------ */

#ifndef  __mydsp_H__
#define  __mydsp_H__

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif 


#ifdef __cplusplus
extern "C" {
#endif

#include <math.h>
#include <stdint.h>
#include <stdlib.h>

static float mydsp_faustpower2_f(float value) {
	return (value * value);
}
static float mydsp_faustpower3_f(float value) {
	return ((value * value) * value);
}
static float mydsp_faustpower4_f(float value) {
	return (((value * value) * value) * value);
}
static float mydsp_faustpower5_f(float value) {
	return ((((value * value) * value) * value) * value);
}
static float mydsp_faustpower6_f(float value) {
	return (((((value * value) * value) * value) * value) * value);
}
static float mydsp_faustpower7_f(float value) {
	return ((((((value * value) * value) * value) * value) * value) * value);
}
static float mydsp_faustpower8_f(float value) {
	return (((((((value * value) * value) * value) * value) * value) * value) * value);
}
static float mydsp_faustpower9_f(float value) {
	return ((((((((value * value) * value) * value) * value) * value) * value) * value) * value);
}
static float mydsp_faustpower10_f(float value) {
	return (((((((((value * value) * value) * value) * value) * value) * value) * value) * value) * value);
}
static float mydsp_faustpower11_f(float value) {
	return ((((((((((value * value) * value) * value) * value) * value) * value) * value) * value) * value) * value);
}
static float mydsp_faustpower12_f(float value) {
	return (((((((((((value * value) * value) * value) * value) * value) * value) * value) * value) * value) * value) * value);
}

#ifndef FAUSTCLASS 
#define FAUSTCLASS mydsp
#endif
#ifdef __APPLE__ 
#define exp10f __exp10f
#define exp10 __exp10
#endif

typedef struct {
	FAUSTFLOAT fEntry0;
	FAUSTFLOAT fEntry1;
	int iVec0[2];
	int fSampleRate;
	float fConst0;
	float fConst1;
	FAUSTFLOAT fEntry2;
	float fConst2;
	float fRec1[2];
	FAUSTFLOAT fEntry3;
	float fRec2[2];
	FAUSTFLOAT fEntry4;
	FAUSTFLOAT fEntry5;
	float fRec4[2];
	FAUSTFLOAT fEntry6;
	float fRec5[2];
	FAUSTFLOAT fEntry7;
	FAUSTFLOAT fEntry8;
	FAUSTFLOAT fEntry9;
	FAUSTFLOAT fEntry10;
	FAUSTFLOAT fEntry11;
	int IOTA;
	float fVec1[131072];
	FAUSTFLOAT fEntry12;
	float fRec7[2];
	float fConst3;
	FAUSTFLOAT fEntry13;
	float fRec8[2];
	FAUSTFLOAT fEntry14;
	float fRec9[2];
	float fRec6[3];
	FAUSTFLOAT fEntry15;
	float fRec11[2];
	FAUSTFLOAT fEntry16;
	float fRec12[2];
	float fRec10[3];
	FAUSTFLOAT fEntry17;
	float fRec14[2];
	float fVec2[2048];
	FAUSTFLOAT fEntry18;
	float fRec15[2];
	float fRec13[2];
	FAUSTFLOAT fEntry19;
	float fRec16[2];
	FAUSTFLOAT fEntry20;
	float fRec17[2];
	float fConst5;
	float fConst6;
	float fConst7;
	FAUSTFLOAT fEntry21;
	float fRec31[2];
	float fConst8;
	FAUSTFLOAT fEntry22;
	float fRec34[2];
	float fRec32[2];
	float fRec33[2];
	float fRec30[3];
	float fRec29[3];
	float fRec28[3];
	float fRec27[3];
	float fRec26[3];
	float fRec25[3];
	float fRec24[3];
	float fRec23[3];
	float fRec22[3];
	float fRec21[3];
	float fRec20[3];
	float fRec19[3];
	float fRec3[65536];
	float fVec3[2];
	float fRec0[2];
	float fConst9;
	float fConst10;
	float fVec4[131072];
	float fRec40[3];
	float fRec41[3];
	float fVec5[2048];
	float fRec42[2];
	float fRec55[3];
	float fRec54[3];
	float fRec53[3];
	float fRec52[3];
	float fRec51[3];
	float fRec50[3];
	float fRec49[3];
	float fRec48[3];
	float fRec47[3];
	float fRec46[3];
	float fRec45[3];
	float fRec44[3];
	float fRec39[65536];
	float fVec6[2];
	float fRec38[2];
	float fConst11;
	float fConst12;
	float fRec37[2];
	float fRec36[2];
	float fRec35[2];
} mydsp;

mydsp* newmydsp() { 
	mydsp* dsp = (mydsp*)calloc(1, sizeof(mydsp));
	return dsp;
}

void deletemydsp(mydsp* dsp) { 
	free(dsp);
}
/*
void metadatamydsp(MetaGlue* m) { 
	m->declare(m->metaInterface, "analyzers.lib/name", "Faust Analyzer Library");
	m->declare(m->metaInterface, "analyzers.lib/version", "0.1");
	m->declare(m->metaInterface, "basics.lib/name", "Faust Basic Element Library");
	m->declare(m->metaInterface, "basics.lib/version", "0.2");
	m->declare(m->metaInterface, "compile_options", "-lang c -es 1 -single -ftz 0");
	m->declare(m->metaInterface, "compressors.lib/compression_gain_mono:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "compressors.lib/compression_gain_mono:copyright", "Copyright (C) 2014-2020 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "compressors.lib/compression_gain_mono:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "compressors.lib/compressor_stereo:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "compressors.lib/compressor_stereo:copyright", "Copyright (C) 2014-2020 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "compressors.lib/compressor_stereo:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "compressors.lib/name", "Faust Compressor Effect Library");
	m->declare(m->metaInterface, "compressors.lib/version", "0.1");
	m->declare(m->metaInterface, "delays.lib/name", "Faust Delay Library");
	m->declare(m->metaInterface, "delays.lib/version", "0.1");
	m->declare(m->metaInterface, "filename", "multifx2.dsp");
	m->declare(m->metaInterface, "filters.lib/dcblocker:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "filters.lib/dcblocker:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/dcblocker:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "filters.lib/fir:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "filters.lib/fir:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/fir:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "filters.lib/iir:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "filters.lib/iir:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/iir:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "filters.lib/lowpass0_highpass1", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/name", "Faust Filters Library");
	m->declare(m->metaInterface, "filters.lib/nlf2:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "filters.lib/nlf2:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/nlf2:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "filters.lib/pole:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "filters.lib/pole:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/pole:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "filters.lib/resonhp:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "filters.lib/resonhp:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/resonhp:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "filters.lib/resonlp:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "filters.lib/resonlp:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/resonlp:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "filters.lib/tf2:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "filters.lib/tf2:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/tf2:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "filters.lib/tf2s:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "filters.lib/tf2s:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/tf2s:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "filters.lib/version", "0.3");
	m->declare(m->metaInterface, "filters.lib/zero:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "filters.lib/zero:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
	m->declare(m->metaInterface, "filters.lib/zero:license", "MIT-style STK-4.3 license");
	m->declare(m->metaInterface, "maths.lib/author", "GRAME");
	m->declare(m->metaInterface, "maths.lib/copyright", "GRAME");
	m->declare(m->metaInterface, "maths.lib/license", "LGPL with exception");
	m->declare(m->metaInterface, "maths.lib/name", "Faust Math Library");
	m->declare(m->metaInterface, "maths.lib/version", "2.5");
	m->declare(m->metaInterface, "misceffects.lib/name", "Misc Effects Library");
	m->declare(m->metaInterface, "misceffects.lib/version", "2.0");
	m->declare(m->metaInterface, "name", "multifx2");
	m->declare(m->metaInterface, "oscillators.lib/name", "Faust Oscillator Library");
	m->declare(m->metaInterface, "oscillators.lib/version", "0.1");
	m->declare(m->metaInterface, "phaflangers.lib/name", "Faust Phaser and Flanger Library");
	m->declare(m->metaInterface, "phaflangers.lib/version", "0.1");
	m->declare(m->metaInterface, "platform.lib/name", "Generic Platform Library");
	m->declare(m->metaInterface, "platform.lib/version", "0.2");
	m->declare(m->metaInterface, "routes.lib/name", "Faust Signal Routing Library");
	m->declare(m->metaInterface, "routes.lib/version", "0.2");
	m->declare(m->metaInterface, "signals.lib/name", "Faust Signal Routing Library");
	m->declare(m->metaInterface, "signals.lib/version", "0.1");
}
*/
int getSampleRatemydsp(mydsp* dsp) {
	return dsp->fSampleRate;
}

int getNumInputsmydsp(mydsp* dsp) {
	return 2;
}
int getNumOutputsmydsp(mydsp* dsp) {
	return 2;
}

void classInitmydsp(int sample_rate) {
}

void instanceResetUserInterfacemydsp(mydsp* dsp) {
	dsp->fEntry0 = (FAUSTFLOAT)1.0f;
	dsp->fEntry1 = (FAUSTFLOAT)1.0f;
	dsp->fEntry2 = (FAUSTFLOAT)0.0f;
	dsp->fEntry3 = (FAUSTFLOAT)0.0f;
	dsp->fEntry4 = (FAUSTFLOAT)1.0f;
	dsp->fEntry5 = (FAUSTFLOAT)0.5f;
	dsp->fEntry6 = (FAUSTFLOAT)0.25f;
	dsp->fEntry7 = (FAUSTFLOAT)1.0f;
	dsp->fEntry8 = (FAUSTFLOAT)1.0f;
	dsp->fEntry9 = (FAUSTFLOAT)1.0f;
	dsp->fEntry10 = (FAUSTFLOAT)1.0f;
	dsp->fEntry11 = (FAUSTFLOAT)1.0f;
	dsp->fEntry12 = (FAUSTFLOAT)0.0f;
	dsp->fEntry13 = (FAUSTFLOAT)20000.0f;
	dsp->fEntry14 = (FAUSTFLOAT)1.0f;
	dsp->fEntry15 = (FAUSTFLOAT)100.0f;
	dsp->fEntry16 = (FAUSTFLOAT)1.0f;
	dsp->fEntry17 = (FAUSTFLOAT)0.5f;
	dsp->fEntry18 = (FAUSTFLOAT)10.0f;
	dsp->fEntry19 = (FAUSTFLOAT)0.0f;
	dsp->fEntry20 = (FAUSTFLOAT)0.0f;
	dsp->fEntry21 = (FAUSTFLOAT)0.5f;
	dsp->fEntry22 = (FAUSTFLOAT)0.5f;
}

void instanceClearmydsp(mydsp* dsp) {
	/* C99 loop */
	{
		int l0;
		for (l0 = 0; (l0 < 2); l0 = (l0 + 1)) {
			dsp->iVec0[l0] = 0;
		}
	}
	/* C99 loop */
	{
		int l1;
		for (l1 = 0; (l1 < 2); l1 = (l1 + 1)) {
			dsp->fRec1[l1] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l2;
		for (l2 = 0; (l2 < 2); l2 = (l2 + 1)) {
			dsp->fRec2[l2] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l3;
		for (l3 = 0; (l3 < 2); l3 = (l3 + 1)) {
			dsp->fRec4[l3] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l4;
		for (l4 = 0; (l4 < 2); l4 = (l4 + 1)) {
			dsp->fRec5[l4] = 0.0f;
		}
	}
	dsp->IOTA = 0;
	/* C99 loop */
	{
		int l5;
		for (l5 = 0; (l5 < 131072); l5 = (l5 + 1)) {
			dsp->fVec1[l5] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l6;
		for (l6 = 0; (l6 < 2); l6 = (l6 + 1)) {
			dsp->fRec7[l6] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l7;
		for (l7 = 0; (l7 < 2); l7 = (l7 + 1)) {
			dsp->fRec8[l7] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l8;
		for (l8 = 0; (l8 < 2); l8 = (l8 + 1)) {
			dsp->fRec9[l8] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l9;
		for (l9 = 0; (l9 < 3); l9 = (l9 + 1)) {
			dsp->fRec6[l9] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l10;
		for (l10 = 0; (l10 < 2); l10 = (l10 + 1)) {
			dsp->fRec11[l10] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l11;
		for (l11 = 0; (l11 < 2); l11 = (l11 + 1)) {
			dsp->fRec12[l11] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l12;
		for (l12 = 0; (l12 < 3); l12 = (l12 + 1)) {
			dsp->fRec10[l12] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l13;
		for (l13 = 0; (l13 < 2); l13 = (l13 + 1)) {
			dsp->fRec14[l13] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l14;
		for (l14 = 0; (l14 < 2048); l14 = (l14 + 1)) {
			dsp->fVec2[l14] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l15;
		for (l15 = 0; (l15 < 2); l15 = (l15 + 1)) {
			dsp->fRec15[l15] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l16;
		for (l16 = 0; (l16 < 2); l16 = (l16 + 1)) {
			dsp->fRec13[l16] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l17;
		for (l17 = 0; (l17 < 2); l17 = (l17 + 1)) {
			dsp->fRec16[l17] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l18;
		for (l18 = 0; (l18 < 2); l18 = (l18 + 1)) {
			dsp->fRec17[l18] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l19;
		for (l19 = 0; (l19 < 2); l19 = (l19 + 1)) {
			dsp->fRec31[l19] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l20;
		for (l20 = 0; (l20 < 2); l20 = (l20 + 1)) {
			dsp->fRec34[l20] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l21;
		for (l21 = 0; (l21 < 2); l21 = (l21 + 1)) {
			dsp->fRec32[l21] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l22;
		for (l22 = 0; (l22 < 2); l22 = (l22 + 1)) {
			dsp->fRec33[l22] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l23;
		for (l23 = 0; (l23 < 3); l23 = (l23 + 1)) {
			dsp->fRec30[l23] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l24;
		for (l24 = 0; (l24 < 3); l24 = (l24 + 1)) {
			dsp->fRec29[l24] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l25;
		for (l25 = 0; (l25 < 3); l25 = (l25 + 1)) {
			dsp->fRec28[l25] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l26;
		for (l26 = 0; (l26 < 3); l26 = (l26 + 1)) {
			dsp->fRec27[l26] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l27;
		for (l27 = 0; (l27 < 3); l27 = (l27 + 1)) {
			dsp->fRec26[l27] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l28;
		for (l28 = 0; (l28 < 3); l28 = (l28 + 1)) {
			dsp->fRec25[l28] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l29;
		for (l29 = 0; (l29 < 3); l29 = (l29 + 1)) {
			dsp->fRec24[l29] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l30;
		for (l30 = 0; (l30 < 3); l30 = (l30 + 1)) {
			dsp->fRec23[l30] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l31;
		for (l31 = 0; (l31 < 3); l31 = (l31 + 1)) {
			dsp->fRec22[l31] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l32;
		for (l32 = 0; (l32 < 3); l32 = (l32 + 1)) {
			dsp->fRec21[l32] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l33;
		for (l33 = 0; (l33 < 3); l33 = (l33 + 1)) {
			dsp->fRec20[l33] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l34;
		for (l34 = 0; (l34 < 3); l34 = (l34 + 1)) {
			dsp->fRec19[l34] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l35;
		for (l35 = 0; (l35 < 65536); l35 = (l35 + 1)) {
			dsp->fRec3[l35] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l36;
		for (l36 = 0; (l36 < 2); l36 = (l36 + 1)) {
			dsp->fVec3[l36] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l37;
		for (l37 = 0; (l37 < 2); l37 = (l37 + 1)) {
			dsp->fRec0[l37] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l38;
		for (l38 = 0; (l38 < 131072); l38 = (l38 + 1)) {
			dsp->fVec4[l38] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l39;
		for (l39 = 0; (l39 < 3); l39 = (l39 + 1)) {
			dsp->fRec40[l39] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l40;
		for (l40 = 0; (l40 < 3); l40 = (l40 + 1)) {
			dsp->fRec41[l40] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l41;
		for (l41 = 0; (l41 < 2048); l41 = (l41 + 1)) {
			dsp->fVec5[l41] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l42;
		for (l42 = 0; (l42 < 2); l42 = (l42 + 1)) {
			dsp->fRec42[l42] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l43;
		for (l43 = 0; (l43 < 3); l43 = (l43 + 1)) {
			dsp->fRec55[l43] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l44;
		for (l44 = 0; (l44 < 3); l44 = (l44 + 1)) {
			dsp->fRec54[l44] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l45;
		for (l45 = 0; (l45 < 3); l45 = (l45 + 1)) {
			dsp->fRec53[l45] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l46;
		for (l46 = 0; (l46 < 3); l46 = (l46 + 1)) {
			dsp->fRec52[l46] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l47;
		for (l47 = 0; (l47 < 3); l47 = (l47 + 1)) {
			dsp->fRec51[l47] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l48;
		for (l48 = 0; (l48 < 3); l48 = (l48 + 1)) {
			dsp->fRec50[l48] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l49;
		for (l49 = 0; (l49 < 3); l49 = (l49 + 1)) {
			dsp->fRec49[l49] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l50;
		for (l50 = 0; (l50 < 3); l50 = (l50 + 1)) {
			dsp->fRec48[l50] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l51;
		for (l51 = 0; (l51 < 3); l51 = (l51 + 1)) {
			dsp->fRec47[l51] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l52;
		for (l52 = 0; (l52 < 3); l52 = (l52 + 1)) {
			dsp->fRec46[l52] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l53;
		for (l53 = 0; (l53 < 3); l53 = (l53 + 1)) {
			dsp->fRec45[l53] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l54;
		for (l54 = 0; (l54 < 3); l54 = (l54 + 1)) {
			dsp->fRec44[l54] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l55;
		for (l55 = 0; (l55 < 65536); l55 = (l55 + 1)) {
			dsp->fRec39[l55] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l56;
		for (l56 = 0; (l56 < 2); l56 = (l56 + 1)) {
			dsp->fVec6[l56] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l57;
		for (l57 = 0; (l57 < 2); l57 = (l57 + 1)) {
			dsp->fRec38[l57] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l58;
		for (l58 = 0; (l58 < 2); l58 = (l58 + 1)) {
			dsp->fRec37[l58] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l59;
		for (l59 = 0; (l59 < 2); l59 = (l59 + 1)) {
			dsp->fRec36[l59] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l60;
		for (l60 = 0; (l60 < 2); l60 = (l60 + 1)) {
			dsp->fRec35[l60] = 0.0f;
		}
	}
}

void instanceConstantsmydsp(mydsp* dsp, int sample_rate) {
	dsp->fSampleRate = sample_rate;
	dsp->fConst0 = fminf(192000.0f, fmaxf(1.0f, (float)dsp->fSampleRate));
	dsp->fConst1 = (44.0999985f / dsp->fConst0);
	dsp->fConst2 = (1.0f - dsp->fConst1);
	dsp->fConst3 = (3.14159274f / dsp->fConst0);
	float fConst4 = expf((0.0f - (314.159271f / dsp->fConst0)));
	dsp->fConst5 = mydsp_faustpower2_f(fConst4);
	dsp->fConst6 = (0.0f - (2.0f * fConst4));
	dsp->fConst7 = (1.0f / dsp->fConst0);
	dsp->fConst8 = (6.28318548f / dsp->fConst0);
	dsp->fConst9 = expf((0.0f - (2500.0f / dsp->fConst0)));
	dsp->fConst10 = (1.0f - dsp->fConst9);
	dsp->fConst11 = expf((0.0f - (1250.0f / dsp->fConst0)));
	dsp->fConst12 = expf((0.0f - (2.0f / dsp->fConst0)));
}

void instanceInitmydsp(mydsp* dsp, int sample_rate) {
	instanceConstantsmydsp(dsp, sample_rate);
	instanceResetUserInterfacemydsp(dsp);
	instanceClearmydsp(dsp);
}

void initmydsp(mydsp* dsp, int sample_rate) {
	classInitmydsp(sample_rate);
	instanceInitmydsp(dsp, sample_rate);
}
/*
void buildUserInterfacemydsp(mydsp* dsp, UIGlue* ui_interface) {
	ui_interface->openVerticalBox(ui_interface->uiInterface, "multifx2");
	ui_interface->openVerticalBox(ui_interface->uiInterface, "Compressor");
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw_comp", &dsp->fEntry0, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->closeBox(ui_interface->uiInterface);
	ui_interface->openVerticalBox(ui_interface->uiInterface, "Delay");
	ui_interface->addNumEntry(ui_interface->uiInterface, "delay", &dsp->fEntry6, (FAUSTFLOAT)0.25f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.00999999978f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "feedback", &dsp->fEntry5, (FAUSTFLOAT)0.5f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.00999999978f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw_echo", &dsp->fEntry4, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->closeBox(ui_interface->uiInterface);
	ui_interface->openVerticalBox(ui_interface->uiInterface, "Distortion");
	ui_interface->addNumEntry(ui_interface->uiInterface, "dr_drive", &dsp->fEntry3, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.00999999978f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "dr_offset", &dsp->fEntry2, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.00999999978f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw_drive", &dsp->fEntry1, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->closeBox(ui_interface->uiInterface);
	ui_interface->openVerticalBox(ui_interface->uiInterface, "Flanger");
	ui_interface->addNumEntry(ui_interface->uiInterface, "fl_delay", &dsp->fEntry18, (FAUSTFLOAT)10.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1024.0f, (FAUSTFLOAT)10.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "fl_depth", &dsp->fEntry19, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.00999999978f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "fl_fb", &dsp->fEntry17, (FAUSTFLOAT)0.5f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.00999999978f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw_flange", &dsp->fEntry8, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->closeBox(ui_interface->uiInterface);
	ui_interface->openVerticalBox(ui_interface->uiInterface, "HighPass");
	ui_interface->addNumEntry(ui_interface->uiInterface, "hp_Q", &dsp->fEntry16, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1000.0f, (FAUSTFLOAT)1.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "hp_freq", &dsp->fEntry15, (FAUSTFLOAT)100.0f, (FAUSTFLOAT)100.0f, (FAUSTFLOAT)20000.0f, (FAUSTFLOAT)100.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw_highpass", &dsp->fEntry9, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->closeBox(ui_interface->uiInterface);
	ui_interface->openVerticalBox(ui_interface->uiInterface, "LowPass");
	ui_interface->addNumEntry(ui_interface->uiInterface, "lp_Q", &dsp->fEntry14, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1000.0f, (FAUSTFLOAT)1.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "lp_freq", &dsp->fEntry13, (FAUSTFLOAT)20000.0f, (FAUSTFLOAT)100.0f, (FAUSTFLOAT)20000.0f, (FAUSTFLOAT)100.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw_lowpass", &dsp->fEntry10, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->closeBox(ui_interface->uiInterface);
	ui_interface->openVerticalBox(ui_interface->uiInterface, "Phaser");
	ui_interface->addNumEntry(ui_interface->uiInterface, "ph_depth", &dsp->fEntry20, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)2.0f, (FAUSTFLOAT)1.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "ph_ratio", &dsp->fEntry21, (FAUSTFLOAT)0.5f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.100000001f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "ph_speed", &dsp->fEntry22, (FAUSTFLOAT)0.5f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)120.0f, (FAUSTFLOAT)1.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw_phase", &dsp->fEntry7, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->closeBox(ui_interface->uiInterface);
	ui_interface->openVerticalBox(ui_interface->uiInterface, "Pitch");
	ui_interface->addNumEntry(ui_interface->uiInterface, "pi_semis", &dsp->fEntry12, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)-12.0f, (FAUSTFLOAT)12.0f, (FAUSTFLOAT)1.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw_pitch", &dsp->fEntry11, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->closeBox(ui_interface->uiInterface);
	ui_interface->closeBox(ui_interface->uiInterface);
}
*/
void computemydsp(mydsp* dsp, int count, FAUSTFLOAT* inputs, FAUSTFLOAT* outputs) {
	int iSlow0 = (int)(float)dsp->fEntry0;
	int iSlow1 = (int)(float)dsp->fEntry1;
	float fSlow2 = (dsp->fConst1 * (float)dsp->fEntry2);
	float fSlow3 = (dsp->fConst1 * (float)dsp->fEntry3);
	int iSlow4 = (int)(float)dsp->fEntry4;
	float fSlow5 = (dsp->fConst1 * (float)dsp->fEntry5);
	float fSlow6 = (dsp->fConst1 * (float)dsp->fEntry6);
	int iSlow7 = (int)(float)dsp->fEntry7;
	int iSlow8 = (int)(float)dsp->fEntry8;
	int iSlow9 = (int)(float)dsp->fEntry9;
	int iSlow10 = (int)(float)dsp->fEntry10;
	int iSlow11 = (int)(float)dsp->fEntry11;
	float fSlow12 = powf(2.0f, (0.0833333358f * (float)dsp->fEntry12));
	float fSlow13 = (dsp->fConst1 * (float)dsp->fEntry13);
	float fSlow14 = (dsp->fConst1 * (float)dsp->fEntry14);
	float fSlow15 = (dsp->fConst1 * (float)dsp->fEntry15);
	float fSlow16 = (dsp->fConst1 * (float)dsp->fEntry16);
	float fSlow17 = (dsp->fConst1 * (float)dsp->fEntry17);
	float fSlow18 = (dsp->fConst1 * (float)dsp->fEntry18);
	float fSlow19 = (dsp->fConst1 * (float)dsp->fEntry19);
	float fSlow20 = (dsp->fConst1 * (float)dsp->fEntry20);
	float fSlow21 = (dsp->fConst1 * (float)dsp->fEntry21);
	float fSlow22 = (dsp->fConst1 * (float)dsp->fEntry22);
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < count); i0 = (i0 + 2)) {
			dsp->iVec0[0] = 1;
			dsp->fRec1[0] = (fSlow2 + (dsp->fConst2 * dsp->fRec1[1]));
			dsp->fRec2[0] = (fSlow3 + (dsp->fConst2 * dsp->fRec2[1]));
			float fTemp0 = powf(10.0f, (2.0f * dsp->fRec2[0]));
			dsp->fRec4[0] = (fSlow5 + (dsp->fConst2 * dsp->fRec4[1]));
			dsp->fRec5[0] = (fSlow6 + (dsp->fConst2 * dsp->fRec5[1]));
			int iTemp1 = ((int)fminf(48000.0f, fmaxf(0.0f, (dsp->fConst0 * dsp->fRec5[0]))) + 1);
			float fTemp2 = (float)inputs[i0];
			float fTemp3 = (iSlow11 ? 0.0f : fTemp2);
			dsp->fVec1[(dsp->IOTA & 131071)] = fTemp3;
			dsp->fRec7[0] = fmodf(((dsp->fRec7[1] + 513.0f) - fSlow12), 512.0f);
			int iTemp4 = (int)dsp->fRec7[0];
			int iTemp5 = fmin(65537, fmax(0, iTemp4));
			float fTemp6 = floorf(dsp->fRec7[0]);
			float fTemp7 = (fTemp6 + (1.0f - dsp->fRec7[0]));
			float fTemp8 = (dsp->fRec7[0] - fTemp6);
			int iTemp9 = fmin(65537, fmax(0, (iTemp4 + 1)));
			float fTemp10 = fminf((0.001953125f * dsp->fRec7[0]), 1.0f);
			float fTemp11 = (dsp->fRec7[0] + 512.0f);
			int iTemp12 = (int)fTemp11;
			int iTemp13 = fmin(65537, fmax(0, iTemp12));
			float fTemp14 = floorf(fTemp11);
			float fTemp15 = (fTemp14 + (-511.0f - dsp->fRec7[0]));
			int iTemp16 = fmin(65537, fmax(0, (iTemp12 + 1)));
			float fTemp17 = (dsp->fRec7[0] + (512.0f - fTemp14));
			float fTemp18 = (1.0f - fTemp10);
			float fThen1 = ((((dsp->fVec1[((dsp->IOTA - iTemp5) & 131071)] * fTemp7) + (fTemp8 * dsp->fVec1[((dsp->IOTA - iTemp9) & 131071)])) * fTemp10) + (((dsp->fVec1[((dsp->IOTA - iTemp13) & 131071)] * fTemp15) + (dsp->fVec1[((dsp->IOTA - iTemp16) & 131071)] * fTemp17)) * fTemp18));
			float fTemp19 = (iSlow11 ? fTemp2 : fThen1);
			dsp->fRec8[0] = (fSlow13 + (dsp->fConst2 * dsp->fRec8[1]));
			float fTemp20 = tanf((dsp->fConst3 * dsp->fRec8[0]));
			float fTemp21 = (1.0f / fTemp20);
			dsp->fRec9[0] = (fSlow14 + (dsp->fConst2 * dsp->fRec9[1]));
			float fTemp22 = (1.0f / dsp->fRec9[0]);
			float fTemp23 = (((fTemp21 - fTemp22) / fTemp20) + 1.0f);
			float fTemp24 = (1.0f - (1.0f / mydsp_faustpower2_f(fTemp20)));
			float fTemp25 = (((fTemp22 + fTemp21) / fTemp20) + 1.0f);
			dsp->fRec6[0] = ((iSlow10 ? 0.0f : fTemp19) - (((dsp->fRec6[2] * fTemp23) + (2.0f * (dsp->fRec6[1] * fTemp24))) / fTemp25));
			float fThen3 = ((dsp->fRec6[2] + (dsp->fRec6[0] + (2.0f * dsp->fRec6[1]))) / fTemp25);
			float fTemp26 = (iSlow10 ? fTemp19 : fThen3);
			float fTemp27 = (iSlow9 ? 0.0f : fTemp26);
			dsp->fRec11[0] = (fSlow15 + (dsp->fConst2 * dsp->fRec11[1]));
			float fTemp28 = tanf((dsp->fConst3 * dsp->fRec11[0]));
			float fTemp29 = (1.0f / fTemp28);
			dsp->fRec12[0] = (fSlow16 + (dsp->fConst2 * dsp->fRec12[1]));
			float fTemp30 = (1.0f / dsp->fRec12[0]);
			float fTemp31 = (((fTemp29 - fTemp30) / fTemp28) + 1.0f);
			float fTemp32 = (1.0f - (1.0f / mydsp_faustpower2_f(fTemp28)));
			float fTemp33 = (((fTemp30 + fTemp29) / fTemp28) + 1.0f);
			dsp->fRec10[0] = (fTemp27 - (((dsp->fRec10[2] * fTemp31) + (2.0f * (dsp->fRec10[1] * fTemp32))) / fTemp33));
			float fThen5 = (fTemp27 - ((dsp->fRec10[2] + (dsp->fRec10[0] + (2.0f * dsp->fRec10[1]))) / fTemp33));
			float fTemp34 = (iSlow9 ? fTemp26 : fThen5);
			float fTemp35 = (iSlow8 ? 0.0f : fTemp34);
			dsp->fRec14[0] = (fSlow17 + (dsp->fConst2 * dsp->fRec14[1]));
			float fTemp36 = ((dsp->fRec14[0] * dsp->fRec13[1]) - fTemp35);
			dsp->fVec2[(dsp->IOTA & 2047)] = fTemp36;
			dsp->fRec15[0] = (fSlow18 + (dsp->fConst2 * dsp->fRec15[1]));
			int iTemp37 = (int)dsp->fRec15[0];
			int iTemp38 = fmin(1025, fmax(0, iTemp37));
			float fTemp39 = floorf(dsp->fRec15[0]);
			float fTemp40 = (fTemp39 + (1.0f - dsp->fRec15[0]));
			float fTemp41 = (dsp->fRec15[0] - fTemp39);
			int iTemp42 = fmin(1025, fmax(0, (iTemp37 + 1)));
			dsp->fRec13[0] = ((dsp->fVec2[((dsp->IOTA - iTemp38) & 2047)] * fTemp40) + (fTemp41 * dsp->fVec2[((dsp->IOTA - iTemp42) & 2047)]));
			dsp->fRec16[0] = (fSlow19 + (dsp->fConst2 * dsp->fRec16[1]));
			float fThen7 = (0.5f * (fTemp35 + (dsp->fRec13[0] * dsp->fRec16[0])));
			float fTemp43 = (iSlow8 ? fTemp34 : fThen7);
			float fTemp44 = (iSlow7 ? 0.0f : fTemp43);
			dsp->fRec17[0] = (fSlow20 + (dsp->fConst2 * dsp->fRec17[1]));
			float fTemp45 = (1.0f - (0.5f * dsp->fRec17[0]));
			dsp->fRec31[0] = (fSlow21 + (dsp->fConst2 * dsp->fRec31[1]));
			dsp->fRec34[0] = (fSlow22 + (dsp->fConst2 * dsp->fRec34[1]));
			float fTemp46 = (dsp->fConst8 * dsp->fRec34[0]);
			float fTemp47 = sinf(fTemp46);
			float fTemp48 = cosf(fTemp46);
			dsp->fRec32[0] = ((dsp->fRec33[1] * fTemp47) + (dsp->fRec32[1] * fTemp48));
			dsp->fRec33[0] = (((float)(1 - dsp->iVec0[1]) + (dsp->fRec33[1] * fTemp48)) - (fTemp47 * dsp->fRec32[1]));
			float fTemp49 = ((4712.38916f * (1.0f - dsp->fRec32[0])) + 3141.59277f);
			float fTemp50 = (dsp->fRec30[1] * cosf((dsp->fConst7 * (dsp->fRec31[0] * fTemp49))));
			dsp->fRec30[0] = (fTemp44 - ((dsp->fConst6 * fTemp50) + (dsp->fConst5 * dsp->fRec30[2])));
			float fTemp51 = mydsp_faustpower2_f(dsp->fRec31[0]);
			float fTemp52 = (dsp->fRec29[1] * cosf((dsp->fConst7 * (fTemp51 * fTemp49))));
			dsp->fRec29[0] = ((dsp->fConst5 * (dsp->fRec30[0] - dsp->fRec29[2])) + (dsp->fRec30[2] + (dsp->fConst6 * (fTemp50 - fTemp52))));
			float fTemp53 = mydsp_faustpower3_f(dsp->fRec31[0]);
			float fTemp54 = (dsp->fRec28[1] * cosf((dsp->fConst7 * (fTemp53 * fTemp49))));
			dsp->fRec28[0] = ((dsp->fConst5 * (dsp->fRec29[0] - dsp->fRec28[2])) + (dsp->fRec29[2] + (dsp->fConst6 * (fTemp52 - fTemp54))));
			float fTemp55 = mydsp_faustpower4_f(dsp->fRec31[0]);
			float fTemp56 = (dsp->fRec27[1] * cosf((dsp->fConst7 * (fTemp55 * fTemp49))));
			dsp->fRec27[0] = ((dsp->fConst5 * (dsp->fRec28[0] - dsp->fRec27[2])) + (dsp->fRec28[2] + (dsp->fConst6 * (fTemp54 - fTemp56))));
			float fTemp57 = mydsp_faustpower5_f(dsp->fRec31[0]);
			float fTemp58 = (dsp->fRec26[1] * cosf((dsp->fConst7 * (fTemp57 * fTemp49))));
			dsp->fRec26[0] = ((dsp->fConst5 * (dsp->fRec27[0] - dsp->fRec26[2])) + (dsp->fRec27[2] + (dsp->fConst6 * (fTemp56 - fTemp58))));
			float fTemp59 = mydsp_faustpower6_f(dsp->fRec31[0]);
			float fTemp60 = (dsp->fRec25[1] * cosf((dsp->fConst7 * (fTemp59 * fTemp49))));
			dsp->fRec25[0] = ((dsp->fConst5 * (dsp->fRec26[0] - dsp->fRec25[2])) + (dsp->fRec26[2] + (dsp->fConst6 * (fTemp58 - fTemp60))));
			float fTemp61 = mydsp_faustpower7_f(dsp->fRec31[0]);
			float fTemp62 = (dsp->fRec24[1] * cosf((dsp->fConst7 * (fTemp61 * fTemp49))));
			dsp->fRec24[0] = ((dsp->fConst5 * (dsp->fRec25[0] - dsp->fRec24[2])) + (dsp->fRec25[2] + (dsp->fConst6 * (fTemp60 - fTemp62))));
			float fTemp63 = mydsp_faustpower8_f(dsp->fRec31[0]);
			float fTemp64 = (dsp->fRec23[1] * cosf((dsp->fConst7 * (fTemp63 * fTemp49))));
			dsp->fRec23[0] = ((dsp->fConst5 * (dsp->fRec24[0] - dsp->fRec23[2])) + (dsp->fRec24[2] + (dsp->fConst6 * (fTemp62 - fTemp64))));
			float fTemp65 = mydsp_faustpower9_f(dsp->fRec31[0]);
			float fTemp66 = (dsp->fRec22[1] * cosf((dsp->fConst7 * (fTemp65 * fTemp49))));
			dsp->fRec22[0] = ((dsp->fConst5 * (dsp->fRec23[0] - dsp->fRec22[2])) + (dsp->fRec23[2] + (dsp->fConst6 * (fTemp64 - fTemp66))));
			float fTemp67 = mydsp_faustpower10_f(dsp->fRec31[0]);
			float fTemp68 = (dsp->fRec21[1] * cosf((dsp->fConst7 * (fTemp67 * fTemp49))));
			dsp->fRec21[0] = ((dsp->fConst5 * (dsp->fRec22[0] - dsp->fRec21[2])) + (dsp->fRec22[2] + (dsp->fConst6 * (fTemp66 - fTemp68))));
			float fTemp69 = mydsp_faustpower11_f(dsp->fRec31[0]);
			float fTemp70 = (dsp->fRec20[1] * cosf((dsp->fConst7 * (fTemp69 * fTemp49))));
			dsp->fRec20[0] = ((dsp->fConst5 * (dsp->fRec21[0] - dsp->fRec20[2])) + (dsp->fRec21[2] + (dsp->fConst6 * (fTemp68 - fTemp70))));
			float fTemp71 = mydsp_faustpower12_f(dsp->fRec31[0]);
			float fTemp72 = (dsp->fRec19[1] * cosf((dsp->fConst7 * (fTemp71 * fTemp49))));
			dsp->fRec19[0] = ((dsp->fConst5 * (dsp->fRec20[0] - dsp->fRec19[2])) + (dsp->fRec20[2] + (dsp->fConst6 * (fTemp70 - fTemp72))));
			float fRec18 = ((dsp->fConst5 * dsp->fRec19[0]) + ((dsp->fConst6 * fTemp72) + dsp->fRec19[2]));
			float fThen9 = ((fTemp44 * fTemp45) + (0.5f * (dsp->fRec17[0] * fRec18)));
			float fTemp73 = (iSlow7 ? fTemp43 : fThen9);
			dsp->fRec3[(dsp->IOTA & 65535)] = ((dsp->fRec4[0] * dsp->fRec3[((dsp->IOTA - iTemp1) & 65535)]) + (iSlow4 ? 0.0f : fTemp73));
			float fThen11 = dsp->fRec3[((dsp->IOTA - 0) & 65535)];
			float fTemp74 = (iSlow4 ? fTemp73 : fThen11);
			float fTemp75 = fmaxf(-1.0f, fminf(1.0f, (dsp->fRec1[0] + (fTemp0 * (iSlow1 ? 0.0f : fTemp74)))));
			float fTemp76 = (fTemp75 * (1.0f - (0.333333343f * mydsp_faustpower2_f(fTemp75))));
			dsp->fVec3[0] = fTemp76;
			dsp->fRec0[0] = (((0.995000005f * dsp->fRec0[1]) + fTemp76) - dsp->fVec3[1]);
			float fTemp77 = (iSlow1 ? fTemp74 : dsp->fRec0[0]);
			float fTemp78 = (iSlow0 ? 0.0f : fTemp77);
			float fTemp79 = (float)inputs[i0+1];
			float fTemp80 = (iSlow11 ? 0.0f : fTemp79);
			dsp->fVec4[(dsp->IOTA & 131071)] = fTemp80;
			float fThen16 = ((fTemp10 * ((dsp->fVec4[((dsp->IOTA - iTemp5) & 131071)] * fTemp7) + (fTemp8 * dsp->fVec4[((dsp->IOTA - iTemp9) & 131071)]))) + (fTemp18 * ((dsp->fVec4[((dsp->IOTA - iTemp13) & 131071)] * fTemp15) + (dsp->fVec4[((dsp->IOTA - iTemp16) & 131071)] * fTemp17))));
			float fTemp81 = (iSlow11 ? fTemp79 : fThen16);
			dsp->fRec40[0] = ((iSlow10 ? 0.0f : fTemp81) - (((fTemp23 * dsp->fRec40[2]) + (2.0f * (fTemp24 * dsp->fRec40[1]))) / fTemp25));
			float fThen18 = ((dsp->fRec40[2] + (dsp->fRec40[0] + (2.0f * dsp->fRec40[1]))) / fTemp25);
			float fTemp82 = (iSlow10 ? fTemp81 : fThen18);
			float fTemp83 = (iSlow9 ? 0.0f : fTemp82);
			dsp->fRec41[0] = (fTemp83 - (((fTemp31 * dsp->fRec41[2]) + (2.0f * (fTemp32 * dsp->fRec41[1]))) / fTemp33));
			float fThen20 = (fTemp83 - ((dsp->fRec41[2] + (dsp->fRec41[0] + (2.0f * dsp->fRec41[1]))) / fTemp33));
			float fTemp84 = (iSlow9 ? fTemp82 : fThen20);
			float fTemp85 = (iSlow8 ? 0.0f : fTemp84);
			float fTemp86 = ((dsp->fRec14[0] * dsp->fRec42[1]) - fTemp85);
			dsp->fVec5[(dsp->IOTA & 2047)] = fTemp86;
			dsp->fRec42[0] = ((fTemp40 * dsp->fVec5[((dsp->IOTA - iTemp38) & 2047)]) + (fTemp41 * dsp->fVec5[((dsp->IOTA - iTemp42) & 2047)]));
			float fThen22 = (0.5f * (fTemp85 + (dsp->fRec16[0] * dsp->fRec42[0])));
			float fTemp87 = (iSlow8 ? fTemp84 : fThen22);
			float fTemp88 = (iSlow7 ? 0.0f : fTemp87);
			float fTemp89 = ((4712.38916f * (1.0f - dsp->fRec33[0])) + 3141.59277f);
			float fTemp90 = (dsp->fRec55[1] * cosf((dsp->fConst7 * (dsp->fRec31[0] * fTemp89))));
			dsp->fRec55[0] = (fTemp88 - ((dsp->fConst6 * fTemp90) + (dsp->fConst5 * dsp->fRec55[2])));
			float fTemp91 = (dsp->fRec54[1] * cosf((dsp->fConst7 * (fTemp51 * fTemp89))));
			dsp->fRec54[0] = ((dsp->fConst5 * (dsp->fRec55[0] - dsp->fRec54[2])) + (dsp->fRec55[2] + (dsp->fConst6 * (fTemp90 - fTemp91))));
			float fTemp92 = (dsp->fRec53[1] * cosf((dsp->fConst7 * (fTemp53 * fTemp89))));
			dsp->fRec53[0] = ((dsp->fConst5 * (dsp->fRec54[0] - dsp->fRec53[2])) + (dsp->fRec54[2] + (dsp->fConst6 * (fTemp91 - fTemp92))));
			float fTemp93 = (dsp->fRec52[1] * cosf((dsp->fConst7 * (fTemp55 * fTemp89))));
			dsp->fRec52[0] = ((dsp->fConst5 * (dsp->fRec53[0] - dsp->fRec52[2])) + (dsp->fRec53[2] + (dsp->fConst6 * (fTemp92 - fTemp93))));
			float fTemp94 = (dsp->fRec51[1] * cosf((dsp->fConst7 * (fTemp57 * fTemp89))));
			dsp->fRec51[0] = ((dsp->fConst5 * (dsp->fRec52[0] - dsp->fRec51[2])) + (dsp->fRec52[2] + (dsp->fConst6 * (fTemp93 - fTemp94))));
			float fTemp95 = (dsp->fRec50[1] * cosf((dsp->fConst7 * (fTemp59 * fTemp89))));
			dsp->fRec50[0] = ((dsp->fConst5 * (dsp->fRec51[0] - dsp->fRec50[2])) + (dsp->fRec51[2] + (dsp->fConst6 * (fTemp94 - fTemp95))));
			float fTemp96 = (dsp->fRec49[1] * cosf((dsp->fConst7 * (fTemp61 * fTemp89))));
			dsp->fRec49[0] = ((dsp->fConst5 * (dsp->fRec50[0] - dsp->fRec49[2])) + (dsp->fRec50[2] + (dsp->fConst6 * (fTemp95 - fTemp96))));
			float fTemp97 = (dsp->fRec48[1] * cosf((dsp->fConst7 * (fTemp63 * fTemp89))));
			dsp->fRec48[0] = ((dsp->fConst5 * (dsp->fRec49[0] - dsp->fRec48[2])) + (dsp->fRec49[2] + (dsp->fConst6 * (fTemp96 - fTemp97))));
			float fTemp98 = (dsp->fRec47[1] * cosf((dsp->fConst7 * (fTemp65 * fTemp89))));
			dsp->fRec47[0] = ((dsp->fConst5 * (dsp->fRec48[0] - dsp->fRec47[2])) + (dsp->fRec48[2] + (dsp->fConst6 * (fTemp97 - fTemp98))));
			float fTemp99 = (dsp->fRec46[1] * cosf((dsp->fConst7 * (fTemp67 * fTemp89))));
			dsp->fRec46[0] = ((dsp->fConst5 * (dsp->fRec47[0] - dsp->fRec46[2])) + (dsp->fRec47[2] + (dsp->fConst6 * (fTemp98 - fTemp99))));
			float fTemp100 = (dsp->fRec45[1] * cosf((dsp->fConst7 * (fTemp69 * fTemp89))));
			dsp->fRec45[0] = ((dsp->fConst5 * (dsp->fRec46[0] - dsp->fRec45[2])) + (dsp->fRec46[2] + (dsp->fConst6 * (fTemp99 - fTemp100))));
			float fTemp101 = (dsp->fRec44[1] * cosf((dsp->fConst7 * (fTemp71 * fTemp89))));
			dsp->fRec44[0] = ((dsp->fConst5 * (dsp->fRec45[0] - dsp->fRec44[2])) + (dsp->fRec45[2] + (dsp->fConst6 * (fTemp100 - fTemp101))));
			float fRec43 = ((dsp->fConst5 * dsp->fRec44[0]) + ((dsp->fConst6 * fTemp101) + dsp->fRec44[2]));
			float fThen24 = ((fTemp45 * fTemp88) + (0.5f * (dsp->fRec17[0] * fRec43)));
			float fTemp102 = (iSlow7 ? fTemp87 : fThen24);
			dsp->fRec39[(dsp->IOTA & 65535)] = ((dsp->fRec4[0] * dsp->fRec39[((dsp->IOTA - iTemp1) & 65535)]) + (iSlow4 ? 0.0f : fTemp102));
			float fThen26 = dsp->fRec39[((dsp->IOTA - 0) & 65535)];
			float fTemp103 = (iSlow4 ? fTemp102 : fThen26);
			float fTemp104 = fmaxf(-1.0f, fminf(1.0f, (dsp->fRec1[0] + (fTemp0 * (iSlow1 ? 0.0f : fTemp103)))));
			float fTemp105 = (fTemp104 * (1.0f - (0.333333343f * mydsp_faustpower2_f(fTemp104))));
			dsp->fVec6[0] = fTemp105;
			dsp->fRec38[0] = (((0.995000005f * dsp->fRec38[1]) + fTemp105) - dsp->fVec6[1]);
			float fTemp106 = (iSlow1 ? fTemp103 : dsp->fRec38[0]);
			float fTemp107 = (iSlow0 ? 0.0f : fTemp106);
			float fTemp108 = fabsf((fabsf(fTemp78) + fabsf(fTemp107)));
			float fTemp109 = ((dsp->fRec36[1] > fTemp108) ? dsp->fConst12 : dsp->fConst11);
			dsp->fRec37[0] = ((dsp->fRec37[1] * fTemp109) + (fTemp108 * (1.0f - fTemp109)));
			dsp->fRec36[0] = dsp->fRec37[0];
			dsp->fRec35[0] = ((dsp->fConst9 * dsp->fRec35[1]) + (dsp->fConst10 * (0.0f - (0.75f * fmaxf(((20.0f * log10f(fmaxf(1.17549435e-38f, dsp->fRec36[0]))) + 6.0f), 0.0f)))));
			float fTemp110 = powf(10.0f, (0.0500000007f * dsp->fRec35[0]));
			float fThen31 = (fTemp78 * fTemp110);
			outputs[i0] = (FAUSTFLOAT)(iSlow0 ? fTemp77 : fThen31);
			float fThen32 = (fTemp107 * fTemp110);
			outputs[i0+1] = (FAUSTFLOAT)(iSlow0 ? fTemp106 : fThen32);
			dsp->iVec0[1] = dsp->iVec0[0];
			dsp->fRec1[1] = dsp->fRec1[0];
			dsp->fRec2[1] = dsp->fRec2[0];
			dsp->fRec4[1] = dsp->fRec4[0];
			dsp->fRec5[1] = dsp->fRec5[0];
			dsp->IOTA = (dsp->IOTA + 1);
			dsp->fRec7[1] = dsp->fRec7[0];
			dsp->fRec8[1] = dsp->fRec8[0];
			dsp->fRec9[1] = dsp->fRec9[0];
			dsp->fRec6[2] = dsp->fRec6[1];
			dsp->fRec6[1] = dsp->fRec6[0];
			dsp->fRec11[1] = dsp->fRec11[0];
			dsp->fRec12[1] = dsp->fRec12[0];
			dsp->fRec10[2] = dsp->fRec10[1];
			dsp->fRec10[1] = dsp->fRec10[0];
			dsp->fRec14[1] = dsp->fRec14[0];
			dsp->fRec15[1] = dsp->fRec15[0];
			dsp->fRec13[1] = dsp->fRec13[0];
			dsp->fRec16[1] = dsp->fRec16[0];
			dsp->fRec17[1] = dsp->fRec17[0];
			dsp->fRec31[1] = dsp->fRec31[0];
			dsp->fRec34[1] = dsp->fRec34[0];
			dsp->fRec32[1] = dsp->fRec32[0];
			dsp->fRec33[1] = dsp->fRec33[0];
			dsp->fRec30[2] = dsp->fRec30[1];
			dsp->fRec30[1] = dsp->fRec30[0];
			dsp->fRec29[2] = dsp->fRec29[1];
			dsp->fRec29[1] = dsp->fRec29[0];
			dsp->fRec28[2] = dsp->fRec28[1];
			dsp->fRec28[1] = dsp->fRec28[0];
			dsp->fRec27[2] = dsp->fRec27[1];
			dsp->fRec27[1] = dsp->fRec27[0];
			dsp->fRec26[2] = dsp->fRec26[1];
			dsp->fRec26[1] = dsp->fRec26[0];
			dsp->fRec25[2] = dsp->fRec25[1];
			dsp->fRec25[1] = dsp->fRec25[0];
			dsp->fRec24[2] = dsp->fRec24[1];
			dsp->fRec24[1] = dsp->fRec24[0];
			dsp->fRec23[2] = dsp->fRec23[1];
			dsp->fRec23[1] = dsp->fRec23[0];
			dsp->fRec22[2] = dsp->fRec22[1];
			dsp->fRec22[1] = dsp->fRec22[0];
			dsp->fRec21[2] = dsp->fRec21[1];
			dsp->fRec21[1] = dsp->fRec21[0];
			dsp->fRec20[2] = dsp->fRec20[1];
			dsp->fRec20[1] = dsp->fRec20[0];
			dsp->fRec19[2] = dsp->fRec19[1];
			dsp->fRec19[1] = dsp->fRec19[0];
			dsp->fVec3[1] = dsp->fVec3[0];
			dsp->fRec0[1] = dsp->fRec0[0];
			dsp->fRec40[2] = dsp->fRec40[1];
			dsp->fRec40[1] = dsp->fRec40[0];
			dsp->fRec41[2] = dsp->fRec41[1];
			dsp->fRec41[1] = dsp->fRec41[0];
			dsp->fRec42[1] = dsp->fRec42[0];
			dsp->fRec55[2] = dsp->fRec55[1];
			dsp->fRec55[1] = dsp->fRec55[0];
			dsp->fRec54[2] = dsp->fRec54[1];
			dsp->fRec54[1] = dsp->fRec54[0];
			dsp->fRec53[2] = dsp->fRec53[1];
			dsp->fRec53[1] = dsp->fRec53[0];
			dsp->fRec52[2] = dsp->fRec52[1];
			dsp->fRec52[1] = dsp->fRec52[0];
			dsp->fRec51[2] = dsp->fRec51[1];
			dsp->fRec51[1] = dsp->fRec51[0];
			dsp->fRec50[2] = dsp->fRec50[1];
			dsp->fRec50[1] = dsp->fRec50[0];
			dsp->fRec49[2] = dsp->fRec49[1];
			dsp->fRec49[1] = dsp->fRec49[0];
			dsp->fRec48[2] = dsp->fRec48[1];
			dsp->fRec48[1] = dsp->fRec48[0];
			dsp->fRec47[2] = dsp->fRec47[1];
			dsp->fRec47[1] = dsp->fRec47[0];
			dsp->fRec46[2] = dsp->fRec46[1];
			dsp->fRec46[1] = dsp->fRec46[0];
			dsp->fRec45[2] = dsp->fRec45[1];
			dsp->fRec45[1] = dsp->fRec45[0];
			dsp->fRec44[2] = dsp->fRec44[1];
			dsp->fRec44[1] = dsp->fRec44[0];
			dsp->fVec6[1] = dsp->fVec6[0];
			dsp->fRec38[1] = dsp->fRec38[0];
			dsp->fRec37[1] = dsp->fRec37[0];
			dsp->fRec36[1] = dsp->fRec36[0];
			dsp->fRec35[1] = dsp->fRec35[0];
		}
	}
}

#ifdef __cplusplus
}
#endif

#endif
