cd D:/Nexys2_Lcd_Controll_Prj_using_EPC/blaze
if { [ catch { xload xmp blaze.xmp } result ] } {
  exit 10
}

if { [catch {run init_bram} result] } {
  exit -1
}

exit 0
