String alphatest_fragment = """
#ifdef ALPHATEST

	if ( diffuseColor.a < ALPHATEST ) discard;

#endif
""";
