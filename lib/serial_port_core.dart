// Copyright 2026 Alexei Zalogin. Use of this source code is governed by the MIT license in the LICENSE file.

/// The serial port interface shared by usb_serial_next and
/// bluetooth_serial_next: [SerialPort], the [SerialPortText] helpers, and
/// [SerialException] with a [SerialError] for every failure.
///
/// Depend on this package when you write a protocol (Modbus RTU, ELM327,
/// ESC/POS, your own) that should work over any transport.
library;

export 'src/serial_exception.dart';
export 'src/serial_port.dart';
