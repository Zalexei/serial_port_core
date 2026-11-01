import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:serial_port_core/serial_port_core.dart';
import 'package:test/test.dart';

/// A port fed by the test.
class _FakePort implements SerialPort {
  final _input = StreamController<Uint8List>();
  final written = <List<int>>[];

  void receive(List<int> bytes) => _input.add(Uint8List.fromList(bytes));

  @override
  Stream<Uint8List> get input => _input.stream;

  @override
  Future<void> write(List<int> data) async => written.add(data);

  @override
  bool get isOpen => !_input.isClosed;

  @override
  Future<SerialException?> get closed => _input.done.then((_) => null);

  @override
  Future<void> close() => _input.close();
}

void main() {
  test('lines() splits across chunks and survives bad bytes', () async {
    final port = _FakePort();
    final lines = port.lines().toList();

    port
      ..receive('temp=2'.codeUnits)
      ..receive('1.5\r\nhum'.codeUnits)
      ..receive([0xff])
      ..receive('=40\nend'.codeUnits);
    await port.close();

    expect(await lines, ['temp=21.5', 'hum\u{fffd}=40', 'end']);
  });

  test('lines() takes another encoding', () async {
    final port = _FakePort();
    final lines = port.lines(encoding: latin1).toList();

    port.receive([0x63, 0x61, 0x66, 0xe9, 0x0a]);
    await port.close();

    expect(await lines, ['café']);
  });

  test('writeText encodes UTF-8', () async {
    final port = _FakePort();

    await port.writeText('AT+ПРИВЕТ\r\n');

    expect(port.written.single, hasLength(17));
    expect(utf8.decode(port.written.single), 'AT+ПРИВЕТ\r\n');
  });

  group('SerialException.fromCode', () {
    test('maps every known code', () {
      const codes = {
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
      for (final MapEntry(:key, :value) in codes.entries) {
        expect(SerialException.fromCode(key, 'm').error, value, reason: key);
      }
      expect(codes.values.toSet(), SerialError.values.toSet());
    });

    test('keeps an unknown code in the message', () {
      final e = SerialException.fromCode('channel-error', 'no engine');

      expect(e.error, SerialError.io);
      expect(e.message, 'channel-error: no engine');
    });

    test('reads bytes written from the details', () {
      final e = SerialException.fromCode('timeout', 'slow', 4096);

      expect(e.bytesWritten, 4096);
      expect(SerialException.fromCode('timeout', 'slow', 'x').bytesWritten,
          isNull);
    });
  });

  test('toString names the error', () {
    expect(const SerialException(SerialError.busy, 'open elsewhere').toString(),
        'SerialException(busy: open elsewhere)');
  });
}
