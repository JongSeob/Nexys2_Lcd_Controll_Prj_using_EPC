proc pnsynth {} {
  cd E:/Nexys2_LCD_UART_EPC/blaze
  if { [ catch { xload xmp blaze.xmp } result ] } {
    exit 10
  }
  if { [catch {run netlist} result] } {
    return -1
  }
  return $result
}
if { [catch {pnsynth} result] } {
  exit -1
}
exit $result
