
var LUTShader = {

	"defines": {
		"USE_3DTEXTURE": 1,
	},

	"uniforms": {
		"lut3d": { "value": null },

		"lut": { "value": null },
		"lutSize": { "value": 0 },

		"tDiffuse": { "value": null },
		"intensity": { "value": 1.0 },
	},

	"vertexShader": """

		varying vec2 vUv;

		void main() {

			vUv = uv;
			gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

		}

	""",


	"fragmentShader": """
		precision highp sampler3D;

		#if USE_3DTEXTURE
		uniform sampler3D lut3d;
		#else
		uniform sampler2D lut;
		uniform float lutSize;

		vec3 lutLookup( sampler2D tex, float size, vec3 rgb ) {

			// clamp the sample in by half a pixel to avoid interpolation
			// artifacts between slices laid out next to each other.
			float halfPixelWidth = 0.5 / size;
			rgb.rg = clamp( rgb.rg, halfPixelWidth, 1.0 - halfPixelWidth );

			// green offset into a LUT layer
			float gOffset = rgb.g / size;
			vec2 uv1 = vec2( rgb.r, gOffset );
			vec2 uv2 = vec2( rgb.r, gOffset );

			// adjust b slice offset
			float bNormalized = size * rgb.b;
			float bSlice = min( floor( size * rgb.b ), size - 1.0 );
			float bMix = ( bNormalized - bSlice ) / size;

			// get the first lut slice and then the one to interpolate to
			float b1 = bSlice / size;
			float b2 = ( bSlice + 1.0 ) / size;

			uv1.y += b1;
			uv2.y += b2;

			vec3 sample1 = texture2D( tex, uv1 ).rgb;
			vec3 sample2 = texture2D( tex, uv2 ).rgb;

			return mix( sample1, sample2, bMix );

		}
		#endif

		varying vec2 vUv;
		uniform float intensity;
		uniform sampler2D tDiffuse;
		void main() {

			vec4 val = texture2D( tDiffuse, vUv );
			vec4 lutVal;
			#if USE_3DTEXTURE
			lutVal = vec4( texture( lut3d, val.rgb ).rgb, val.a );
			#else
			lutVal = vec4( lutLookup( lut, lutSize, val.rgb ), val.a );
			#endif
			gl_FragColor = mix( val, lutVal, intensity );

		}

	""",

};
