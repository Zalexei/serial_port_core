## 0.1.0

* First release: `SerialPort`, the `lines()` and `writeText()` helpers, and
  `SerialException` with `SerialError`, taken out of usb_serial_next 0.1.0
  so that bluetooth_serial_next can share them. New errors for Bluetooth:
  `adapterOff`, `notPaired`, `connectionFailed`.
