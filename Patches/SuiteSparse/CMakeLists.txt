cmake_minimum_required(VERSION 2.8.10)
project(CXSparse)

include_directories(CXSparse/Include)
include_directories(SuiteSparse_config)

set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)


if( WIN32 )
  add_definitions(-DNCOMPLEX)
endif()

add_library(cs_add_di OBJECT
  CXSparse/Source/cs_add.c
  )
add_library(cs_amd_di OBJECT
  CXSparse/Source/cs_amd.c
  )
add_library( cs_chol_di OBJECT
  CXSparse/Source/cs_chol.c
  )
add_library(cs_cholsol_di OBJECT
  CXSparse/Source/cs_cholsol.c
  )
add_library(cs_counts_di OBJECT
  CXSparse/Source/cs_counts.c
  )
add_library(cs_cumsum_di OBJECT
  CXSparse/Source/cs_cumsum.c
  )
add_library(cs_droptol_di OBJECT
  CXSparse/Source/cs_droptol.c
  )
add_library(cs_dropzeros_di OBJECT
  CXSparse/Source/cs_dropzeros.c
  )
add_library(cs_dupl_di OBJECT
  CXSparse/Source/cs_dupl.c
  )
add_library(cs_entry_di OBJECT
  CXSparse/Source/cs_entry.c
  )
add_library(cs_etree_di OBJECT
  CXSparse/Source/cs_etree.c
  )
add_library(cs_fkeep_di OBJECT
  CXSparse/Source/cs_fkeep.c
  )
add_library(cs_gaxpy_di OBJECT
  CXSparse/Source/cs_gaxpy.c
  )
add_library(cs_happly_di OBJECT
  CXSparse/Source/cs_happly.c
  )
add_library(cs_house_di OBJECT
  CXSparse/Source/cs_house.c
  )
add_library(cs_ipvec_di OBJECT
  CXSparse/Source/cs_ipvec.c
  )
add_library(cs_lsolve_di OBJECT
  CXSparse/Source/cs_lsolve.c
  )
add_library(cs_ltsolve_di OBJECT
  CXSparse/Source/cs_ltsolve.c
  )
add_library(cs_lu_di OBJECT
  CXSparse/Source/cs_lu.c
  )
add_library(cs_lusol_di OBJECT
  CXSparse/Source/cs_lusol.c
  )
add_library(cs_util_di OBJECT
  CXSparse/Source/cs_util.c
  )
add_library(cs_multiply_di OBJECT
  CXSparse/Source/cs_multiply.c
  )
add_library(cs_permute_di OBJECT
  CXSparse/Source/cs_permute.c
  )
add_library(cs_pinv_di OBJECT
  CXSparse/Source/cs_pinv.c
  )
add_library(cs_post_di OBJECT
  CXSparse/Source/cs_post.c
  )
add_library(cs_pvec_di OBJECT
  CXSparse/Source/cs_pvec.c
  )
add_library(cs_qr_di OBJECT
  CXSparse/Source/cs_qr.c
  )
add_library(cs_qrsol_di OBJECT
  CXSparse/Source/cs_qrsol.c
  )
add_library(cs_scatter_di OBJECT
  CXSparse/Source/cs_scatter.c
  )
add_library(cs_schol_di OBJECT
  CXSparse/Source/cs_schol.c
  )
add_library(cs_sqr_di OBJECT
  CXSparse/Source/cs_sqr.c
  )
add_library(cs_symperm_di OBJECT
  CXSparse/Source/cs_symperm.c
  )
add_library(cs_tdfs_di OBJECT
  CXSparse/Source/cs_tdfs.c
  )
add_library(cs_malloc_di OBJECT
  CXSparse/Source/cs_malloc.c
  )
add_library(cs_transpose_di OBJECT
  CXSparse/Source/cs_transpose.c
  )
add_library(cs_compress_di OBJECT
  CXSparse/Source/cs_compress.c
  )
add_library(cs_usolve_di OBJECT
  CXSparse/Source/cs_usolve.c
  )
add_library(cs_utsolve_di OBJECT
  CXSparse/Source/cs_utsolve.c
  )
add_library(cs_scc_di OBJECT
  CXSparse/Source/cs_scc.c
  )
add_library(cs_maxtrans_di OBJECT
  CXSparse/Source/cs_maxtrans.c
  )
add_library(cs_dmperm_di OBJECT
  CXSparse/Source/cs_dmperm.c
  )
add_library(cs_updown_di OBJECT
  CXSparse/Source/cs_updown.c
  )
add_library(cs_norm_di OBJECT
  CXSparse/Source/cs_norm.c
  )
add_library(cs_print_di OBJECT
  CXSparse/Source/cs_print.c
  )
add_library(cs_load_di OBJECT
  CXSparse/Source/cs_load.c
  )
add_library(cs_dfs_di OBJECT
  CXSparse/Source/cs_dfs.c
  )
