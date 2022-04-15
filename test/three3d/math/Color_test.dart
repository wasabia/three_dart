import 'package:flutter_test/flutter_test.dart';
import 'package:three_dart/three3d/math/index.dart';

import 'Constants_test.dart';

void main() {
  group('Maths', () {
    group('Color', () {
      // INSTANCING
      test("Instancing", () {
        // default ctor
        var c1 = Color();
        expect(c1.r, 1.0);
        expect(c1.g, 1.0);
        expect(c1.b, 1.0);

        // rgb ctor
        var c2 = Color(1, 1, 1);
        expect(c2.r, 1);
        expect(c2.g, 1);
        expect(c2.b, 1);
      });

      // EXPOSED CONSTANTS
      test("Exposed Color.NAMES", () {
        expect(Color.NAMES["aliceblue"], 0xF0F8FF);
      });

      // PUBLIC STUFF
      test("isColor", () {
        var a = Color();
        expect(a.isColor, true);

        var b = Object();
        expect(!(b is Color), true);
      });

      group("set", () {
        var a = Color();
        var b = Color(0.5, 0, 0);
        var c = Color(0xFF0000);
        var d = Color(0, 1.0, 0);

        test("Set with Color instance", () {
          a.set(b);
          expect(a.equal(b), true);
        });

        test("Set with number", () {
          a.set(0xFF0000);

          print(" a: ${a.toArray()} ");
          print(" c: ${c.toArray()} ");

          expect(a.equal(c), true);
        });

        test("Set with style", () {
          a.set("rgb(0,255,0)");
          expect(a.equal(d), true);
        });
      });

      test("setScalar", () {
        var c = Color();
        c.setScalar(0.5);

        expect(c.r, 0.5);
        expect(c.g, 0.5);
        expect(c.b, 0.5);
      });

      test("setHex", () {
        var c = Color();
        c.setHex(0xFA8072);
        expect(c.getHex(), 0xFA8072);
        expect(c.r, 0xFA / 0xFF);
        expect(c.g, 0x80 / 0xFF);
        expect(c.b, 0x72 / 0xFF);
      });

      test("setRGB", () {
        var c = Color();
        c.setRGB(0.3, 0.5, 0.7);
        expect(c.r, 0.3);
        expect(c.g, 0.5);
        expect(c.b, 0.7);
      });

      test("setHSL", () {
        var c = Color();
        Map<String, dynamic> hsl = {"h": 0, "s": 0, "l": 0};
        c.setHSL(0.75, 1.0, 0.25);
        c.getHSL(hsl);

        expect(hsl["h"], 0.75);
        expect(hsl["s"], 1.00);
        expect(hsl["l"], 0.25);
      });

      test("setStyle", () {
        var a = Color();

        var b = Color(8 / 255, 25 / 255, 178 / 255);
        a.setStyle("rgb(8,25,178)");
        expect(a.equals(b), true);

        b = Color(8 / 255, 25 / 255, 178 / 255);
        a.setStyle("rgba(8,25,178,200)");
        expect(a.equals(b), true);

        Map<String, dynamic> hsl = {"h": 0, "s": 0, "l": 0};
        a.setStyle("hsl(270,50%,75%)");
        a.getHSL(hsl);
        expect(hsl["h"], 0.75);
        expect(hsl["s"], 0.5);
        expect(hsl["l"], 0.75);

        hsl = {"h": 0, "s": 0, "l": 0};
        a.setStyle("hsl(270,50%,75%)");
        a.getHSL(hsl);
        expect(hsl["h"], 0.75);
        expect(hsl["s"], 0.5);
        expect(hsl["l"], 0.75);

        a.setStyle("#F8A");
        expect(a.r, 0xFF / 255);
        expect(a.g, 0x88 / 255);
        expect(a.b, 0xAA / 255);

        a.setStyle("#F8ABC1");
        expect(a.r, 0xF8 / 255);
        expect(a.g, 0xAB / 255);
        expect(a.b, 0xC1 / 255);

        a.setStyle("aliceblue");
        expect(a.r, 0xF0 / 255);
        expect(a.g, 0xF8 / 255);
        expect(a.b, 0xFF / 255);
      });

      test("setColorName", () {
        var c = Color();
        var res = c.setColorName("aliceblue");

        expect(c.getHex(), 0xF0F8FF);
        expect(c, res);
      });

      test("clone", () {
        var c = Color('teal');
        var c2 = c.clone();
        expect(c2.getHex(), 0x008080);
      });

      test("copy", () {
        var a = Color('teal');
        var b = Color();
        b.copy(a);
        expect(b.r, 0x00 / 255);
        expect(b.g, 0x80 / 255);
        expect(b.b, 0x80 / 255);
      });

      test("copyGammaToLinear", () {
        var c = Color();
        var c2 = Color();
        c2.setRGB(0.3, 0.5, 0.9);
        c.copyGammaToLinear(c2);
        expect(c.r, 0.09);
        expect(c.g, 0.25);
        expect(c.b, 0.81);
      });

      test("copyLinearToGamma", () {
        var c = Color();
        var c2 = Color();
        c2.setRGB(0.09, 0.25, 0.81);
        c.copyLinearToGamma(c2);
        expect(c.r, 0.3);
        expect(c.g, 0.5);
        expect(c.b, 0.9);
      });

      test("convertGammaToLinear", () {
        var c = Color();
        c.setRGB(0.3, 0.5, 0.9);
        c.convertGammaToLinear();
        expect(c.r, 0.09);
        expect(c.g, 0.25);
        expect(c.b, 0.81);
      });

      test("convertLinearToGamma", () {
        var c = Color();
        c.setRGB(4, 9, 16);
        c.convertLinearToGamma();
        expect(c.r, 2);
        expect(c.g, 3);
        expect(c.b, 4);
      });

      test("getHex", () {
        var c = Color('red');
        var res = c.getHex();
        expect(res, 0xFF0000);
      });

      test("getHexString", () {
        var c = Color('tomato');
        var res = c.getHexString();
        expect(res, 'ff6347');
      });

      test("getHSL", () {
        var c = Color(0x80ffff);
        Map<String, dynamic> hsl = {"h": 0, "s": 0, "l": 0};
        c.getHSL(hsl);

        expect(hsl["h"], 0.5);
        expect(hsl["s"], 1.0);
        expect((Math.round(hsl["l"] * 100) / 100), 0.75);
      });

      test("getStyle", () {
        var c = Color('plum');
        var res = c.getStyle();
        expect(
          res,
          'rgb(221.0,160.0,221.0)',
        );
      });

      test("offsetHSL", () {
        var a = Color("hsl(120,50%,50%)");
        var b = Color(0.36, 0.84, 0.648);

        a.offsetHSL(0.1, 0.1, 0.1);

        expect(Math.abs(a.r - b.r) <= eps, true);
        expect(Math.abs(a.g - b.g) <= eps, true);
        expect(Math.abs(a.b - b.b) <= eps, true);
      });

      test("add", () {
        var a = Color(0x0000FF);
        var b = Color(0xFF0000);
        var c = Color(0xFF00FF);

        a.add(b);

        expect(a.equals(c), true);
      });

      test("addColors", () {
        var a = Color(0x0000FF);
        var b = Color(0xFF0000);
        var c = Color(0xFF00FF);
        var d = Color();

        d.addColors(a, b);

        expect(d.equals(c), true);
      });

      test("addScalar", () {
        var a = Color(0.1, 0.0, 0.0);
        var b = Color(0.6, 0.5, 0.5);

        a.addScalar(0.5);

        expect(a.equals(b), true);
      });

      test("sub", () {
        var a = Color(0x0000CC);
        var b = Color(0xFF0000);
        var c = Color(0x0000AA);

        a.sub(b);
        expect(
          a.getHex(),
          0xCC,
        );

        a.sub(c);
        expect(a.getHex(), 0x22);
      });

      test("multiply", () {
        var a = Color(1, 0, 0.5);
        var b = Color(0.5, 1, 0.5);
        var c = Color(0.5, 0, 0.25);

        a.multiply(b);
        expect(a.equals(c), true);
      });

      test("multiplyScalar", () {
        var a = Color(0.25, 0, 0.5);
        var b = Color(0.5, 0, 1);

        a.multiplyScalar(2);
        expect(a.equals(b), true);
      });

      test("copyHex", () {
        var c = Color();
        var c2 = Color(0xF5FFFA);
        c.copy(c2);
        expect(c.getHex(), c2.getHex());
      });

      test("copyColorString", () {
        var c = Color();
        var c2 = Color('ivory');
        c.copy(c2);
        expect(c.getHex(), c2.getHex());
      });

      test("lerp", () {
        var c = Color();
        var c2 = Color();
        c.setRGB(0, 0, 0);
        c.lerp(c2, 0.2);
        expect(c.r, 0.2);
        expect(c.g, 0.2);
        expect(c.b, 0.2);
      });

      test("equals", () {
        var a = Color(0.5, 0.0, 1.0);
        var b = Color(0.5, 1.0, 0.0);

        expect(a.r, b.r);
        expect(a.g == b.g, false);
        expect(a.b == b.b, false);

        expect(a.equals(b), false);
        expect(b.equals(a), false);

        a.copy(b);
        expect(a.r, b.r);
        expect(a.g, b.g);
        expect(a.b, b.b);

        expect(a.equals(b), true);
        expect(b.equals(a), true);
      });

      group("fromArray", () {
        var a = Color();
        List<double> array = [0.5, 0.6, 0.7, 0, 1, 0];

        test("No offset: ", () {
          a.fromArray(array);
          expect(a.r, 0.5);
          expect(a.g, 0.6);
          expect(a.b, 0.7);
        });

        test("With offset:", () {
          a.fromArray(array, 3);
          expect(a.r, 0);
          expect(a.g, 1);
          expect(a.b, 0);
        });
      });

      group("toArray", () {
        var r = 0.5, g = 1.0, b = 0.0;
        var a = Color(r, g, b);

        test("No array, no offset", () {
          var array = a.toArray();
          expect(array[0], r);
          expect(array[1], g);
          expect(array[2], b);
        });

        test("With array, no offset", () {
          var array = List<num>.filled(3, 0.0);
          a.toArray(array);
          expect(array[0], r);
          expect(array[1], g);
          expect(array[2], b);
        });

        test("With array, offset", () {
          var array = List<num>.filled(5, 0.0);
          a.toArray(array, 1);
          expect(array[0], 0.0);
          expect(array[1], r);
          expect(array[2], g);
          expect(array[3], b);
        });
      });

      test("toJSON", () {
        var a = Color(0.0, 0.0, 0.0);
        var b = Color(0.0, 0.5, 0.0);
        var c = Color(1.0, 0.0, 0.0);
        var d = Color(1.0, 1.0, 1.0);

        expect(a.toJSON(), 0x000000);
        expect(b.toJSON(), 0x007F00);
        expect(c.toJSON(), 0xFF0000);
        expect(d.toJSON(), 0xFFFFFF);
      });

      // OTHERS
      test("setWithNum", () {
        var c = Color();
        c.set(0xFF0000);
        expect(c.r, 1);
        expect(c.g, 0);
        expect(c.b, 0);
      });

      test("setWithString", () {
        var c = Color();
        c.set('silver');
        expect(c.getHex(), 0xC0C0C0);
      });

      test("setStyleRGBRed", () {
        var c = Color();
        c.setStyle('rgb(255,0,0)');
        expect(c.r, 1);
        expect(c.g, 0);
        expect(c.b, 0);
      });

      test("setStyleRGBARed", () {
        var c = Color();

        c.setStyle('rgba(255,0,0,0.5)');

        expect(c.r, 1);
        expect(c.g, 0);
        expect(c.b, 0);
      });

      test("setStyleRGBRedWithSpaces", () {
        var c = Color();
        c.setStyle('rgb( 255 , 0,   0 )');
        expect(c.r, 1);
        expect(c.g, 0);
        expect(c.b, 0);
      });

      test("setStyleRGBARedWithSpaces", () {
        var c = Color();
        c.setStyle('rgba( 255,  0,  0  , 1 )');
        expect(c.r, 1);
        expect(c.g, 0);
        expect(c.b, 0);
      });

      test("setStyleRGBPercent", () {
        var c = Color();
        c.setStyle('rgb(100%,50%,10%)');
        expect(c.r, 1);
        expect(c.g, 0.5);
        expect(c.b, 0.1);
      });

      test("setStyleRGBAPercent", () {
        var c = Color();

        c.setStyle('rgba(100%,50%,10%, 0.5)');

        expect(c.r, 1);
        expect(c.g, 0.5);
        expect(c.b, 0.1);
      });

      test("setStyleRGBPercentWithSpaces", () {
        var c = Color();
        c.setStyle('rgb( 100% ,50%  , 10% )');
        expect(c.r, 1);
        expect(c.g, 0.5);
        expect(c.b, 0.1);
      });

      test("setStyleRGBAPercentWithSpaces", () {
        var c = Color();

        c.setStyle('rgba( 100% ,50%  ,  10%, 0.5 )');

        expect(c.r, 1);
        expect(c.g, 0.5);
        expect(c.b, 0.1);
      });

      test("setStyleHSLRed", () {
        var c = Color();
        c.setStyle('hsl(360,100%,50%)');
        expect(c.r, 1);
        expect(c.g, 0);
        expect(c.b, 0);
      });

      test("setStyleHSLARed", () {
        var c = Color();

        c.setStyle('hsla(360,100%,50%,0.5)');

        expect(c.r, 1);
        expect(c.g, 0);
        expect(c.b, 0);
      });

      test("setStyleHSLRedWithSpaces", () {
        var c = Color();
        c.setStyle('hsl(360,  100% , 50% )');
        expect(c.r, 1);
        expect(c.g, 0);
        expect(c.b, 0);
      });

      test("setStyleHSLARedWithSpaces", () {
        var c = Color();

        c.setStyle('hsla( 360,  100% , 50%,  0.5 )');

        expect(c.r, 1);
        expect(c.g, 0);
        expect(c.b, 0);
      });

      test("setStyleHexSkyBlue", () {
        var c = Color();
        c.setStyle('#87CEEB');
        expect(c.getHex(), 0x87CEEB);
      });

      test("setStyleHexSkyBlueMixed", () {
        var c = Color();
        c.setStyle('#87cEeB');
        expect(
          c.getHex(),
          0x87CEEB,
        );
      });

      test("setStyleHex2Olive", () {
        var c = Color();
        c.setStyle('#F00');
        expect(
          c.getHex(),
          0xFF0000,
        );
      });

      test("setStyleHex2OliveMixed", () {
        var c = Color();
        c.setStyle('#f00');
        expect(
          c.getHex(),
          0xFF0000,
        );
      });

      test("setStyleColorName", () {
        var c = Color();
        c.setStyle('powderblue');
        expect(
          c.getHex(),
          0xB0E0E6,
        );
      });
    });
  });
}
