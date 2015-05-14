
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Assignment5 -dir "E:/Assignment5/planAhead_run_1" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "E:/Assignment5/top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {E:/Assignment5} }
add_files [list {E:/Assignment5/blaze.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {E:/Assignment5/blaze_clock_generator_0_wrapper.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {E:/Assignment5/blaze_dlmb_wrapper.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {E:/Assignment5/blaze_ilmb_wrapper.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {E:/Assignment5/blaze_microblaze_0_wrapper.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "top.ucf" [current_fileset -constrset]
add_files [list {top.ucf}] -fileset [get_property constrset [current_run]]
link_design
