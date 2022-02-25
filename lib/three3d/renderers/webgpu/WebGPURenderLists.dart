part of three_webgpu;

painterSortStable( a, b ) {

	if ( a.groupOrder != b.groupOrder ) {

		return a.groupOrder - b.groupOrder;

	} else if ( a.renderOrder != b.renderOrder ) {

		return a.renderOrder - b.renderOrder;

	} else if ( a.material.id != b.material.id ) {

		return a.material.id - b.material.id;

	} else if ( a.z != b.z ) {

		return a.z - b.z;

	} else {

		return a.id - b.id;

	}

}

reversePainterSortStable( a, b ) {

	if ( a.groupOrder != b.groupOrder ) {

		return a.groupOrder - b.groupOrder;

	} else if ( a.renderOrder != b.renderOrder ) {

		return a.renderOrder - b.renderOrder;

	} else if ( a.z != b.z ) {

		return b.z - a.z;

	} else {

		return a.id - b.id;

	}

}

class WebGPURenderList {

  late List renderItems;
  late int renderItemsIndex;
  late List opaque;
  late List transparent;

	WebGPURenderList() {

		this.renderItems = [];
		this.renderItemsIndex = 0;

		this.opaque = [];
		this.transparent = [];

	}

	init() {

		this.renderItemsIndex = 0;

		this.opaque.length = 0;
		this.transparent.length = 0;

	}

	getNextRenderItem( object, geometry, material, groupOrder, z, group ) {

		var renderItem = null;

    if(this.renderItemsIndex < this.renderItems.length) {
      renderItem = this.renderItems[ this.renderItemsIndex ];
    }

		if ( renderItem == undefined ) {

			renderItem = RenderItem(
				id: object.id,
				object: object,
				geometry: geometry,
				material: material,
				groupOrder: groupOrder,
				renderOrder: object.renderOrder,
				z: z,
				group: group
      );

			// this.renderItems[ this.renderItemsIndex ] = renderItem;
      this.renderItems.add( renderItem );
		} else {

			renderItem.id = object.id;
			renderItem.object = object;
			renderItem.geometry = geometry;
			renderItem.material = material;
			renderItem.groupOrder = groupOrder;
			renderItem.renderOrder = object.renderOrder;
			renderItem.z = z;
			renderItem.group = group;

		}

		this.renderItemsIndex ++;

		return renderItem;

	}

	push( object, geometry, material, groupOrder, z, group ) {

		var renderItem = this.getNextRenderItem( object, geometry, material, groupOrder, z, group );

		( material.transparent == true ? this.transparent : this.opaque ).add( renderItem );

	}

	unshift( object, geometry, material, groupOrder, z, group ) {

		var renderItem = this.getNextRenderItem( object, geometry, material, groupOrder, z, group );

		( material.transparent == true ? this.transparent : this.opaque ).insert(0, renderItem );

	}

	sort( customOpaqueSort, customTransparentSort ) {

		if ( this.opaque.length > 1 ) this.opaque.sort( customOpaqueSort ?? painterSortStable );
		if ( this.transparent.length > 1 ) this.transparent.sort( customTransparentSort ?? reversePainterSortStable );

	}

	finish() {

		// Clear references from inactive renderItems in the list

		for ( var i = this.renderItemsIndex, il = this.renderItems.length; i < il; i ++ ) {

			var renderItem = this.renderItems[ i ];

			if ( renderItem.id == null ) break;

			renderItem.id = null;
			renderItem.object = null;
			renderItem.geometry = null;
			renderItem.material = null;
			renderItem.program = null;
			renderItem.group = null;

		}

	}

}

class WebGPURenderLists {

  late WeakMap lists;

	WebGPURenderLists() {

		this.lists = new WeakMap();

	}

	get( scene, camera ) {

		var lists = this.lists;

		var cameras = lists.get( scene );
		var list;

		if ( cameras == undefined ) {

			list = new WebGPURenderList();
			lists.set( scene, new WeakMap() );
			lists.get( scene ).set( camera, list );

		} else {

			list = cameras.get( camera );
			if ( list == undefined ) {

				list = new WebGPURenderList();
				cameras.set( camera, list );

			}

		}

		return list;

	}

	dispose() {

		this.lists = new WeakMap();

	}

}



class RenderItem {

  dynamic id;
  dynamic object;
  dynamic geometry;
  dynamic material;
  dynamic groupOrder;
  dynamic renderOrder;
  dynamic z;
  dynamic group;

  RenderItem({
    this.id,
    this.object,
    this.geometry,
    this.material,
    this.groupOrder,
    this.renderOrder,
    this.z,
    this.group
  });

}