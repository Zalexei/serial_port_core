# serial_port_core

[![pub package](https://img.shields.io/pub/v/serial_port_core.svg)](https://pub.dev/packages/serial_port_core)

The serial port interface shared by
[`usb_serial_next`](https://pub.dev/packages/usb_serial_next) (USB OTG on
Android) and
[`bluetooth_serial_next`](https://pub.dev/packages/bluetooth_serial_next)
(Bluetooth Classic SPP on Android). Pure Dart, no dependencies.

- `SerialPort`: `input` (`Stream<Uint8List>`, buffered until you listen),
  `write`, `isOpen`, `closed` (with the reason), `close`.
- `lines()` and `writeText()`: UTF-8 (or another encoding) lines split on
  `\n`, `\r\n` and `\r`, also across chunks.
- `SerialException` with a `SerialError` for every failure, the same values
  in both plugins.

You do not need to add this package to use either plugin: both export it.
Depend on it when you write a protocol (Modbus RTU, ELM327, ESC/POS, AT
commands, your own) that should work over any transport:

```dart
import 'package:serial_port_core/serial_port_core.dart';

class Elm327 {
  Elm327(this.port);
  final SerialPort port;

  Future<void> reset() => port.writeText('ATZ\r');
}

// Elm327(await UsbSerial.instance.open(usbDevice));
// Elm327(await BluetoothSerial.instance.open('00:1D:A5:68:98:8B', channel: 1));
```

For tests, implement `SerialPort` with a `StreamController`; see
[`test/serial_port_core_test.dart`](test/serial_port_core_test.dart).

## Errors

| `SerialError` | When |
|---|---|
| `permissionDenied` | No permission for the device, or the user said no |
| `deviceNotFound` | The device is not attached or not known |
| `unsupportedDevice` | No driver knows the device (USB) |
| `disconnected` | The connection was lost while open |
| `portClosed` | The port was closed before or during the call |
| `busy` | Already open, here or in another app |
| `invalidArgument` | A value out of range |
| `unsupportedOperation` | The device or platform cannot do this |
| `timeout` | The operation did not finish in time |
| `adapterOff` | The radio is off (Bluetooth) |
| `notPaired` | The device has to be paired (again) (Bluetooth) |
| `connectionFailed` | The device did not take the connection (Bluetooth) |
| `io` | Anything else; see `message` |

## License

MIT, see [LICENSE](LICENSE).
