part of three_extra;




class ShapePath {

  String type = "ShapePath";
  Color color = Color(1,1,1);
  List subPaths = [];
  Path? currentPath;
  Map<String, dynamic>? userData;

  ShapePath() {}

  moveTo( num x, num y ) {
		this.currentPath = Path(null);
		this.subPaths.add( this.currentPath );
		this.currentPath!.moveTo( x, y );
		return this;
	}

	lineTo( x, y ) {
		this.currentPath!.lineTo( x, y );
		return this;
	}

	quadraticCurveTo ( aCPx, aCPy, aX, aY ) {

		this.currentPath!.quadraticCurveTo( aCPx, aCPy, aX, aY );
		return this;
	}

	bezierCurveTo ( aCP1x, aCP1y, aCP2x, aCP2y, aX, aY ) {

		this.currentPath!.bezierCurveTo( aCP1x, aCP1y, aCP2x, aCP2y, aX, aY );

		return this;

	}

	splineThru ( pts ) {

		this.currentPath!.splineThru( pts );

		return this;

	}

	List<Shape> toShapes( bool isCCW, bool noHoles ) {

		Function toShapesNoHoles = ( inSubpaths ) {

			List<Shape> shapes = [];

			for ( var i = 0, l = inSubpaths.length; i < l; i ++ ) {

				var tmpPath = inSubpaths[ i ];

				var tmpShape = Shape(null);
				tmpShape.curves = tmpPath.curves;

				shapes.add( tmpShape );

			}

			return shapes;

		};

		Function isPointInsidePolygon = ( inPt, inPolygon ) {

			var polyLen = inPolygon.length;

			// inPt on polygon contour => immediate success    or
			// toggling of inside/outside at every single! intersection point of an edge
			//  with the horizontal line through inPt, left of inPt
			//  not counting lowerY endpoints of edges and whole edges on that line
			var inside = false;
			for ( var p = polyLen - 1, q = 0; q < polyLen; p = q ++ ) {

				var edgeLowPt = inPolygon[ p ];
				var edgeHighPt = inPolygon[ q ];

				var edgeDx = edgeHighPt.x - edgeLowPt.x;
				var edgeDy = edgeHighPt.y - edgeLowPt.y;

				if ( Math.abs( edgeDy ) > Math.EPSILON ) {

					// not parallel
					if ( edgeDy < 0 ) {

						edgeLowPt = inPolygon[ q ]; edgeDx = - edgeDx;
						edgeHighPt = inPolygon[ p ]; edgeDy = - edgeDy;

					}

					if ( ( inPt.y < edgeLowPt.y ) || ( inPt.y > edgeHighPt.y ) ) 		continue;

					if ( inPt.y == edgeLowPt.y ) {

						if ( inPt.x == edgeLowPt.x )		return	true;		// inPt is on contour ?
						// continue;				// no intersection or edgeLowPt => doesn't count !!!

					} else {

						var perpEdge = edgeDy * ( inPt.x - edgeLowPt.x ) - edgeDx * ( inPt.y - edgeLowPt.y );
						if ( perpEdge == 0 )				return	true;		// inPt is on contour ?
						if ( perpEdge < 0 ) 				continue;
						inside = ! inside;		// true intersection left of inPt

					}

				} else {

					// parallel or collinear
					if ( inPt.y != edgeLowPt.y ) 		continue;			// parallel
					// edge lies on the same horizontal line as inPt
					if ( ( ( edgeHighPt.x <= inPt.x ) && ( inPt.x <= edgeLowPt.x ) ) ||
						 ( ( edgeLowPt.x <= inPt.x ) && ( inPt.x <= edgeHighPt.x ) ) )		return	true;	// inPt: Point on contour !
					// continue;

				}

			}

			return	inside;

		};

		var isClockWise = ShapeUtils.isClockWise;

		var subPaths = this.subPaths;
		if ( subPaths.length == 0 ) return [];

		if ( noHoles == true )	return	toShapesNoHoles( subPaths );


		var solid, tmpPath, tmpShape;
		List<Shape> shapes = [];

		if ( subPaths.length == 1 ) {

			tmpPath = subPaths[ 0 ];
			tmpShape = Shape(null);
			tmpShape.curves = tmpPath.curves;
			shapes.add( tmpShape );
			return shapes;

		}

		var holesFirst = ! isClockWise( subPaths[ 0 ].getPoints() );
		holesFirst = isCCW ? ! holesFirst : holesFirst;

		// console.log("Holes first", holesFirst);

		var betterShapeHoles = [];
		var newShapes = [];
		var newShapeHoles = [];
		var mainIdx = 0;
		var tmpPoints;

		// newShapes[ mainIdx ] = null;
    listSetter(newShapes, mainIdx, null);

		// newShapeHoles[ mainIdx ] = [];
    listSetter(newShapeHoles, mainIdx, []);

		for ( var i = 0, l = subPaths.length; i < l; i ++ ) {

			tmpPath = subPaths[ i ];
			tmpPoints = tmpPath.getPoints();
			solid = isClockWise( tmpPoints );
			solid = isCCW ? ! solid : solid;

			if ( solid ) {

				if ( ( ! holesFirst ) && ( newShapes[ mainIdx ] != null ) )	mainIdx ++;

				// newShapes[ mainIdx ] = { "s": Shape(null), "p": tmpPoints };
        listSetter(newShapes, mainIdx, { "s": Shape(null), "p": tmpPoints });

				newShapes[ mainIdx ]["s"].curves = tmpPath.curves;

				if ( holesFirst )	mainIdx ++;
				// newShapeHoles[ mainIdx ] = [];
        listSetter(newShapeHoles, mainIdx, []);

				//console.log('cw', i);

			} else {

				newShapeHoles[ mainIdx ].add( { "h": tmpPath, "p": tmpPoints[ 0 ] } );

				//console.log('ccw', i);

			}

		}

		// only Holes? -> probably all Shapes with wrong orientation
		if ( newShapes.length == 0 || newShapes[ 0 ] == null )	return	toShapesNoHoles( subPaths );


		if ( newShapes.length > 1 ) {

			var ambiguous = false;
			var toChange = [];

			for ( var sIdx = 0, sLen = newShapes.length; sIdx < sLen; sIdx ++ ) {

				// betterShapeHoles[ sIdx ] = [];
        listSetter(betterShapeHoles, sIdx, []);

			}

			for ( var sIdx = 0, sLen = newShapes.length; sIdx < sLen; sIdx ++ ) {

				var sho = newShapeHoles[ sIdx ];

				for ( var hIdx = 0; hIdx < sho.length; hIdx ++ ) {

					var ho = sho[ hIdx ];
					var hole_unassigned = true;

					for ( var s2Idx = 0; s2Idx < newShapes.length; s2Idx ++ ) {

						if ( isPointInsidePolygon( ho["p"], newShapes[ s2Idx ]["p"] ) ) {

							if ( sIdx != s2Idx )	toChange.add( { "froms": sIdx, "tos": s2Idx, "hole": hIdx } );
							if ( hole_unassigned ) {

								hole_unassigned = false;
								betterShapeHoles[ s2Idx ].add( ho );

							} else {

								ambiguous = true;

							}

						}

					}

					if ( hole_unassigned ) {

						betterShapeHoles[ sIdx ].add( ho );

					}

				}

			}
			// console.log("ambiguous: ", ambiguous);

			if ( toChange.length > 0 ) {

				// console.log("to change: ", toChange);
				if ( ! ambiguous )	newShapeHoles = betterShapeHoles;

			}

		}

		var tmpHoles;

		for ( var i = 0, il = newShapes.length; i < il; i ++ ) {

			tmpShape = newShapes[ i ]["s"];
			shapes.add( tmpShape );
			tmpHoles = newShapeHoles[ i ];

			for ( var j = 0, jl = tmpHoles.length; j < jl; j ++ ) {

				tmpShape.holes.add( tmpHoles[ j ]["h"] );

			}

		}

		//console.log("shape", shapes);

		return shapes;

	}


}

