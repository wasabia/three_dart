String fog_vertex = """
#ifdef USE_FOG

	fogDepth = - mvPosition.z;

#endif
""";