add_library(cs_reach_di OBJECT
  CXSparse/Source/cs_reach.c
  )
add_library(cs_spsolve_di OBJECT
  CXSparse/Source/cs_spsolve.c
  )
add_library(cs_leaf_di OBJECT
  CXSparse/Source/cs_leaf.c
  )
add_library(cs_ereach_di OBJECT
  CXSparse/Source/cs_ereach.c
  )
add_library(cs_randperm_di OBJECT
  CXSparse/Source/cs_randperm.c
  )

#-DCS_LONG
add_library(cs_add_dl OBJECT
  CXSparse/Source/cs_add.c
  )
set_target_properties(cs_add_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_amd_dl OBJECT
  CXSparse/Source/cs_amd.c
  )
set_target_properties(cs_amd_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_chol_dl OBJECT
  CXSparse/Source/cs_chol.c
  )
set_target_properties(cs_chol_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_cholsol_dl OBJECT
  CXSparse/Source/cs_cholsol.c
  )
set_target_properties(cs_cholsol_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_counts_dl OBJECT
  CXSparse/Source/cs_counts.c
  )
set_target_properties(cs_counts_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_cumsum_dl OBJECT
  CXSparse/Source/cs_cumsum.c
  )
set_target_properties(cs_cumsum_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_droptol_dl OBJECT
  CXSparse/Source/cs_droptol.c
  )
set_target_properties(cs_droptol_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_dropzeros_dl OBJECT
  CXSparse/Source/cs_dropzeros.c
  )
set_target_properties(cs_dropzeros_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_dupl_dl OBJECT
  CXSparse/Source/cs_dupl.c
  )
set_target_properties(cs_dupl_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_entry_dl OBJECT
  CXSparse/Source/cs_entry.c
  )
set_target_properties(cs_entry_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_etree_dl OBJECT
  CXSparse/Source/cs_etree.c
  )
set_target_properties(cs_etree_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_fkeep_dl OBJECT
  CXSparse/Source/cs_fkeep.c
  )
set_target_properties(cs_fkeep_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_gaxpy_dl OBJECT
  CXSparse/Source/cs_gaxpy.c
  )
set_target_properties(cs_gaxpy_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_happly_dl OBJECT
  CXSparse/Source/cs_happly.c
  )
set_target_properties(cs_happly_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_house_dl OBJECT
  CXSparse/Source/cs_house.c
  )
set_target_properties(cs_house_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_ipvec_dl OBJECT
  CXSparse/Source/cs_ipvec.c
  )
set_target_properties(cs_ipvec_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_lsolve_dl OBJECT
  CXSparse/Source/cs_lsolve.c
  )
set_target_properties(cs_lsolve_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_ltsolve_dl OBJECT
  CXSparse/Source/cs_ltsolve.c
  )
set_target_properties(cs_ltsolve_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_lu_dl OBJECT
  CXSparse/Source/cs_lu.c
  )
set_target_properties(cs_lu_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_lusol_dl OBJECT
  CXSparse/Source/cs_lusol.c
  )
set_target_properties(cs_lusol_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_util_dl OBJECT
  CXSparse/Source/cs_util.c
  )
set_target_properties(cs_util_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_multiply_dl OBJECT
  CXSparse/Source/cs_multiply.c
  )
set_target_properties(cs_multiply_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_permute_dl OBJECT
  CXSparse/Source/cs_permute.c
  )
set_target_properties(cs_permute_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_pinv_dl OBJECT
  CXSparse/Source/cs_pinv.c
  )
set_target_properties(cs_pinv_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_post_dl OBJECT
  CXSparse/Source/cs_post.c
  )
set_target_properties(cs_post_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_pvec_dl OBJECT
  CXSparse/Source/cs_pvec.c
  )
set_target_properties(cs_pvec_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_qr_dl OBJECT
  CXSparse/Source/cs_qr.c
  )
set_target_properties(cs_qr_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_qrsol_dl OBJECT
  CXSparse/Source/cs_qrsol.c
  )
set_target_properties(cs_qrsol_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_scatter_dl OBJECT
  CXSparse/Source/cs_scatter.c
  )
set_target_properties(cs_scatter_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_schol_dl OBJECT
  CXSparse/Source/cs_schol.c
  )
set_target_properties(cs_schol_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_sqr_dl OBJECT
  CXSparse/Source/cs_sqr.c
  )
set_target_properties(cs_sqr_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_symperm_dl OBJECT
  CXSparse/Source/cs_symperm.c
  )
set_target_properties(cs_symperm_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_tdfs_dl OBJECT
  CXSparse/Source/cs_tdfs.c
  )
set_target_properties(cs_tdfs_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_malloc_dl OBJECT
  CXSparse/Source/cs_malloc.c
  )
set_target_properties(cs_malloc_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_transpose_dl OBJECT
  CXSparse/Source/cs_transpose.c
  )
