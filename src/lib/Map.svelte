<script>
  import { onMount, onDestroy } from "svelte";
  import { Map } from "maplibre-gl";
  import "maplibre-gl/dist/maplibre-gl.css";

  export let location = {
    bounds: [
      [103.5997, 1.4761],
      [104.0879, 1.1847],
    ], // Singapore bounding box
  };
  export let map;

  let mapContainer;
  let options;

  if (location.bounds) {
    options = { bounds: location.bounds };
  } else if (location.lon && location.lat) {
    options = { center: [location.lon, location.lat] };
  }

  // if (location.zoom) {
  //   options.zoom = location.zoom;
  // }

  onMount(() => {
    map = new Map({
      container: mapContainer, // container id
      style: `https://basemaps.cartocdn.com/gl/positron-gl-style/style.json`, // style URL
      ...options,
    });

    return () => {
      map.remove();
    };
  });
</script>

<div class="map-wrap">
  <div class="map" bind:this={mapContainer}>
    {#if map}
      <slot />
    {/if}
  </div>
</div>

<style>
  .map {
    position: absolute;
    width: 100%;
    height: 100%;
  }

  .map-wrap {
    position: relative;
    width: 100%;
    height: 35vh;
  }
</style>
