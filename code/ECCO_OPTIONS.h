C $Header: /u/gcmpack/MITgcm_contrib/gael/verification/ECCO_v4_r2/code/ECCO_OPTIONS.h,v 1.5 2016/09/21 19:20:34 gforget Exp $
C $Name:  $

CBOP
C !ROUTINE: ECCO_OPTIONS.h
C !INTERFACE:
C #include "ECCO_OPTIONS.h"

C !DESCRIPTION:
C *==================================================================*
C | CPP options file for ECCO (ecco) package:
C | Control which optional features to compile in this package code.
C *==================================================================*
CEOP

#ifndef ECCO_OPTIONS_H
#define ECCO_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_ECCO
#ifdef ECCO_CPPOPTIONS_H

C-- When multi-package option-file ECCO_CPPOPTIONS.h is used (directly included
C   in CPP_OPTIONS.h), this option file is left empty since all options that
C   are specific to this package are assumed to be set in ECCO_CPPOPTIONS.h

#else /* ndef ECCO_CPPOPTIONS_H */

C-- Package-specific Options & Macros go here

C allow for generic cost function and integral terms
#define ALLOW_GENCOST_CONTRIBUTION
C allow for 3 dimensional generic terms
#define ALLOW_GENCOST3D

C include global mean steric sea level correction
#define ALLOW_PSBAR_STERIC
C allow for near-shore and high-latitude altimetry
#define ALLOW_SHALLOW_ALTIMETRY
#define ALLOW_HIGHLAT_ALTIMETRY

C allow for In-Situ Profiles cost function contribution
#define ALLOW_PROFILES_CONTRIBUTION

C cost function output format
#define ALLOW_ECCO_OLD_FC_PRINT

C re-activate deprecated codes (just in case ... but not recommended)
#undef ECCO_CTRL_DEPRECATED

#endif /* ndef ECCO_CPPOPTIONS_H */
#endif /* ALLOW_ECCO */
#endif /* ECCO_OPTIONS_H */

