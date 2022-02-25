part of three_webgpu;


getFloatLength( floatLength ) {

	// ensure chunk size alignment (STD140 layout)

	return floatLength + ( ( GPUChunkSize - ( floatLength % GPUChunkSize ) ) % GPUChunkSize );

}

getVectorLength( count, [vectorLength = 4] ) {

	var strideLength = getStrideLength( vectorLength );

	var floatLength = strideLength * count;

	return getFloatLength( floatLength );

}

getStrideLength( vectorLength ) {

	var strideLength = 4;

	return vectorLength + ( ( strideLength - ( vectorLength % strideLength ) ) % strideLength );

}
