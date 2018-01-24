C $Header$
C $Name$

#ifdef ALLOW_GUD

CBOP
C    !ROUTINE: GUD_SIZE.h
C    !INTERFACE:
C #include GUD_SIZE.h

C    !DESCRIPTION:
C Contains dimensions and index ranges for cell model.

      integer nplank, nGroup, nlam, nopt
      integer nPhoto
      integer iMinBact, iMaxBact
      integer iMinPrey, iMaxPrey
      integer iMinPred, iMaxPred
      integer nChl
      integer nPPplank
      integer nGRplank
      parameter(nlam=13)
      parameter(nopt=12)
      parameter(nplank=51)
      parameter(nGroup=9)
      parameter(nPhoto=35)
      parameter(iMinBact=nPhoto+1, iMaxBact=nPhoto)
      parameter(iMinPrey=1, iMaxPrey=nplank)
      parameter(iMinPred=26, iMaxPred=nplank)
      parameter(nChl=nPhoto)
      parameter(nPPplank=0)
      parameter(nGRplank=0)

CEOP
#endif /* ALLOW_GUD */
