String transmissionmap_fragment = """
#ifdef USE_TRANSMISSIONMAP

	totalTransmission *= texture2D( transmissionMap, vUv ).r;

#endif
""";
