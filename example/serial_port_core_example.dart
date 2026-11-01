// A protocol written against SerialPort works over USB and Bluetooth alike.
import 'dart:async';

import 'package:serial_port_core/serial_port_core.dart';

/// Sends AT commands and waits for the reply line, whatever the transport.
class AtModem {
  AtModem(this.port) : _lines = StreamIterator(port.lines());

  final SerialPort port;
  final StreamIterator<String> _lines;

  /// Sends [command] and returns the lines up to "OK", or throws on "ERROR".
  Future<List<String>> send(String command,
      {Duration timeout = const Duration(seconds: 2)}) async {
    await port.writeText('$command\r\n');
    final reply = <String>[];
    while (await _lines.moveNext().timeout(timeout)) {
      final line = _lines.current.trim();
      if (line.isEmpty || line == command) continue;
      if (line == 'OK') return reply;
      if (line == 'ERROR') {
        throw SerialException(SerialError.io, '$command failed: $reply');
      }
      reply.add(line);
    }
    throw const SerialException(SerialError.portClosed, 'port closed');
  }
}

// With usb_serial_next:
//   final port = await UsbSerial.instance.open(device);
// or with bluetooth_serial_next:
//   final port = await BluetoothSerial.instance.open(address);
// and then the same code:
//   final modem = AtModem(port);
//   print(await modem.send('AT+GMR'));
Future<void> useModem(SerialPort port) async {
  final modem = AtModem(port);
  try {
    print(await modem.send('AT+GMR'));
  } on SerialException catch (e) {
    print('Modem said no: ${e.error.name}, ${e.message}');
  } finally {
    await port.close();
  }
}
