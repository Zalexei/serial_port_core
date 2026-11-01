// Copyright 2026 Alexei Zalogin. Use of this source code is governed by the MIT license in the LICENSE file.

/// Why an operation failed.
enum SerialError {
  /// The app has no permission for the device, or the user said no.
  permissionDenied,

  /// The device is not attached, not known or no longer there.
  deviceNotFound,

  /// No driver knows the device. If you know the chip, pass a driver to
  /// `UsbSerial.open`.
  unsupportedDevice,

  /// The connection was lost while the port was open: the cable was
  /// unplugged, or the device went out of range or was switched off.
  disconnected,

  /// The port was closed before or during the operation.
  portClosed,

  /// The port is already open, here or in another app.
  busy,

  /// A value is out of range: baud rate, data bits, port index, address.
  invalidArgument,

  /// The chip or platform cannot do this, for example flow control on a
  /// chip without it.
  unsupportedOperation,

  /// The operation did not finish in time.
  timeout,

  /// The radio the transport needs is switched off, for example Bluetooth.
  adapterOff,

  /// The device has to be paired first, or it forgot the pairing (after a
  /// firmware update, for example) and has to be paired again.
  notPaired,

  /// The device did not take the connection: it is off or out of range, it
  /// has no such service, or it is connected to someone else.
  connectionFailed,

  /// Any other failure; see [SerialException.message].
  io,
}

/// What every call of a serial plugin throws when it fails, and what the
/// [Stream]s of received data end with when a connection is lost.
class SerialException implements Exception {
  const SerialException(this.error, [this.message, this.bytesWritten]);

  /// Converts an error code from the platform side, for plugins; [details]
  /// is the number of bytes written before a timeout.
  factory SerialException.fromCode(String code,
      [String? message, Object? details]) {
    final error = _codes[code];
    if (error == null) {
      // An unknown code is itself the clue (a channel error, an engine that
      // went away), so it stays in the message.
      return SerialException(SerialError.io, '$code: $message');
    }
    return SerialException(error, message, details is int ? details : null);
  }

  static const _codes = {
    'permission_denied': SerialError.permissionDenied,
    'device_not_found': SerialError.deviceNotFound,
    'unsupported_device': SerialError.unsupportedDevice,
    'disconnected': SerialError.disconnected,
    'port_closed': SerialError.portClosed,
    'busy': SerialError.busy,
    'invalid_argument': SerialError.invalidArgument,
    'unsupported_operation': SerialError.unsupportedOperation,
    'timeout': SerialError.timeout,
    'adapter_off': SerialError.adapterOff,
    'not_paired': SerialError.notPaired,
    'connection_failed': SerialError.connectionFailed,
    'io_error': SerialError.io,
  };

  /// Why it failed.
  final SerialError error;

  /// Details for logs, in English.
  final String? message;

  /// For a write that hit [SerialError.timeout]: how many bytes surely went
  /// out before it. Counted in whole chunks, so more may have.
  final int? bytesWritten;

  @override
  String toString() => 'SerialException(${error.name}: $message)';
}
