import 'package:flutter_test/flutter_test.dart';
import 'package:three_dart/three3d/core/index.dart';

void main() {
  group('Layers', () {
    // INSTANCING
    test('Instancing', () {
      // expect( false, 'everything\'s gonna be alright' );
    });

    // PUBLIC STUFF
    test('set', () {
      var a = new Layers();

      a.set(0);
      expect(a.mask, 1, reason: 'Set channel 0');

      a.set(1);
      expect(a.mask, 2, reason: 'Set channel 1');

      a.set(2);
      expect(a.mask, 4, reason: 'Set channel 2');
    });

    test('enable', () {
      var a = new Layers();

      a.set(0);
      a.enable(0);
      //  'Enable channel 0 with mask 0'
      expect(a.mask, 1);

      a.set(0);
      a.enable(1);
      // 'Enable channel 1 with mask 0'
      expect(a.mask, 3);

      a.set(1);
      a.enable(0);
      // 'Enable channel 0 with mask 1'
      expect(a.mask, 3);

      a.set(1);
      a.enable(1);
      // 'Enable channel 1 with mask 1'
      expect(a.mask, 2);
    });

    test('toggle', () {
      var a = new Layers();

      a.set(0);
      a.toggle(0);
      //  'Toggle channel 0 with mask 0'
      expect(a.mask, 0);

      a.set(0);
      a.toggle(1);
      // 'Toggle channel 1 with mask 0'
      expect(a.mask, 3);

      a.set(1);
      a.toggle(0);

      // 'Toggle channel 0 with mask 1'
      expect(a.mask, 3);

      a.set(1);
      a.toggle(1);

      // 'Toggle channel 1 with mask 1'
      expect(a.mask, 0);
    });

    test('disable', () {
      var a = Layers();

      a.set(0);
      a.disable(0);
      // 'Disable channel 0 with mask 0'
      expect(a.mask, 0);

      a.set(0);
      a.disable(1);

      // 'Disable channel 1 with mask 0'
      expect(
        a.mask,
        1,
      );

      a.set(1);
      a.disable(0);
      // 'Disable channel 0 with mask 1'
      expect(a.mask, 2);

      a.set(1);
      a.disable(1);

      // 'Disable channel 1 with mask 1'
      expect(a.mask, 0);
    });

    test('test', () {
      var a = Layers();
      var b = Layers();

      expect(a.test(b), true);

      a.set(1);
      expect(a.test(b), false);

      b.toggle(1);
      // 'Toggle channel 1 in b and pass again'
      expect(a.test(b), true);
    });

    test('isEnabled', () {
      var a = new Layers();

      a.enable(1);
      // 'Enable channel 1 and pass the QUnit.test'
      expect(a.isEnabled(1), true);

      a.enable(2);
      // 'Enable channel 2 and pass the QUnit.test'
      expect(a.isEnabled(2), true);

      a.toggle(1);
      // 'Toggle channel 1 and fail the QUnit.test'
      expect(a.isEnabled(1), false);

      //  'Channel 2 still enabled and pass the QUnit.test'
      expect(a.isEnabled(2), true);
    });
  });
}