set_target_properties(cs_transpose_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_compress_dl OBJECT
  CXSparse/Source/cs_compress.c
  )
set_target_properties(cs_compress_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_usolve_dl OBJECT
  CXSparse/Source/cs_usolve.c
  )
set_target_properties(cs_usolve_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_utsolve_dl OBJECT
  CXSparse/Source/cs_utsolve.c
  )
set_target_properties(cs_utsolve_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_scc_dl OBJECT
  CXSparse/Source/cs_scc.c
  )
set_target_properties(cs_scc_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_maxtrans_dl OBJECT
  CXSparse/Source/cs_maxtrans.c
  )
set_target_properties(cs_maxtrans_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_dmperm_dl OBJECT
  CXSparse/Source/cs_dmperm.c
  )
set_target_properties(cs_dmperm_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_updown_dl OBJECT
  CXSparse/Source/cs_updown.c
  )
set_target_properties(cs_updown_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_print_dl OBJECT
  CXSparse/Source/cs_print.c
  )
set_target_properties(cs_print_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_norm_dl OBJECT
  CXSparse/Source/cs_norm.c
  )
set_target_properties(cs_norm_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_load_dl OBJECT
  CXSparse/Source/cs_load.c
  )
set_target_properties(cs_load_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_dfs_dl OBJECT
  CXSparse/Source/cs_dfs.c
  )
set_target_properties(cs_dfs_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_reach_dl OBJECT
  CXSparse/Source/cs_reach.c
  )
set_target_properties(cs_reach_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_spsolve_dl OBJECT
  CXSparse/Source/cs_spsolve.c
  )
set_target_properties(cs_spsolve_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_leaf_dl OBJECT
  CXSparse/Source/cs_leaf.c
  )
set_target_properties(cs_leaf_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_ereach_dl OBJECT
  CXSparse/Source/cs_ereach.c
  )
