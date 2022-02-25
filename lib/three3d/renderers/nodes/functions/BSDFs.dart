part of renderer_nodes;

var F_Schlick = ShaderNode( ( inputs ) {

  var f0 = inputs.f0;
  var f90 = inputs.f90;
  var dotVH = inputs.dotVH;


	// Original approximation by Christophe Schlick '94
	// float fresnel = pow( 1.0 - dotVH, 5.0 );

	// Optimized variant (presented by Epic at SIGGRAPH '13)
	// https://cdn2.unrealengine.com/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf
	var fresnel = exp2( mul( sub( mul( - 5.55473, dotVH ), 6.98316 ), dotVH ) );

	return add( mul( f0, sub( 1.0, fresnel ) ), mul( f90, fresnel ) );

} ); // validated

var BRDF_Lambert = ShaderNode( ( inputs ) {

	return mul( RECIPROCAL_PI, inputs.diffuseColor ); // punctual light

} ); // validated

var getDistanceAttenuation = ShaderNode( ( inputs ) {

  var lightDistance = inputs.lightDistance;
  var cutoffDistance = inputs.cutoffDistance;
  var decayExponent = inputs.decayExponent;


	return cond(
		[and( greaterThan( cutoffDistance, 0 ), greaterThan( decayExponent, 0 ) ),
		pow( saturate( add( div( negate( lightDistance ), cutoffDistance ), 1.0 ) ), decayExponent ),
		1.0]
	);

} ); // validated

//
// STANDARD
//

// Moving Frostbite to Physically Based Rendering 3.0 - page 12, listing 2
// https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
var V_GGX_SmithCorrelated =  ShaderNode( ( inputs ) {

  var alpha = inputs.alpha;
  var dotNL = inputs.dotNL;
  var dotNV = inputs.dotNV;

	var a2 = pow2( alpha );

	var gv = mul( dotNL, sqrt( add( a2, mul( sub( 1.0, a2 ), pow2( dotNV ) ) ) ) );
	var gl = mul( dotNV, sqrt( add( a2, mul( sub( 1.0, a2 ), pow2( dotNL ) ) ) ) );

	return div( 0.5, max( add( gv, gl ), EPSILON ) );

} ); // validated

// Microfacet Models for Refraction through Rough Surfaces - equation (33)
// http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
// alpha is "roughness squared" in Disney’s reparameterization
var D_GGX = ShaderNode( ( inputs ) {

  var alpha = inputs.alpha;
  var dotNH = inputs.dotNH;

	var a2 = pow2( alpha );

	var denom = add( mul( pow2( dotNH ), sub( a2, 1.0 ) ), 1.0 ); // avoid alpha = 0 with dotNH = 1

	return mul( RECIPROCAL_PI, div( a2, pow2( denom ) ) );

} ); // validated


// GGX Distribution, Schlick Fresnel, GGX_SmithCorrelated Visibility
var BRDF_GGX = ShaderNode( ( inputs ) {

  var lightDirection = inputs.lightDirection;
  var f0 = inputs.f0;
  var f90 = inputs.f90;
  var roughness = inputs.roughness;

	var alpha = pow2( roughness ); // UE4's roughness

	var halfDir = normalize( add( lightDirection, positionViewDirection ) );

	var dotNL = saturate( dot( transformedNormalView, lightDirection ) );
	var dotNV = saturate( dot( transformedNormalView, positionViewDirection ) );
	var dotNH = saturate( dot( transformedNormalView, halfDir ) );
	var dotVH = saturate( dot( positionViewDirection, halfDir ) );

	var F = F_Schlick( { f0, f90, dotVH } );

	var V = V_GGX_SmithCorrelated( { alpha, dotNL, dotNV } );

	var D = D_GGX( { alpha, dotNH } );

	return mul( F, mul( V, D ) );

} ); // validated

var RE_Direct_Physical = ShaderNode( ( inputs ) {

  var lightDirection = inputs.lightDirection;
  var lightColor = inputs.lightColor;
  var directDiffuse = inputs.directDiffuse;
  var directSpecular = inputs.directSpecular;

	var dotNL = saturate( dot( transformedNormalView, lightDirection ) );
	var irradiance = mul( dotNL, lightColor );

	irradiance = mul( irradiance, PI ); // punctual light

	addTo( directDiffuse, mul( irradiance, BRDF_Lambert( { diffuseColor } ) ) );

	addTo( directSpecular, mul( irradiance, BRDF_GGX( { "lightDirection": lightDirection, "f0": specularColor, "f90": 1, "roughness": roughness } ) ) );

} );

var PhysicalLightingModel = ShaderNode( ( inputs/*, builder*/ ) {

	// PHYSICALLY_CORRECT_LIGHTS <-> builder.renderer.physicallyCorrectLights === true

	RE_Direct_Physical( inputs );

} );
