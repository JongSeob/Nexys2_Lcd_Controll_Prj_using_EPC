proc exportToSDK {} {
  cd E:/Assignment5/blaze
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
set sExportDir [ file join "E:/Assignment5/blaze" "$sExportDir" "hw" ] 
if { [ file exists E:/Assignment5/edkBmmFile_bd.bmm ] } {
   puts "Copying placed bmm file E:/Assignment5/edkBmmFile_bd.bmm to $sExportDir" 
   file copy -force "E:/Assignment5/edkBmmFile_bd.bmm" $sExportDir
}
if { [ file exists E:/Assignment5/top.bit ] } {
   puts "Copying bit file E:/Assignment5/top.bit to $sExportDir" 
   file copy -force "E:/Assignment5/top.bit" $sExportDir
}
exit $result