set_target_properties(cs_ereach_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

add_library(cs_randperm_dl OBJECT
  CXSparse/Source/cs_randperm.c
  )
set_target_properties(cs_randperm_dl PROPERTIES
  COMPILE_DEFINITIONS "CS_LONG")

if( NOT WIN32 )
  add_library(cs_convert OBJECT
    CXSparse/Source/cs_convert.c
    )

  #-DCS_COMPLEX
  add_library(cs_add_ci OBJECT
    CXSparse/Source/cs_add.c
    )
  set_target_properties(cs_add_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_amd_ci OBJECT
    CXSparse/Source/cs_amd.c
    )
  set_target_properties(cs_amd_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_chol_ci OBJECT
    CXSparse/Source/cs_chol.c
    )
  set_target_properties(cs_chol_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_cholsol_ci OBJECT
    CXSparse/Source/cs_cholsol.c
    )
  set_target_properties(cs_cholsol_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_counts_ci OBJECT
    CXSparse/Source/cs_counts.c
    )
  set_target_properties(cs_counts_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_cumsum_ci OBJECT
    CXSparse/Source/cs_cumsum.c
    )
  set_target_properties(cs_cumsum_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_droptol_ci OBJECT
    CXSparse/Source/cs_droptol.c
    )
  set_target_properties(cs_droptol_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_dropzeros_ci OBJECT
    CXSparse/Source/cs_dropzeros.c
    )
  set_target_properties(cs_dropzeros_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_dupl_ci OBJECT
    CXSparse/Source/cs_dupl.c
    )
  set_target_properties(cs_dupl_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_entry_ci OBJECT
    CXSparse/Source/cs_entry.c
    )
  set_target_properties(cs_entry_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_etree_ci OBJECT
    CXSparse/Source/cs_etree.c
    )
  set_target_properties(cs_etree_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_fkeep_ci OBJECT
    CXSparse/Source/cs_fkeep.c
    )
  set_target_properties(cs_fkeep_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_gaxpy_ci OBJECT
    CXSparse/Source/cs_gaxpy.c
    )
  set_target_properties(cs_gaxpy_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_happly_ci OBJECT
    CXSparse/Source/cs_happly.c
    )
  set_target_properties(cs_happly_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_house_ci OBJECT
    CXSparse/Source/cs_house.c
    )
  set_target_properties(cs_house_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_ipvec_ci OBJECT
    CXSparse/Source/cs_ipvec.c
    )
  set_target_properties(cs_ipvec_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_lsolve_ci OBJECT
    CXSparse/Source/cs_lsolve.c
    )
  set_target_properties(cs_lsolve_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_ltsolve_ci OBJECT
    CXSparse/Source/cs_ltsolve.c
    )
  set_target_properties(cs_ltsolve_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_lu_ci OBJECT
    CXSparse/Source/cs_lu.c
    )
  set_target_properties(cs_lu_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_lusol_ci OBJECT
    CXSparse/Source/cs_lusol.c
    )
  set_target_properties(cs_lusol_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_util_ci OBJECT
    CXSparse/Source/cs_util.c
    )
  set_target_properties(cs_util_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_multiply_ci OBJECT
    CXSparse/Source/cs_multiply.c
    )
  set_target_properties(cs_multiply_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_permute_ci OBJECT
    CXSparse/Source/cs_permute.c
    )
  set_target_properties(cs_permute_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_pinv_ci OBJECT
    CXSparse/Source/cs_pinv.c
    )
  set_target_properties(cs_pinv_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_post_ci OBJECT
    CXSparse/Source/cs_post.c
    )
  set_target_properties(cs_post_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_pvec_ci OBJECT
    CXSparse/Source/cs_pvec.c
    )
  set_target_properties(cs_pvec_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_qr_ci OBJECT
    CXSparse/Source/cs_qr.c
    )
  set_target_properties(cs_qr_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_qrsol_ci OBJECT
    CXSparse/Source/cs_qrsol.c
    )
  set_target_properties(cs_qrsol_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_scatter_ci OBJECT
    CXSparse/Source/cs_scatter.c
    )
  set_target_properties(cs_scatter_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_schol_ci OBJECT
    CXSparse/Source/cs_schol.c
    )
  set_target_properties(cs_schol_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_sqr_ci OBJECT
    CXSparse/Source/cs_sqr.c
    )
  set_target_properties(cs_sqr_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_symperm_ci OBJECT
    CXSparse/Source/cs_symperm.c
    )
  set_target_properties(cs_symperm_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_tdfs_ci OBJECT
    CXSparse/Source/cs_tdfs.c
    )
  set_target_properties(cs_tdfs_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_malloc_ci OBJECT
    CXSparse/Source/cs_malloc.c
    )
  set_target_properties(cs_malloc_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_transpose_ci OBJECT
    CXSparse/Source/cs_transpose.c
    )
  set_target_properties(cs_transpose_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_compress_ci OBJECT
    CXSparse/Source/cs_compress.c
    )
  set_target_properties(cs_compress_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_usolve_ci OBJECT
    CXSparse/Source/cs_usolve.c
    )
  set_target_properties(cs_usolve_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_utsolve_ci OBJECT
    CXSparse/Source/cs_utsolve.c
    )
  set_target_properties(cs_utsolve_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_scc_ci OBJECT
    CXSparse/Source/cs_scc.c
    )
  set_target_properties(cs_scc_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_maxtrans_ci OBJECT
    CXSparse/Source/cs_maxtrans.c
    )
  set_target_properties(cs_maxtrans_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_dmperm_ci OBJECT
    CXSparse/Source/cs_dmperm.c
    )
  set_target_properties(cs_dmperm_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_updown_ci OBJECT
    CXSparse/Source/cs_updown.c
    )
  set_target_properties(cs_updown_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_print_ci OBJECT
    CXSparse/Source/cs_print.c
    )
  set_target_properties(cs_print_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_norm_ci OBJECT
    CXSparse/Source/cs_norm.c
    )
  set_target_properties(cs_norm_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_load_ci OBJECT
    CXSparse/Source/cs_load.c
    )
  set_target_properties(cs_load_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_dfs_ci OBJECT
    CXSparse/Source/cs_dfs.c
    )
  set_target_properties(cs_dfs_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_reach_ci OBJECT
    CXSparse/Source/cs_reach.c
    )
  set_target_properties(cs_reach_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_spsolve_ci OBJECT
    CXSparse/Source/cs_spsolve.c
    )
  set_target_properties(cs_spsolve_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_leaf_ci OBJECT
    CXSparse/Source/cs_leaf.c
    )
  set_target_properties(cs_leaf_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_ereach_ci OBJECT
    CXSparse/Source/cs_ereach.c
    )
  set_target_properties(cs_ereach_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")

  add_library(cs_randperm_ci OBJECT
    CXSparse/Source/cs_randperm.c
    )
  set_target_properties(cs_randperm_ci PROPERTIES
    COMPILE_DEFINITIONS "CS_COMPLEX")



  #-DCS_LONG -DCS_COMPLEX
  add_library(cs_add_cl OBJECT
    CXSparse/Source/cs_add.c
    )
  set_target_properties(cs_add_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_amd_cl OBJECT
    CXSparse/Source/cs_amd.c
    )
  set_target_properties(cs_amd_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_chol_cl OBJECT
    CXSparse/Source/cs_chol.c
    )
  set_target_properties(cs_chol_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_cholsol_cl OBJECT
    CXSparse/Source/cs_cholsol.c
    )
  set_target_properties(cs_cholsol_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_counts_cl OBJECT
    CXSparse/Source/cs_counts.c
    )
  set_target_properties(cs_counts_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_cumsum_cl OBJECT
    CXSparse/Source/cs_cumsum.c
    )
  set_target_properties(cs_cumsum_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_droptol_cl OBJECT
    CXSparse/Source/cs_droptol.c
    )
  set_target_properties(cs_droptol_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_dropzeros_cl OBJECT
    CXSparse/Source/cs_dropzeros.c
    )
  set_target_properties(cs_dropzeros_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_dupl_cl OBJECT
    CXSparse/Source/cs_dupl.c
    )
  set_target_properties(cs_dupl_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_entry_cl OBJECT
    CXSparse/Source/cs_entry.c
    )
  set_target_properties(cs_entry_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_etree_cl OBJECT
    CXSparse/Source/cs_etree.c
    )
  set_target_properties(cs_etree_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_fkeep_cl OBJECT
    CXSparse/Source/cs_fkeep.c
    )
  set_target_properties(cs_fkeep_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_gaxpy_cl OBJECT
    CXSparse/Source/cs_gaxpy.c
    )
  set_target_properties(cs_gaxpy_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_happly_cl OBJECT
    CXSparse/Source/cs_happly.c
    )
  set_target_properties(cs_happly_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_house_cl OBJECT
    CXSparse/Source/cs_house.c
    )
  set_target_properties(cs_house_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_ipvec_cl OBJECT
    CXSparse/Source/cs_ipvec.c
    )
  set_target_properties(cs_ipvec_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_lsolve_cl OBJECT
    CXSparse/Source/cs_lsolve.c
    )
  set_target_properties(cs_lsolve_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_ltsolve_cl OBJECT
    CXSparse/Source/cs_ltsolve.c
    )
  set_target_properties(cs_ltsolve_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_lu_cl OBJECT
    CXSparse/Source/cs_lu.c
    )
  set_target_properties(cs_lu_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_lusol_cl OBJECT
    CXSparse/Source/cs_lusol.c
    )
  set_target_properties(cs_lusol_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_util_cl OBJECT
    CXSparse/Source/cs_util.c
    )
  set_target_properties(cs_util_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_multiply_cl OBJECT
    CXSparse/Source/cs_multiply.c
    )
  set_target_properties(cs_multiply_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_permute_cl OBJECT
    CXSparse/Source/cs_permute.c
    )
  set_target_properties(cs_permute_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_pinv_cl OBJECT
    CXSparse/Source/cs_pinv.c
    )
  set_target_properties(cs_pinv_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_post_cl OBJECT
    CXSparse/Source/cs_post.c
    )
  set_target_properties(cs_post_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_pvec_cl OBJECT
    CXSparse/Source/cs_pvec.c
    )
  set_target_properties(cs_pvec_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_qr_cl OBJECT
    CXSparse/Source/cs_qr.c
    )
  set_target_properties(cs_qr_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_qrsol_cl OBJECT
    CXSparse/Source/cs_qrsol.c
    )
  set_target_properties(cs_qrsol_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_scatter_cl OBJECT
    CXSparse/Source/cs_scatter.c
    )
  set_target_properties(cs_scatter_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_schol_cl OBJECT
    CXSparse/Source/cs_schol.c
    )
  set_target_properties(cs_schol_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_sqr_cl OBJECT
    CXSparse/Source/cs_sqr.c
    )
  set_target_properties(cs_sqr_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_symperm_cl OBJECT
    CXSparse/Source/cs_symperm.c
    )
  set_target_properties(cs_symperm_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_tdfs_cl OBJECT
    CXSparse/Source/cs_tdfs.c
    )
  set_target_properties(cs_tdfs_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_malloc_cl OBJECT
    CXSparse/Source/cs_malloc.c
    )
  set_target_properties(cs_malloc_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_transpose_cl OBJECT
    CXSparse/Source/cs_transpose.c
    )
  set_target_properties(cs_transpose_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_compress_cl OBJECT
    CXSparse/Source/cs_compress.c
    )
  set_target_properties(cs_compress_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_usolve_cl OBJECT
    CXSparse/Source/cs_usolve.c
    )
  set_target_properties(cs_usolve_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_utsolve_cl OBJECT
    CXSparse/Source/cs_utsolve.c
    )
  set_target_properties(cs_utsolve_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_scc_cl OBJECT
    CXSparse/Source/cs_scc.c
    )
  set_target_properties(cs_scc_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_maxtrans_cl OBJECT
    CXSparse/Source/cs_maxtrans.c
    )
  set_target_properties(cs_maxtrans_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_dmperm_cl OBJECT
    CXSparse/Source/cs_dmperm.c
    )
  set_target_properties(cs_dmperm_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_updown_cl OBJECT
    CXSparse/Source/cs_updown.c
    )
  set_target_properties(cs_updown_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_print_cl OBJECT
    CXSparse/Source/cs_print.c
    )
  set_target_properties(cs_print_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_norm_cl OBJECT
    CXSparse/Source/cs_norm.c
    )
  set_target_properties(cs_norm_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_load_cl OBJECT
    CXSparse/Source/cs_load.c
    )
  set_target_properties(cs_load_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_dfs_cl OBJECT
    CXSparse/Source/cs_dfs.c
    )
  set_target_properties(cs_dfs_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_reach_cl OBJECT
    CXSparse/Source/cs_reach.c
    )
  set_target_properties(cs_reach_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_spsolve_cl OBJECT
    CXSparse/Source/cs_spsolve.c
    )
  set_target_properties(cs_spsolve_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_leaf_cl OBJECT
    CXSparse/Source/cs_leaf.c
    )
  set_target_properties(cs_leaf_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_ereach_cl OBJECT
    CXSparse/Source/cs_ereach.c
    )
  set_target_properties(cs_ereach_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")

  add_library(cs_randperm_cl OBJECT
    CXSparse/Source/cs_randperm.c
    )
  set_target_properties(cs_randperm_cl PROPERTIES
    COMPILE_DEFINITIONS "CS_LONG;CS_COMPLEX")


  set (ci_cl_targets
    $<TARGET_OBJECTS:cs_add_ci>
    $<TARGET_OBJECTS:cs_ereach_ci>
    $<TARGET_OBJECTS:cs_malloc_ci>
    $<TARGET_OBJECTS:cs_scatter_ci>
    $<TARGET_OBJECTS:cs_dfs_ci>
    $<TARGET_OBJECTS:cs_leaf_ci>
    $<TARGET_OBJECTS:cs_print_ci>
    $<TARGET_OBJECTS:cs_transpose_ci>
    $<TARGET_OBJECTS:cs_amd_ci>
    $<TARGET_OBJECTS:cs_post_ci>
    $<TARGET_OBJECTS:cs_tdfs_ci>
    $<TARGET_OBJECTS:cs_etree_ci>
    $<TARGET_OBJECTS:cs_maxtrans_ci>
    $<TARGET_OBJECTS:cs_scc_ci>
    $<TARGET_OBJECTS:cs_ipvec_ci>
    $<TARGET_OBJECTS:cs_dmperm_ci>
    $<TARGET_OBJECTS:cs_load_ci>
    $<TARGET_OBJECTS:cs_chol_ci>
    $<TARGET_OBJECTS:cs_cumsum_ci>
    $<TARGET_OBJECTS:cs_pvec_ci>
    $<TARGET_OBJECTS:cs_updown_ci>
    $<TARGET_OBJECTS:cs_entry_ci>
    $<TARGET_OBJECTS:cs_lusol_ci>
    $<TARGET_OBJECTS:cs_reach_ci>
    $<TARGET_OBJECTS:cs_symperm_ci>
    $<TARGET_OBJECTS:cs_pinv_ci>
    $<TARGET_OBJECTS:cs_counts_ci>
    $<TARGET_OBJECTS:cs_house_ci>
    $<TARGET_OBJECTS:cs_utsolve_ci>
    $<TARGET_OBJECTS:cs_randperm_ci>
    $<TARGET_OBJECTS:cs_lu_ci>
    $<TARGET_OBJECTS:cs_dupl_ci>
    $<TARGET_OBJECTS:cs_dropzeros_ci>
    $<TARGET_OBJECTS:cs_ltsolve_ci>
    $<TARGET_OBJECTS:cs_qrsol_ci>
    $<TARGET_OBJECTS:cs_util_ci>
    $<TARGET_OBJECTS:cs_compress_ci>
    $<TARGET_OBJECTS:cs_happly_ci>
    $<TARGET_OBJECTS:cs_permute_ci>
    $<TARGET_OBJECTS:cs_sqr_ci>
    $<TARGET_OBJECTS:cs_gaxpy_ci>
    $<TARGET_OBJECTS:cs_norm_ci>
    $<TARGET_OBJECTS:cs_spsolve_ci>
    $<TARGET_OBJECTS:cs_cholsol_ci>
    $<TARGET_OBJECTS:cs_qr_ci>
    $<TARGET_OBJECTS:cs_usolve_ci>
    $<TARGET_OBJECTS:cs_lsolve_ci>
    $<TARGET_OBJECTS:cs_droptol_ci>

    $<TARGET_OBJECTS:cs_cumsum_cl>
    $<TARGET_OBJECTS:cs_ipvec_cl>
    $<TARGET_OBJECTS:cs_post_cl>
    $<TARGET_OBJECTS:cs_tdfs_cl>
    $<TARGET_OBJECTS:cs_add_cl>
    $<TARGET_OBJECTS:cs_ereach_cl>
    $<TARGET_OBJECTS:cs_malloc_cl>
    $<TARGET_OBJECTS:cs_scatter_cl>
    $<TARGET_OBJECTS:cs_dfs_cl>
    $<TARGET_OBJECTS:cs_leaf_cl>
    $<TARGET_OBJECTS:cs_print_cl>
    $<TARGET_OBJECTS:cs_transpose_cl>
    $<TARGET_OBJECTS:cs_amd_cl>
    $<TARGET_OBJECTS:cs_reach_cl>
    $<TARGET_OBJECTS:cs_lusol_cl>
    $<TARGET_OBJECTS:cs_etree_cl>
    $<TARGET_OBJECTS:cs_maxtrans_cl>
    $<TARGET_OBJECTS:cs_scc_cl>
    $<TARGET_OBJECTS:cs_entry_cl>
    $<TARGET_OBJECTS:cs_counts_cl>
    $<TARGET_OBJECTS:cs_house_cl>
    $<TARGET_OBJECTS:cs_pinv_cl>
    $<TARGET_OBJECTS:cs_symperm_cl>
    $<TARGET_OBJECTS:cs_dupl_cl>
    $<TARGET_OBJECTS:cs_lu_cl>
    $<TARGET_OBJECTS:cs_randperm_cl>
    $<TARGET_OBJECTS:cs_utsolve_cl>
    $<TARGET_OBJECTS:cs_happly_cl>
    $<TARGET_OBJECTS:cs_permute_cl>
    $<TARGET_OBJECTS:cs_sqr_cl>
    $<TARGET_OBJECTS:cs_dropzeros_cl>
    $<TARGET_OBJECTS:cs_ltsolve_cl>
    $<TARGET_OBJECTS:cs_qrsol_cl>
    $<TARGET_OBJECTS:cs_util_cl>
    $<TARGET_OBJECTS:cs_compress_cl>
    $<TARGET_OBJECTS:cs_spsolve_cl>
    $<TARGET_OBJECTS:cs_dmperm_cl>
    $<TARGET_OBJECTS:cs_load_cl>
    $<TARGET_OBJECTS:cs_pvec_cl>
    $<TARGET_OBJECTS:cs_updown_cl>
    $<TARGET_OBJECTS:cs_chol_cl>
    $<TARGET_OBJECTS:cs_fkeep_cl>
    $<TARGET_OBJECTS:cs_multiply_cl>
    $<TARGET_OBJECTS:cs_schol_cl>
    $<TARGET_OBJECTS:cs_gaxpy_cl>
    $<TARGET_OBJECTS:cs_norm_cl>
    $<TARGET_OBJECTS:cs_usolve_cl>
    $<TARGET_OBJECTS:cs_cholsol_cl>
    $<TARGET_OBJECTS:cs_qr_cl>
    $<TARGET_OBJECTS:cs_droptol_cl>
    $<TARGET_OBJECTS:cs_lsolve_cl>
    $<TARGET_OBJECTS:cs_fkeep_ci>
    $<TARGET_OBJECTS:cs_multiply_ci>
    $<TARGET_OBJECTS:cs_schol_ci>

    $<TARGET_OBJECTS:cs_convert>
    )
endif()

add_library( cxsparse
  ${ci_cl_targets}
  $<TARGET_OBJECTS:cs_add_di>
  $<TARGET_OBJECTS:cs_cumsum_di>
  $<TARGET_OBJECTS:cs_dfs_di>
  $<TARGET_OBJECTS:cs_ereach_di>
  $<TARGET_OBJECTS:cs_ipvec_di>
  $<TARGET_OBJECTS:cs_malloc_di>
  $<TARGET_OBJECTS:cs_norm_di>
  $<TARGET_OBJECTS:cs_print_di>
  $<TARGET_OBJECTS:cs_post_di>
  $<TARGET_OBJECTS:cs_reach_di>
  $<TARGET_OBJECTS:cs_tdfs_di>
  $<TARGET_OBJECTS:cs_scatter_di>
  $<TARGET_OBJECTS:cs_leaf_di>
  $<TARGET_OBJECTS:cs_transpose_di>
  $<TARGET_OBJECTS:cs_amd_di>
  $<TARGET_OBJECTS:cs_entry_di>
  $<TARGET_OBJECTS:cs_lusol_di>
  $<TARGET_OBJECTS:cs_etree_di>
  $<TARGET_OBJECTS:cs_maxtrans_di>
  $<TARGET_OBJECTS:cs_scc_di>
  $<TARGET_OBJECTS:cs_counts_di>
  $<TARGET_OBJECTS:cs_house_di>
  $<TARGET_OBJECTS:cs_pinv_di>
  $<TARGET_OBJECTS:cs_symperm_di>
  $<TARGET_OBJECTS:cs_utsolve_di>
  $<TARGET_OBJECTS:cs_randperm_di>
  $<TARGET_OBJECTS:cs_lu_di>
  $<TARGET_OBJECTS:cs_dupl_di>
  $<TARGET_OBJECTS:cs_happly_di>
  $<TARGET_OBJECTS:cs_permute_di>
  $<TARGET_OBJECTS:cs_sqr_di>
  $<TARGET_OBJECTS:cs_util_di>
  $<TARGET_OBJECTS:cs_qrsol_di>
  $<TARGET_OBJECTS:cs_compress_di>
  $<TARGET_OBJECTS:cs_ltsolve_di>
  $<TARGET_OBJECTS:cs_dropzeros_di>
  $<TARGET_OBJECTS:cs_spsolve_di>
  $<TARGET_OBJECTS:cs_gaxpy_di>
  $<TARGET_OBJECTS:cs_usolve_di>
  $<TARGET_OBJECTS:cs_cholsol_di>
  $<TARGET_OBJECTS:cs_dmperm_di>
  $<TARGET_OBJECTS:cs_load_di>
  $<TARGET_OBJECTS:cs_pvec_di>
  $<TARGET_OBJECTS:cs_updown_di>
  $<TARGET_OBJECTS:cs_chol_di>
  $<TARGET_OBJECTS:cs_fkeep_di>
  $<TARGET_OBJECTS:cs_multiply_di>
  $<TARGET_OBJECTS:cs_schol_di>
  $<TARGET_OBJECTS:cs_droptol_di>
  $<TARGET_OBJECTS:cs_lsolve_di>
  $<TARGET_OBJECTS:cs_qr_di>

  $<TARGET_OBJECTS:cs_entry_dl>
  $<TARGET_OBJECTS:cs_lusol_dl>
  $<TARGET_OBJECTS:cs_reach_dl>
  $<TARGET_OBJECTS:cs_tdfs_dl>
  $<TARGET_OBJECTS:cs_add_dl>
  $<TARGET_OBJECTS:cs_cumsum_dl>
  $<TARGET_OBJECTS:cs_ipvec_dl>
  $<TARGET_OBJECTS:cs_post_dl>
  $<TARGET_OBJECTS:cs_ereach_dl>
  $<TARGET_OBJECTS:cs_malloc_dl>
  $<TARGET_OBJECTS:cs_scatter_dl>
  $<TARGET_OBJECTS:cs_house_dl>
  $<TARGET_OBJECTS:cs_pinv_dl>
  $<TARGET_OBJECTS:cs_symperm_dl>
  $<TARGET_OBJECTS:cs_dfs_dl>
  $<TARGET_OBJECTS:cs_leaf_dl>
  $<TARGET_OBJECTS:cs_print_dl>
  $<TARGET_OBJECTS:cs_transpose_dl>
  $<TARGET_OBJECTS:cs_amd_dl>
  $<TARGET_OBJECTS:cs_dupl_dl>
  $<TARGET_OBJECTS:cs_lu_dl>
  $<TARGET_OBJECTS:cs_counts_dl>
  $<TARGET_OBJECTS:cs_randperm_dl>
  $<TARGET_OBJECTS:cs_utsolve_dl>
  $<TARGET_OBJECTS:cs_happly_dl>
  $<TARGET_OBJECTS:cs_permute_dl>
  $<TARGET_OBJECTS:cs_sqr_dl>
  $<TARGET_OBJECTS:cs_util_dl>
  $<TARGET_OBJECTS:cs_compress_dl>
  $<TARGET_OBJECTS:cs_ltsolve_dl>
  $<TARGET_OBJECTS:cs_norm_dl>
  $<TARGET_OBJECTS:cs_etree_dl>
  $<TARGET_OBJECTS:cs_dropzeros_dl>
  $<TARGET_OBJECTS:cs_qrsol_dl>
  $<TARGET_OBJECTS:cs_spsolve_dl>
  $<TARGET_OBJECTS:cs_gaxpy_dl>
  $<TARGET_OBJECTS:cs_droptol_dl>
  $<TARGET_OBJECTS:cs_lsolve_dl>
  $<TARGET_OBJECTS:cs_qr_dl>
  $<TARGET_OBJECTS:cs_usolve_dl>
  $<TARGET_OBJECTS:cs_cholsol_dl>
  $<TARGET_OBJECTS:cs_maxtrans_dl>
  $<TARGET_OBJECTS:cs_scc_dl>
  $<TARGET_OBJECTS:cs_multiply_dl>
  $<TARGET_OBJECTS:cs_schol_dl>
  $<TARGET_OBJECTS:cs_fkeep_dl>
  $<TARGET_OBJECTS:cs_updown_dl>
  $<TARGET_OBJECTS:cs_chol_dl>
  $<TARGET_OBJECTS:cs_pvec_dl>
  $<TARGET_OBJECTS:cs_load_dl>
  $<TARGET_OBJECTS:cs_dmperm_dl>
  )

install( FILES CXSparse/Include/cs.h DESTINATION include )
install( FILES SuiteSparse_config/SuiteSparse_config.h DESTINATION include )

install(TARGETS cxsparse DESTINATION lib)
