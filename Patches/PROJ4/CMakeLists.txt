cmake_minimum_required(VERSION 2.8.3)
project(PROJ4)

# We need -fPIC when building statically
if( UNIX AND NOT BUILD_SHARED_LIBS)
  set (CMAKE_POSITION_INDEPENDENT_CODE TRUE)
endif()


list(APPEND source_azimuthal
  src/PJ_aeqd.c src/PJ_gnom.c src/PJ_laea.c src/PJ_mod_ster.c
  src/PJ_nsper.c src/PJ_nzmg.c src/PJ_ortho.c src/PJ_stere.c src/PJ_sterea.c
  src/proj_rouss.c
)

list(APPEND source_conic
  src/PJ_aea.c src/PJ_bipc.c src/PJ_bonne.c src/PJ_eqdc.c
  src/PJ_imw_p.c src/PJ_lcc.c src/PJ_poly.c
  src/PJ_rpoly.c src/PJ_sconics.c src/PJ_lcca.c
)

list(APPEND source_cylinder
  src/PJ_cass.c src/PJ_cc.c src/PJ_cea.c src/PJ_eqc.c
  src/PJ_gall.c src/PJ_labrd.c src/PJ_lsat.c src/PJ_merc.c
  src/PJ_mill.c src/PJ_ocea.c src/PJ_omerc.c src/PJ_somerc.c
  src/PJ_tcc.c src/PJ_tcea.c src/PJ_tmerc.c src/PJ_geos.c src/PJ_gstmerc.c
)

list(APPEND source_misc
  src/PJ_airy.c src/PJ_aitoff.c src/PJ_august.c src/PJ_bacon.c
  src/PJ_chamb.c src/PJ_hammer.c src/PJ_lagrng.c src/PJ_larr.c
  src/PJ_lask.c src/PJ_nocol.c src/PJ_ob_tran.c src/PJ_oea.c
  src/PJ_tpeqd.c src/PJ_vandg.c src/PJ_vandg2.c src/PJ_vandg4.c
  src/PJ_wag7.c src/pj_latlong.c src/PJ_krovak.c src/pj_geocent.c
)

list(APPEND source_pseudo
  src/PJ_boggs.c src/PJ_collg.c src/PJ_crast.c src/PJ_denoy.c
  src/PJ_eck1.c src/PJ_eck2.c src/PJ_eck3.c src/PJ_eck4.c
  src/PJ_eck5.c src/PJ_fahey.c src/PJ_fouc_s.c src/PJ_gins8.c
  src/PJ_gn_sinu.c src/PJ_goode.c src/PJ_hatano.c src/PJ_loxim.c
  src/PJ_mbt_fps.c src/PJ_mbtfpp.c src/PJ_mbtfpq.c src/PJ_moll.c
  src/PJ_nell.c src/PJ_nell_h.c src/PJ_putp2.c src/PJ_putp3.c
  src/PJ_putp4p.c src/PJ_putp5.c src/PJ_putp6.c src/PJ_robin.c
  src/PJ_sts.c src/PJ_urm5.c src/PJ_urmfps.c src/PJ_wag2.c
  src/PJ_wag3.c src/PJ_wink1.c src/PJ_wink2.c
)

list(APPEND source_support
  src/aasincos.c src/adjlon.c src/bch2bps.c src/bchgen.c src/pj_gauss.c
  src/biveval.c src/dmstor.c src/mk_cheby.c src/pj_auth.c
  src/pj_deriv.c src/pj_ell_set.c src/pj_ellps.c src/pj_errno.c
  src/pj_factors.c src/pj_fwd.c src/pj_init.c src/pj_inv.c
  src/pj_list.c src/pj_malloc.c src/pj_mlfn.c src/pj_msfn.c
  src/pj_open_lib.c src/pj_param.c src/pj_phi2.c src/pj_pr_list.c
  src/pj_qsfn.c src/pj_strerrno.c src/pj_tsfn.c src/pj_units.c
  src/pj_zpoly1.c src/rtodms.c src/vector1.c src/pj_release.c
  src/geocent.c src/pj_transform.c src/pj_datum_set.c src/pj_datums.c
  src/pj_apply_gridshift.c src/nad_cvt.c src/nad_init.c
  src/nad_intr.c src/pj_utils.c src/pj_gridlist.c src/pj_gridinfo.c
  src/proj_mdist.c src/pj_mutex.c src/pj_initcache.c
)

list(APPEND misc_source
src/emess.c
src/gen_cheb.c
src/geod_for.c
src/geod_inv.c
src/geod_set.c
src/jniproj.c
src/pj_apply_vgridshift.c
src/pj_ctx.c
src/PJ_healpix.c
src/PJ_igh.c
src/PJ_isea.c
src/pj_log.c
src/PJ_natearth.c
src/proj_etmerc.c
src/p_series.c
src/emess.c
src/gen_cheb.c
src/geod.c
src/geod_for.c
src/geod_inv.c
src/geod_set.c
src/jniproj.c
src/pj_apply_vgridshift.c
src/pj_ctx.c
src/PJ_healpix.c
src/PJ_igh.c
src/PJ_isea.c
src/pj_log.c
src/PJ_natearth.c
src/proj_etmerc.c
src/p_series.c


)

include_directories( src )

add_library(proj
  src/proj.def
  ${source_azimuthal}
  ${source_conic}
  ${source_cylinder}
  ${source_misc}
  ${source_pseudo}
  ${source_support}
  ${misc_source}
)
if(NOT WIN32)
  set(MATH_LIBS m)
endif()
target_link_libraries(proj ${MATH_LIBS})

install(TARGETS proj
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(DIRECTORY src/ DESTINATION include FILES_MATCHING PATTERN "*.h" )
