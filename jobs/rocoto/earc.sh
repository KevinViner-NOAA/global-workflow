#! /usr/bin/env bash

source "$HOMEgfs/ush/preamble.sh"

###############################################################
## Abstract:
## Ensemble archive driver script
## RUN_ENVIR : runtime environment (emc | nco)
## HOMEgfs   : /full/path/to/workflow
## EXPDIR : /full/path/to/config/files
## CDATE  : current analysis date (YYYYMMDDHH)
## PDY    : current date (YYYYMMDD)
## cyc    : current cycle (HH)
## CDUMP  : cycle name (gdas / gfs)
## ENSGRP : ensemble sub-group to archive (0, 1, 2, ...)
###############################################################

###############################################################
# Source FV3GFS workflow modules
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Source relevant configs
configs="base earc"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done

export COMPONENT=${COMPONENT:-atmos}

n=$((10#${ENSGRP}))

# ICS are restarts and always lag INC by $assim_freq hours.
EARCINC_CYC=$ARCH_CYC
EARCICS_CYC=$((ARCH_CYC-assim_freq))
if [ $EARCICS_CYC -lt 0 ]; then
    EARCICS_CYC=$((EARCICS_CYC+24))
fi

# EnKF update in GFS, GDAS or both
CDUMP_ENKF=$(echo ${EUPD_CYC:-"gdas"} | tr a-z A-Z)

ARCH_LIST="$ROTDIR/enkf${CDUMP}.$PDY/$cyc/$COMPONENT/earc$ENSGRP"
[[ -d $ARCH_LIST ]] && rm -rf $ARCH_LIST
mkdir -p $ARCH_LIST
cd $ARCH_LIST

$HOMEgfs/ush/hpssarch_gen.sh enkf${CDUMP}
status=$?
if [ $status -ne 0 ]; then
   echo "$HOMEgfs/ush/hpssarch_gen.sh enkf${CDUMP} failed, ABORT!"
   exit $status
fi

cd $ROTDIR

source "${HOMEgfs}/ush/file_utils.sh"

###################################################################
# ENSGRP > 0 archives a group of ensemble members
firstday=$($NDATE +24 $SDATE)
if (( 10#${ENSGRP} > 0 )) && [[ ${HPSSARCH} = "YES" || ${LOCALARCH} = "YES" ]]; then

#--set the archiving command and create local directories, if necessary
   TARCMD="htar"
   if [[ $LOCALARCH = "YES" ]]; then
       TARCMD="tar"
       [ ! -d $ATARDIR/$CDATE ] && mkdir -p $ATARDIR/$CDATE
   fi

#--determine when to save ICs for warm start
   SAVEWARMICA="NO"
   SAVEWARMICB="NO"
   mm=$(echo $CDATE|cut -c 5-6)
   dd=$(echo $CDATE|cut -c 7-8)
   nday=$(( (mm-1)*30+dd ))
   mod=$(($nday % $ARCH_WARMICFREQ))
   if [ $CDATE -eq $firstday -a $cyc -eq $EARCINC_CYC ]; then SAVEWARMICA="YES" ; fi
   if [ $CDATE -eq $firstday -a $cyc -eq $EARCICS_CYC ]; then SAVEWARMICB="YES" ; fi
   if [ $mod -eq 0 -a $cyc -eq $EARCINC_CYC ]; then SAVEWARMICA="YES" ; fi
   if [ $mod -eq 0 -a $cyc -eq $EARCICS_CYC ]; then SAVEWARMICB="YES" ; fi

   if [ $EARCICS_CYC -eq 18 ]; then
       nday1=$((nday+1))
       mod1=$(($nday1 % $ARCH_WARMICFREQ))
       if [ $mod1 -eq 0 -a $cyc -eq $EARCICS_CYC ] ; then SAVEWARMICB="YES" ; fi
       if [ $mod1 -ne 0 -a $cyc -eq $EARCICS_CYC ] ; then SAVEWARMICB="NO" ; fi
       if [ $CDATE -eq $SDATE -a $cyc -eq $EARCICS_CYC ] ; then SAVEWARMICB="YES" ; fi
   fi

   if [ $CDATE -gt $SDATE ]; then # Don't run for first half cycle

     $TARCMD -P -cvf $ATARDIR/$CDATE/enkf${CDUMP}_grp${ENSGRP}.tar $(cat $ARCH_LIST/enkf${CDUMP}_grp${n}.txt)
     status=$?
     if [ $status -ne 0  -a $CDATE -ge $firstday ]; then
         echo "$(echo $TARCMD | tr 'a-z' 'A-Z') $CDATE enkf${CDUMP}_grp${ENSGRP}.tar failed"
         exit $status
     fi

     if [ $SAVEWARMICA = "YES" -a $cyc -eq $EARCINC_CYC ]; then
       $TARCMD -P -cvf $ATARDIR/$CDATE/enkf${CDUMP}_restarta_grp${ENSGRP}.tar $(cat $ARCH_LIST/enkf${CDUMP}_restarta_grp${n}.txt)
       status=$?
       if [ $status -ne 0 ]; then
           echo "$(echo $TARCMD | tr 'a-z' 'A-Z') $CDATE enkf${CDUMP}_restarta_grp${ENSGRP}.tar failed"
           exit $status
       fi
     fi

     if [ $SAVEWARMICB = "YES"  -a $cyc -eq $EARCICS_CYC ]; then
       $TARCMD -P -cvf $ATARDIR/$CDATE/enkf${CDUMP}_restartb_grp${ENSGRP}.tar $(cat $ARCH_LIST/enkf${CDUMP}_restartb_grp${n}.txt)
       status=$?
       if [ $status -ne 0 ]; then
           echo "$(echo $TARCMD | tr 'a-z' 'A-Z') $CDATE enkf${CDUMP}_restartb_grp${ENSGRP}.tar failed"
           exit $status
       fi
     fi

   fi # CDATE>SDATE

fi


###################################################################
# ENSGRP 0 archives ensemble means and copy data to online archive
if [ $ENSGRP -eq 0 ]; then

    if [[ $HPSSARCH = "YES" || $LOCALARCH = "YES" ]]; then

#--set the archiving command and create local directories, if necessary
        TARCMD="htar"
        if [[ $LOCALARCH = "YES" ]]; then
            TARCMD="tar"
            [ ! -d $ATARDIR/$CDATE ] && mkdir -p $ATARDIR/$CDATE
        fi

        set +e
        $TARCMD -P -cvf $ATARDIR/$CDATE/enkf${CDUMP}.tar $(cat $ARCH_LIST/enkf${CDUMP}.txt)
        status=$?
        if [ $status -ne 0  -a $CDATE -ge $firstday ]; then
            echo "$(echo $TARCMD | tr 'a-z' 'A-Z') $CDATE enkf${CDUMP}.tar failed"
            exit $status
        fi
        set_strict
    fi

    #-- Archive online for verification and diagnostics
    [[ ! -d $ARCDIR ]] && mkdir -p $ARCDIR
    cd $ARCDIR

    nb_copy $ROTDIR/enkf${CDUMP}.$PDY/$cyc/$COMPONENT/${CDUMP}.t${cyc}z.enkfstat         enkfstat.${CDUMP}.$CDATE
    nb_copy $ROTDIR/enkf${CDUMP}.$PDY/$cyc/$COMPONENT/${CDUMP}.t${cyc}z.gsistat.ensmean  gsistat.${CDUMP}.${CDATE}.ensmean

    if [ $CDUMP_ENKF != "GDAS" ]; then
		nb_copy $ROTDIR/enkfgfs.$PDY/$cyc/$COMPONENT/${CDUMP}.t${cyc}z.enkfstat         enkfstat.gfs.$CDATE
		nb_copy $ROTDIR/enkfgfs.$PDY/$cyc/$COMPONENT/${CDUMP}.t${cyc}z.gsistat.ensmean  gsistat.gfs.${CDATE}.ensmean
	fi

fi


if [[ "${DELETE_COM_IN_ARCHIVE_JOB:-YES}" == NO ]] ; then
    exit 0
fi

###############################################################
# ENSGRP 0 also does clean-up
if [ $ENSGRP -eq 0 ]; then

    # Start start and end dates to remove
    GDATEEND=$($NDATE -${RMOLDEND_ENKF:-24}  $CDATE)
    GDATE=$($NDATE -${RMOLDSTD_ENKF:-120} $CDATE)
    while [ $GDATE -le $GDATEEND ]; do

	gPDY=$(echo $GDATE | cut -c1-8)
	gcyc=$(echo $GDATE | cut -c9-10)

	# Loop over GDAS and GFS EnKF directories separately.
        clist="gdas gfs"
	for ctype in $clist; do
	    COMIN_ENS="$ROTDIR/enkf$ctype.$gPDY/$gcyc/$COMPONENT"
            if [ -d $COMIN_ENS ]; then
		rocotolog="$EXPDIR/logs/${GDATE}.log"
		if [ -f $rocotolog ]; then
		    testend=$(tail -n 1 $rocotolog | grep "This cycle is complete: Success")
		    rc=$?
		    if [ $rc -eq 0 ]; then
                        # Retain f006.ens files.  Remove everything else
			for file in $(ls $COMIN_ENS | grep -v f006.ens); do
			    rm -rf $COMIN_ENS/$file
			done
		    fi
		fi
	    fi

	    # Remove empty directories
	    if [ -d $COMIN_ENS ] ; then
		[[ ! "$(ls -A $COMIN_ENS)" ]] && rm -rf $COMIN_ENS
	    fi
	done

	# Advance to next cycle
	GDATE=$($NDATE +$assim_freq $GDATE)

    done

fi

# Remove enkf*.$rPDY for the older of GDATE or RDATE
GDATE=$($NDATE -${RMOLDSTD_ENKF:-120} $CDATE)
fhmax=$FHMAX_GFS
RDATE=$($NDATE -$fhmax $CDATE)
if [ $GDATE -lt $RDATE ]; then
    RDATE=$GDATE
fi
rPDY=$(echo $RDATE | cut -c1-8)
clist="gdas gfs"
for ctype in $clist; do
    COMIN="$ROTDIR/enkf$ctype.$rPDY"
    [[ -d $COMIN ]] && rm -rf $COMIN
done

###############################################################


exit 0
