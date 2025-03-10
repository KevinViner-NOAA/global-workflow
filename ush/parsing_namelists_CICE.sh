#! /usr/bin/env bash

# parsing namelist of CICE

CICE_namelists(){

if [ $warm_start = ".true." ]; then
  cmeps_run_type='continue'
else
  cmeps_run_type='initial'
fi


cat > ice_in <<eof
&setup_nml
   days_per_year  = 365
   use_leap_years = .true.
   year_init      = $year
   month_init     = $month
   day_init       = $day
   sec_init       = $sec
   dt             = $ICETIM
   npt            = $npt
   ndtd           = 1
   runtype        = '$cmeps_run_type'
   runid          = 'unknown'
   ice_ic         = '$iceic'
   restart        = .true.
   restart_ext    = .false.
   use_restart_time = $USE_RESTART_TIME
   restart_format = 'nc'
   lcdf64         = .false.
   numin          = 21
   numax          = 89
   restart_dir    = './RESTART/'
   restart_file   = 'iced'
   pointer_file   = './ice.restart_file'
   dumpfreq       = '$dumpfreq'
   dumpfreq_n     =  $dumpfreq_n
   dump_last      = .false.
   bfbflag        = 'off'
   diagfreq       = 6
   diag_type      = 'file'
   diag_file      = 'ice_diag.d'
   print_global   = .true.
   print_points   = .true.
   latpnt(1)      =  90.
   lonpnt(1)      =   0.
   latpnt(2)      = -65.
   lonpnt(2)      = -45.
   histfreq       = 'm','d','h','x','x'
   histfreq_n     =  0 , 0 , 6 , 1 , 1
   hist_avg       = $cice_hist_avg
   history_dir    = './history/'
   history_file   = 'iceh'
   write_ic       = .true.
   incond_dir     = './history/'
   incond_file    = 'iceh_ic'
   version_name   = 'CICE_6.0.2'
/

&grid_nml
   grid_format  = 'nc'
   grid_type    = 'tripole'
   grid_file    = '$ice_grid_file'
   kmt_file     = '$ice_kmt_file'
   kcatbound    = 0
   ncat         = 5
   nfsd         = 1
   nilyr        = 7
   nslyr        = 1
   nblyr        = 1
   nfsd         = 1
/

&tracer_nml
   tr_iage      = .true.
   restart_age  = .false.
   tr_FY        = .false.
   restart_FY   = .false.
   tr_lvl       = .true.
   restart_lvl  = .false.
   tr_pond_topo = .false.
   restart_pond_topo = .false.
   tr_pond_lvl  = $tr_pond_lvl
   restart_pond_lvl  = $restart_pond_lvl
   tr_aero      = .false.
   restart_aero = .false.
   tr_fsd       = .false.
   restart_fsd  = .false.
/

&thermo_nml
   kitd              = 1
   ktherm            = $ktherm
   conduct           = 'MU71'
   a_rapid_mode      =  0.5e-3
   Rac_rapid_mode    =    10.0
   aspect_rapid_mode =     1.0
   dSdt_slow_mode    = -5.0e-8
   phi_c_slow_mode   =    0.05
   phi_i_mushy       =    0.85
/

&dynamics_nml
   kdyn            = 1
   ndte            = 120
   revised_evp     = .false.
   evp_algorithm   = 'standard_2d'
   brlx            = 300.0
   arlx            = 300.0
   ssh_stress      = 'coupled'
   advection       = 'remap'
   kstrength       = 1
   krdg_partic     = 1
   krdg_redist     = 1
   mu_rdg          = 3
   Cf              = 17.
   Ktens           = 0.
   e_yieldcurve    = 2.
   e_plasticpot    = 2.
   coriolis        = 'latitude'
   kridge          = 1
   ktransport      = 1
/

&shortwave_nml
   shortwave       = 'dEdd'
   albedo_type     = 'default'
   albicev         = 0.78
   albicei         = 0.36
   albsnowv        = 0.98
   albsnowi        = 0.70
   ahmax           = 0.3
   R_ice           = 0.
   R_pnd           = 0.
   R_snw           = 1.5
   dT_mlt          = 1.5
   rsnw_mlt        = 1500.
   kalg            = 0.0
   sw_redist       = .true.
/

&ponds_nml
   hp1             = 0.01
   hs0             = 0.
   hs1             = 0.03
   dpscale         = 1.e-3
   frzpnd          = 'hlid'
   rfracmin        = 0.15
   rfracmax        = 1.
   pndaspect       = 0.8
/

&snow_nml
   snwredist       = 'none'
/

&forcing_nml
   formdrag        = .false.
   atmbndy         = 'default'
   calc_strair     = .true.
   calc_Tsfc       = .true.
   highfreq        = .false.
   natmiter        = 5
   ustar_min       = 0.0005
   emissivity      = 0.95
   fbot_xfer_type  = 'constant'
   update_ocn_f    = $FRAZIL_FWSALT
   l_mpond_fresh   = .false.
   tfrz_option     = $tfrz_option
   restart_coszen  = .true.
/

&domain_nml
   nprocs = $ICEPETS
   nx_global         = $NX_GLB
   ny_global         = $NY_GLB
   block_size_x      = $(( 2 * ( $NX_GLB / $ICEPETS ) ))
   block_size_y      = $(( $NY_GLB / 2 ))
   max_blocks        = -1
   processor_shape   = 'slenderX2'
   distribution_type = 'cartesian'
   distribution_wght = 'latitude'
   ew_boundary_type  = 'cyclic'
   ns_boundary_type  = 'tripole'
   maskhalo_dyn      = .false.
   maskhalo_remap    = .false.
   maskhalo_bound    = .false.
/

&zbgc_nml
/

&icefields_nml
   f_tmask         = .true.
   f_blkmask       = .true.
   f_tarea         = .true.
   f_uarea         = .true.
   f_dxt           = .false.
   f_dyt           = .false.
   f_dxu           = .false.
   f_dyu           = .false.
   f_HTN           = .false.
   f_HTE           = .false.
   f_ANGLE         = .true.
   f_ANGLET        = .true.
   f_NCAT          = .true.
   f_VGRDi         = .false.
   f_VGRDs         = .false.
   f_VGRDb         = .false.
   f_VGRDa         = .true.
   f_bounds        = .false.
   f_aice          = 'mdhxx'
   f_hi            = 'mdhxx'
   f_hs            = 'mdhxx'
   f_Tsfc          = 'mdhxx'
   f_sice          = 'mdhxx'
   f_uvel          = 'mdhxx'
   f_vvel          = 'mdhxx'
   f_uatm          = 'mdhxx'
   f_vatm          = 'mdhxx'
   f_fswdn         = 'mdhxx'
   f_flwdn         = 'mdhxx'
   f_snowfrac      = 'x'
   f_snow          = 'mdhxx'
   f_snow_ai       = 'x'
   f_rain          = 'mdhxx'
   f_rain_ai       = 'x'
   f_sst           = 'mdhxx'
   f_sss           = 'mdhxx'
   f_uocn          = 'mdhxx'
   f_vocn          = 'mdhxx'
   f_frzmlt        = 'mdhxx'
   f_fswfac        = 'mdhxx'
   f_fswint_ai     = 'x'
   f_fswabs        = 'mdhxx'
   f_fswabs_ai     = 'x'
   f_albsni        = 'mdhxx'
   f_alvdr         = 'mdhxx'
   f_alidr         = 'mdhxx'
   f_alvdf         = 'mdhxx'
   f_alidf         = 'mdhxx'
   f_alvdr_ai      = 'x'
   f_alidr_ai      = 'x'
   f_alvdf_ai      = 'x'
   f_alidf_ai      = 'x'
   f_albice        = 'x'
   f_albsno        = 'x'
   f_albpnd        = 'x'
   f_coszen        = 'x'
   f_flat          = 'mdhxx'
   f_flat_ai       = 'x'
   f_fsens         = 'mdhxx'
   f_fsens_ai      = 'x'
   f_fswup         = 'x'
   f_flwup         = 'mdhxx'
   f_flwup_ai      = 'x'
   f_evap          = 'mdhxx'
   f_evap_ai       = 'x'
   f_Tair          = 'mdhxx'
   f_Tref          = 'mdhxx'
   f_Qref          = 'mdhxx'
   f_congel        = 'mdhxx'
   f_frazil        = 'mdhxx'
   f_snoice        = 'mdhxx'
   f_dsnow         = 'mdhxx'
   f_melts         = 'mdhxx'
   f_meltt         = 'mdhxx'
   f_meltb         = 'mdhxx'
   f_meltl         = 'mdhxx'
   f_fresh         = 'mdhxx'
   f_fresh_ai      = 'x'
   f_fsalt         = 'mdhxx'
   f_fsalt_ai      = 'x'
   f_fbot          = 'mdhxx'
   f_fhocn         = 'mdhxx'
   f_fhocn_ai      = 'x'
   f_fswthru       = 'x'
   f_fswthru_ai    = 'x'
   f_fsurf_ai      = 'x'
   f_fcondtop_ai   = 'x'
   f_fmeltt_ai     = 'x'
   f_strairx       = 'mdhxx'
   f_strairy       = 'mdhxx'
   f_strtltx       = 'x'
   f_strtlty       = 'x'
   f_strcorx       = 'x'
   f_strcory       = 'x'
   f_strocnx       = 'mdhxx'
   f_strocny       = 'mdhxx'
   f_strintx       = 'x'
   f_strinty       = 'x'
   f_taubx         = 'x'
   f_tauby         = 'x'
   f_strength      = 'x'
   f_divu          = 'mdhxx'
   f_shear         = 'mdhxx'
   f_sig1          = 'x'
   f_sig2          = 'x'
   f_sigP          = 'x'
   f_dvidtt        = 'mdhxx'
   f_dvidtd        = 'mdhxx'
   f_daidtt        = 'mdhxx'
   f_daidtd        = 'mdhxx'
   f_dagedtt       = 'x'
   f_dagedtd       = 'x'
   f_mlt_onset     = 'mdhxx'
   f_frz_onset     = 'mdhxx'
   f_hisnap        = 'x'
   f_aisnap        = 'x'
   f_trsig         = 'x'
   f_icepresent    = 'x'
   f_iage          = 'x'
   f_FY            = 'x'
   f_aicen         = 'x'
   f_vicen         = 'x'
   f_vsnon         = 'x'
   f_snowfracn     = 'x'
   f_keffn_top     = 'x'
   f_Tinz          = 'x'
   f_Sinz          = 'x'
   f_Tsnz          = 'x'
   f_fsurfn_ai     = 'x'
   f_fcondtopn_ai  = 'x'
   f_fmelttn_ai    = 'x'
   f_flatn_ai      = 'x'
   f_fsensn_ai     = 'x'
/

&icefields_mechred_nml
   f_alvl         = 'x'
   f_vlvl         = 'x'
   f_ardg         = 'x'
   f_vrdg         = 'x'
   f_dardg1dt     = 'x'
   f_dardg2dt     = 'x'
   f_dvirdgdt     = 'x'
   f_opening      = 'x'
   f_ardgn        = 'x'
   f_vrdgn        = 'x'
   f_dardg1ndt    = 'x'
   f_dardg2ndt    = 'x'
   f_dvirdgndt    = 'x'
   f_krdgn        = 'x'
   f_aparticn     = 'x'
   f_aredistn     = 'x'
   f_vredistn     = 'x'
   f_araftn       = 'x'
   f_vraftn       = 'x'
/

&icefields_pond_nml
   f_apondn       = 'x'
   f_apeffn       = 'x'
   f_hpondn       = 'x'
   f_apond        = 'mdhxx'
   f_hpond        = 'mdhxx'
   f_ipond        = 'mdhxx'
   f_apeff        = 'mdhxx'
   f_apond_ai     = 'x'
   f_hpond_ai     = 'x'
   f_ipond_ai     = 'x'
   f_apeff_ai     = 'x'
/

&icefields_drag_nml
   f_drag         = 'x'
   f_Cdn_atm      = 'x'
   f_Cdn_ocn      = 'x'
/

&icefields_bgc_nml
/
eof

}
