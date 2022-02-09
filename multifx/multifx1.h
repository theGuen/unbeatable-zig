/* ------------------------------------------------------------
name: "multifx"
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
#include "CInterface.h"

static float mydsp_faustpower2_f(float value) {
	return (value * value);
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
	FAUSTFLOAT fEntry2;
	FAUSTFLOAT fEntry3;
	int fSampleRate;
	float fConst0;
	float fConst1;
	FAUSTFLOAT fEntry4;
	float fConst2;
	float fRec2[2];
	FAUSTFLOAT fEntry5;
	float fRec3[2];
	int IOTA;
	float fRec1[65536];
	float fConst3;
	FAUSTFLOAT fEntry6;
	float fRec4[2];
	FAUSTFLOAT fEntry7;
	float fRec5[2];
	float fRec0[3];
	FAUSTFLOAT fEntry8;
	float fRec7[2];
	float fVec0[2048];
	FAUSTFLOAT fEntry9;
	float fRec8[2];
	float fRec6[2];
	FAUSTFLOAT fEntry10;
	float fRec9[2];
	float fConst4;
	float fConst5;
	float fRec14[65536];
	float fRec13[3];
	float fVec1[2048];
	float fRec15[2];
	float fConst6;
	float fConst7;
	float fRec12[2];
	float fRec11[2];
	float fRec10[2];
} mydsp;

mydsp* newmydsp() { 
	mydsp* dsp = (mydsp*)calloc(1, sizeof(mydsp));
	return dsp;
}

void deletemydsp(mydsp* dsp) { 
	free(dsp);
}

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
	dsp->fEntry2 = (FAUSTFLOAT)1.0f;
	dsp->fEntry3 = (FAUSTFLOAT)1.0f;
	dsp->fEntry4 = (FAUSTFLOAT)0.5f;
	dsp->fEntry5 = (FAUSTFLOAT)0.25f;
	dsp->fEntry6 = (FAUSTFLOAT)2000.0f;
	dsp->fEntry7 = (FAUSTFLOAT)1.0f;
	dsp->fEntry8 = (FAUSTFLOAT)0.5f;
	dsp->fEntry9 = (FAUSTFLOAT)10.0f;
	dsp->fEntry10 = (FAUSTFLOAT)0.0f;
}

void instanceClearmydsp(mydsp* dsp) {
	/* C99 loop */
	{
		int l0;
		for (l0 = 0; (l0 < 2); l0 = (l0 + 1)) {
			dsp->fRec2[l0] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l1;
		for (l1 = 0; (l1 < 2); l1 = (l1 + 1)) {
			dsp->fRec3[l1] = 0.0f;
		}
	}
	dsp->IOTA = 0;
	/* C99 loop */
	{
		int l2;
		for (l2 = 0; (l2 < 65536); l2 = (l2 + 1)) {
			dsp->fRec1[l2] = 0.0f;
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
	/* C99 loop */
	{
		int l5;
		for (l5 = 0; (l5 < 3); l5 = (l5 + 1)) {
			dsp->fRec0[l5] = 0.0f;
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
		for (l7 = 0; (l7 < 2048); l7 = (l7 + 1)) {
			dsp->fVec0[l7] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l8;
		for (l8 = 0; (l8 < 2); l8 = (l8 + 1)) {
			dsp->fRec8[l8] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l9;
		for (l9 = 0; (l9 < 2); l9 = (l9 + 1)) {
			dsp->fRec6[l9] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l10;
		for (l10 = 0; (l10 < 2); l10 = (l10 + 1)) {
			dsp->fRec9[l10] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l11;
		for (l11 = 0; (l11 < 65536); l11 = (l11 + 1)) {
			dsp->fRec14[l11] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l12;
		for (l12 = 0; (l12 < 3); l12 = (l12 + 1)) {
			dsp->fRec13[l12] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l13;
		for (l13 = 0; (l13 < 2048); l13 = (l13 + 1)) {
			dsp->fVec1[l13] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l14;
		for (l14 = 0; (l14 < 2); l14 = (l14 + 1)) {
			dsp->fRec15[l14] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l15;
		for (l15 = 0; (l15 < 2); l15 = (l15 + 1)) {
			dsp->fRec12[l15] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l16;
		for (l16 = 0; (l16 < 2); l16 = (l16 + 1)) {
			dsp->fRec11[l16] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l17;
		for (l17 = 0; (l17 < 2); l17 = (l17 + 1)) {
			dsp->fRec10[l17] = 0.0f;
		}
	}
}

void instanceConstantsmydsp(mydsp* dsp, int sample_rate) {
	dsp->fSampleRate = sample_rate;
	dsp->fConst0 = fminf(192000.0f, fmaxf(1.0f, (float)dsp->fSampleRate));
	dsp->fConst1 = (44.0999985f / dsp->fConst0);
	dsp->fConst2 = (1.0f - dsp->fConst1);
	dsp->fConst3 = (3.14159274f / dsp->fConst0);
	dsp->fConst4 = expf((0.0f - (2500.0f / dsp->fConst0)));
	dsp->fConst5 = (1.0f - dsp->fConst4);
	dsp->fConst6 = expf((0.0f - (1250.0f / dsp->fConst0)));
	dsp->fConst7 = expf((0.0f - (2.0f / dsp->fConst0)));
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

void buildUserInterfacemydsp(mydsp* dsp, UIGlue* ui_interface) {
	ui_interface->openVerticalBox(ui_interface->uiInterface, "delay");
	ui_interface->addNumEntry(ui_interface->uiInterface, "s1", &dsp->fEntry3, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "delay", &dsp->fEntry5, (FAUSTFLOAT)0.25f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.00999999978f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "feedback", &dsp->fEntry4, (FAUSTFLOAT)0.5f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.00999999978f);
	ui_interface->closeBox(ui_interface->uiInterface);

	ui_interface->openVerticalBox(ui_interface->uiInterface, "filter");
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw2", &dsp->fEntry2, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "frequency", &dsp->fEntry6, (FAUSTFLOAT)20000.0f, (FAUSTFLOAT)100.0f, (FAUSTFLOAT)20000.0f, (FAUSTFLOAT)100.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "Q", &dsp->fEntry7, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1000.0f, (FAUSTFLOAT)1.0f);
	ui_interface->closeBox(ui_interface->uiInterface);

	ui_interface->openVerticalBox(ui_interface->uiInterface, "flanger");
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw3", &dsp->fEntry1, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "fl_delay", &dsp->fEntry9, (FAUSTFLOAT)10.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1024.0f, (FAUSTFLOAT)10.0f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "fl_depth", &dsp->fEntry10, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.00999999978f);
	ui_interface->addNumEntry(ui_interface->uiInterface, "fl_fb", &dsp->fEntry8, (FAUSTFLOAT)0.5f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.00999999978f);
	ui_interface->closeBox(ui_interface->uiInterface);

	ui_interface->openVerticalBox(ui_interface->uiInterface, "limiter");
	ui_interface->addNumEntry(ui_interface->uiInterface, "sw4", &dsp->fEntry0, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)0.0f, (FAUSTFLOAT)1.0f, (FAUSTFLOAT)1.0f);
	ui_interface->closeBox(ui_interface->uiInterface);
}

void computemydsp(mydsp* dsp, int count, FAUSTFLOAT* inputs, FAUSTFLOAT* outputs) {
	int iSlow0 = (int)(float)dsp->fEntry0;
	int iSlow1 = (int)(float)dsp->fEntry1;
	int iSlow2 = (int)(float)dsp->fEntry2;
	int iSlow3 = (int)(float)dsp->fEntry3;
	float fSlow4 = (dsp->fConst1 * (float)dsp->fEntry4);
	float fSlow5 = (dsp->fConst1 * (float)dsp->fEntry5);
	float fSlow6 = (dsp->fConst1 * (float)dsp->fEntry6);
	float fSlow7 = (dsp->fConst1 * (float)dsp->fEntry7);
	float fSlow8 = (dsp->fConst1 * (float)dsp->fEntry8);
	float fSlow9 = (dsp->fConst1 * (float)dsp->fEntry9);
	float fSlow10 = (dsp->fConst1 * (float)dsp->fEntry10);
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < count); i0 = (i0 + 2)) {
			float fTemp0 = (float)inputs[i0];
			dsp->fRec2[0] = (fSlow4 + (dsp->fConst2 * dsp->fRec2[1]));
			dsp->fRec3[0] = (fSlow5 + (dsp->fConst2 * dsp->fRec3[1]));
			int iTemp1 = ((int)fminf(44100.0f, fmaxf(0.0f, (dsp->fConst0 * dsp->fRec3[0]))) + 1);
			dsp->fRec1[(dsp->IOTA & 65535)] = ((iSlow3 ? 0.0f : fTemp0) + (dsp->fRec2[0] * dsp->fRec1[((dsp->IOTA - iTemp1) & 65535)]));
			float fThen1 = dsp->fRec1[((dsp->IOTA - 0) & 65535)];
			float fTemp2 = (iSlow3 ? fTemp0 : fThen1);
			dsp->fRec4[0] = (fSlow6 + (dsp->fConst2 * dsp->fRec4[1]));
			float fTemp3 = tanf((dsp->fConst3 * dsp->fRec4[0]));
			float fTemp4 = (1.0f / fTemp3);
			dsp->fRec5[0] = (fSlow7 + (dsp->fConst2 * dsp->fRec5[1]));
			float fTemp5 = (1.0f / dsp->fRec5[0]);
			float fTemp6 = (((fTemp4 - fTemp5) / fTemp3) + 1.0f);
			float fTemp7 = (1.0f - (1.0f / mydsp_faustpower2_f(fTemp3)));
			float fTemp8 = (((fTemp5 + fTemp4) / fTemp3) + 1.0f);
			dsp->fRec0[0] = ((iSlow2 ? 0.0f : fTemp2) - (((dsp->fRec0[2] * fTemp6) + (2.0f * (dsp->fRec0[1] * fTemp7))) / fTemp8));
			float fThen3 = ((dsp->fRec0[2] + (dsp->fRec0[0] + (2.0f * dsp->fRec0[1]))) / fTemp8);
			float fTemp9 = (iSlow2 ? fTemp2 : fThen3);
			float fTemp10 = (iSlow1 ? 0.0f : fTemp9);
			dsp->fRec7[0] = (fSlow8 + (dsp->fConst2 * dsp->fRec7[1]));
			float fTemp11 = ((dsp->fRec7[0] * dsp->fRec6[1]) - fTemp10);
			dsp->fVec0[(dsp->IOTA & 2047)] = fTemp11;
			dsp->fRec8[0] = (fSlow9 + (dsp->fConst2 * dsp->fRec8[1]));
			int iTemp12 = (int)dsp->fRec8[0];
			int iTemp13 = fmin(1025, fmax(0, iTemp12));
			float fTemp14 = floorf(dsp->fRec8[0]);
			float fTemp15 = (fTemp14 + (1.0f - dsp->fRec8[0]));
			float fTemp16 = (dsp->fRec8[0] - fTemp14);
			int iTemp17 = fmin(1025, fmax(0, (iTemp12 + 1)));
			dsp->fRec6[0] = ((dsp->fVec0[((dsp->IOTA - iTemp13) & 2047)] * fTemp15) + (fTemp16 * dsp->fVec0[((dsp->IOTA - iTemp17) & 2047)]));
			dsp->fRec9[0] = (fSlow10 + (dsp->fConst2 * dsp->fRec9[1]));
			float fThen5 = (0.5f * (fTemp10 + (dsp->fRec6[0] * dsp->fRec9[0])));
			float fTemp18 = (iSlow1 ? fTemp9 : fThen5);
			float fTemp19 = (iSlow0 ? 0.0f : fTemp18);
			float fTemp20 = (float)inputs[i0+1];
			dsp->fRec14[(dsp->IOTA & 65535)] = ((iSlow3 ? 0.0f : fTemp20) + (dsp->fRec2[0] * dsp->fRec14[((dsp->IOTA - iTemp1) & 65535)]));
			float fThen8 = dsp->fRec14[((dsp->IOTA - 0) & 65535)];
			float fTemp21 = (iSlow3 ? fTemp20 : fThen8);
			dsp->fRec13[0] = ((iSlow2 ? 0.0f : fTemp21) - (((fTemp6 * dsp->fRec13[2]) + (2.0f * (fTemp7 * dsp->fRec13[1]))) / fTemp8));
			float fThen10 = ((dsp->fRec13[2] + (dsp->fRec13[0] + (2.0f * dsp->fRec13[1]))) / fTemp8);
			float fTemp22 = (iSlow2 ? fTemp21 : fThen10);
			float fTemp23 = (iSlow1 ? 0.0f : fTemp22);
			float fTemp24 = ((dsp->fRec7[0] * dsp->fRec15[1]) - fTemp23);
			dsp->fVec1[(dsp->IOTA & 2047)] = fTemp24;
			dsp->fRec15[0] = ((fTemp15 * dsp->fVec1[((dsp->IOTA - iTemp13) & 2047)]) + (fTemp16 * dsp->fVec1[((dsp->IOTA - iTemp17) & 2047)]));
			float fThen12 = (0.5f * (fTemp23 + (dsp->fRec9[0] * dsp->fRec15[0])));
			float fTemp25 = (iSlow1 ? fTemp22 : fThen12);
			float fTemp26 = (iSlow0 ? 0.0f : fTemp25);
			float fTemp27 = fabsf((fabsf(fTemp19) + fabsf(fTemp26)));
			float fTemp28 = ((dsp->fRec11[1] > fTemp27) ? dsp->fConst7 : dsp->fConst6);
			dsp->fRec12[0] = ((dsp->fRec12[1] * fTemp28) + (fTemp27 * (1.0f - fTemp28)));
			dsp->fRec11[0] = dsp->fRec12[0];
			dsp->fRec10[0] = ((dsp->fConst4 * dsp->fRec10[1]) + (dsp->fConst5 * (0.0f - (0.75f * fmaxf(((20.0f * log10f(fmaxf(1.17549435e-38f, dsp->fRec11[0]))) + 6.0f), 0.0f)))));
			float fTemp29 = powf(10.0f, (0.0500000007f * dsp->fRec10[0]));
			float fThen15 = (fTemp19 * fTemp29);
			outputs[i0] = (FAUSTFLOAT)(iSlow0 ? fTemp18 : fThen15);
			float fThen16 = (fTemp26 * fTemp29);
			outputs[i0+1] = (FAUSTFLOAT)(iSlow0 ? fTemp25 : fThen16);
			dsp->fRec2[1] = dsp->fRec2[0];
			dsp->fRec3[1] = dsp->fRec3[0];
			dsp->IOTA = (dsp->IOTA + 1);
			dsp->fRec4[1] = dsp->fRec4[0];
			dsp->fRec5[1] = dsp->fRec5[0];
			dsp->fRec0[2] = dsp->fRec0[1];
			dsp->fRec0[1] = dsp->fRec0[0];
			dsp->fRec7[1] = dsp->fRec7[0];
			dsp->fRec8[1] = dsp->fRec8[0];
			dsp->fRec6[1] = dsp->fRec6[0];
			dsp->fRec9[1] = dsp->fRec9[0];
			dsp->fRec13[2] = dsp->fRec13[1];
			dsp->fRec13[1] = dsp->fRec13[0];
			dsp->fRec15[1] = dsp->fRec15[0];
			dsp->fRec12[1] = dsp->fRec12[0];
			dsp->fRec11[1] = dsp->fRec11[0];
			dsp->fRec10[1] = dsp->fRec10[0];
		}
	}
}

#ifdef __cplusplus
}
#endif

#endif