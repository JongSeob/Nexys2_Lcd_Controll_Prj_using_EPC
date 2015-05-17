proc exportToSDK {} {
  cd D:/Nexys2_Lcd_Controll_Prj_using_EPC/blaze
  if { [ catch { xload xmp blaze.xmp } result ] } {
    exit 10
  }
  if { [run exporttosdk] != 0 } {
    return -1
  }
  return 0
}

if { [catch {exportToSDK} result] } {
  exit -1
}

set sExportDir [ xget sdk_export_dir ]
set sExportDir [ file join "D:/Nexys2_Lcd_Controll_Prj_using_EPC/blaze" "$sExportDir" "hw" ] 
if { [ file exists D:/Nexys2_Lcd_Controll_Prj_using_EPC/edkBmmFile_bd.bmm ] } {
   puts "Copying placed bmm file D:/Nexys2_Lcd_Controll_Prj_using_EPC/edkBmmFile_bd.bmm to $sExportDir" 
   file copy -force "D:/Nexys2_Lcd_Controll_Prj_using_EPC/edkBmmFile_bd.bmm" $sExportDir
}
if { [ file exists D:/Nexys2_Lcd_Controll_Prj_using_EPC/top.bit ] } {
   puts "Copying bit file D:/Nexys2_Lcd_Controll_Prj_using_EPC/top.bit to $sExportDir" 
   file copy -force "D:/Nexys2_Lcd_Controll_Prj_using_EPC/top.bit" $sExportDir
}
exit $result
