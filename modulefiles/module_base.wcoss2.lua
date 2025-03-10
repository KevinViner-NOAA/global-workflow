help([[
Load environment to run GFS on WCOSS2
]])

load(pathJoin("PrgEnv-intel", "8.1.0"))
load(pathJoin("craype", "2.7.10"))
load(pathJoin("intel", "19.1.3.304"))
load(pathJoin("cray-mpich", "8.1.9"))
load(pathJoin("cray-pals", "1.0.17"))
load(pathJoin("esmf", "8.0.1"))
load(pathJoin("cfp", "2.0.4"))
setenv("USE_CFP","YES")

load(pathJoin("python", "3.8.6"))
load(pathJoin("prod_envir", "2.0.4"))
load(pathJoin("gempak", "7.14.1"))
load(pathJoin("perl", "5.32.0"))
load(pathJoin("libjpeg", "9c"))

load(pathJoin("cdo", "1.9.8"))

load(pathJoin("hdf5", "1.10.6"))
load(pathJoin("netcdf", "4.7.4"))

load(pathJoin("udunits", "2.2.28"))
load(pathJoin("gsl", "2.7"))
load(pathJoin("nco", "4.7.9"))
load(pathJoin("prod_util", "2.0.9"))
load(pathJoin("grib_util", "1.2.3"))
load(pathJoin("bufr_dump", "1.0.0"))
load(pathJoin("util_shared", "1.4.0"))
load(pathJoin("crtm", "2.3.0"))
load(pathJoin("g2tmpl", "1.9.1"))
load(pathJoin("wgrib2", "2.0.7"))

pushenv("HPC_OPT", "/apps/ops/para/libs")
append_path("MODULEPATH", "/apps/ops/para/libs/modulefiles/compiler/intel/19.1.3.304")
append_path("MODULEPATH", "/apps/ops/para/libs/modulefiles/mpi/intel/19.1.3.304/cray-mpich/8.1.7")

load("ncdiag/1.0.0")

prepend_path("MODULEPATH", pathJoin("/lfs/h2/emc/global/save/emc.global/git/prepobs/v1.0.1/modulefiles"))
load(pathJoin("prepobs", "1.0.1"))

whatis("Description: GFS run environment")
