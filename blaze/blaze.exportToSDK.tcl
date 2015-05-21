proc exportToSDK {} {
  cd E:/Nexys2_LCD_UART_EPC/blaze
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
set sExportDir [ file join "E:/Nexys2_LCD_UART_EPC/blaze" "$sExportDir" "hw" ] 
if { [ file exists E:/Nexys2_LCD_UART_EPC/edkBmmFile_bd.bmm ] } {
   puts "Copying placed bmm file E:/Nexys2_LCD_UART_EPC/edkBmmFile_bd.bmm to $sExportDir" 
   file copy -force "E:/Nexys2_LCD_UART_EPC/edkBmmFile_bd.bmm" $sExportDir
}
if { [ file exists E:/Nexys2_LCD_UART_EPC/top.bit ] } {
   puts "Copying bit file E:/Nexys2_LCD_UART_EPC/top.bit to $sExportDir" 
   file copy -force "E:/Nexys2_LCD_UART_EPC/top.bit" $sExportDir
}
exit $result
