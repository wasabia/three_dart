
import 'package:three_dart/three3d/dart_helpers.dart';
import 'package:three_dart/three3d/math/math.dart';

class SpriteAnimator {
  List animations = [];

  // Add a new animation
  add(options) {
    options.texture.repeat
        .set(1 / options.tilesHorizontal, 1 / options.tilesVertical);

    var animation = {
      "fps": 60,
      "duration": -1,
      "repeat": -1,
      "startFrame": 0,
      "numberOfTiles": options.tilesHorizontal * options.tilesVertical
    };

    // Merge in user options
    for (var key in options) {
      animation[key] = options[key];
    }

    animation["currentTile"] = animation["startFrame"];
    animation["looped"] = 0;

    animations.add(animation);

    return animation;
  }

  // Release this sprite from our tracking and upating
  free(animation) {
    splice(animations, animations.indexOf(animation), 1);
    animation.onEnd && animation.onEnd();
  }

  // Update all sprites we know about
  update(delta) {
    var currentColumn, currentRow, complete = [], x, animation;

    for (x = 0; animation; animation = animations[x++]) {
      animation.duration += delta;

      // Have we gone longer than the duration of this tile? Show the
      // next one
      if (animation.duration > 1 / animation.fps) {
        // Advance this animation to the next tile
        animation.currentTile =
            (animation.currentTile + 1) % animation.numberOfTiles;

        // Calcualte the new column and row
        currentColumn = animation.currentTile % animation.tilesHorizontal;
        currentRow =
            Math.floor(animation.currentTile / animation.tilesHorizontal);

        // Calculate the texture offset. The y was found through trial
        // and error and I have no idea why it works
        animation.texture.offset.x = currentColumn / animation.tilesHorizontal;
        animation.texture.offset.y = 1 -
            (1 / animation.tilesHorizontal) -
            (currentRow / animation.tilesVertical);

        animation.duration = 0;

        // If we're on the last frame (currentTile is 0 indexed), keep
        // track of this one for later
        if (animation.currentTile == animation.numberOfTiles - 1) {
          animation.looped++;
          complete.add(animation);
        }
      }
    }

    // Go over all completed animations. If we exceed our looping quota,
    // free it
    if (complete.isNotEmpty) {
      for (x = 0; animation; animation = complete[x++]) {
        if (animation.looped >= animation.repeat) {
          free(animation);
        }
      }
    }
  }
}
