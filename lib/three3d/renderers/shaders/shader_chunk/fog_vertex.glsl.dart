String fog_vertex = """
#ifdef USE_FOG

	vFogDepth = - mvPosition.z;

#endif
""";
