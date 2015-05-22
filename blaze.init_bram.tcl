cd E:/Nexys2_LCD_UART_EPC/blaze
if { [ catch { xload xmp blaze.xmp } result ] } {
  exit 10
}

if { [catch {run init_bram} result] } {
  exit -1
}

exit 0
