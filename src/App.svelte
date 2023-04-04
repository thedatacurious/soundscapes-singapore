<script>
  import Map from "./lib/Map.svelte";
  import Scroller from "@sveltejs/svelte-scroller";

  let index, indexPrev, offset, progress;
  let map = null;

  // TO CHANGE FOR BUILD; FIND SECURE WAY
  const key = "";

  const mapbounds = {
    ew: [
      [-5.816, 49.864],
      [1.863, 55.872],
    ],
    fareham: [
      [-1.228, 50.8368],
      [-1.165, 50.8699],
    ],
    newport: [
      [-3.0682, 51.5448],
      [-2.917, 51.6258],
    ],
  };

  const toggleLayer = function (layerId) {
    var visibility = map.getLayoutProperty(layerId, "visibility");
    if (visibility === "visible") {
      map.setLayoutProperty(layerId, "visibility", "none");
    } else {
      map.setLayoutProperty(layerId, "visibility", "visible");
    }
  };

  // Actions for MAP scroller
  const mapActions = [
    () => {
      map.on("load", function () {
        // population density choropleth
        map.addSource("pop_density", {
          type: "geojson",
          data: `https://api.maptiler.com/data/1769d603-8d0f-49d2-810d-63ad6eb01b20/features.json?key=${key}`,
        });

        map.addLayer({
          id: "pop_choropleth",
          source: "pop_density",
          layout: { visibility: "none" },
          type: "fill",
          paint: {
            "fill-color": [
              "interpolate",
              ["linear"],
              ["get", "population"],
              1,
              "#edf8fb",
              2,
              "#d3e5f0",
              5,
              "#b9d2e6",
              12,
              "#a6bbd9",
              35,
              "#95a2cc",
              85,
              "#8b88bf",
              249,
              "#896bb1",
              3461,
              "#874ea2",
              8783,
              "#842f8f",
              16039,
              "#810f7c",
            ],
            "fill-opacity": 0.75,
            "fill-outline-color": "#7f7f7f",
          },
        });

        // calm and tranquil
        map.loadImage("/calm_marker.png", async function (error, image) {
          if (error) throw error;
          map.addImage("calm_marker", image);
        });

        map.addSource("calm_sites", {
          type: "geojson",
          data: `https://api.maptiler.com/data/e76b0250-3175-46bc-9058-c03c74c4de32/features.json?key=${key}`,
        });

        map.addLayer({
          id: "calm_marker",
          type: "symbol",
          source: "calm_sites",
          layout: {
            "icon-image": "calm_marker",
            "icon-size": 0.05,
            "icon-anchor": "bottom",
            visibility: "visible",
            "icon-allow-overlap": true,
          },
          paint: {},
        });

        // boring and lifeless
        map.loadImage("/boring_marker.png", async function (error, image) {
          if (error) throw error;
          map.addImage("boring_marker", image);
        });

        map.addSource("boring_sites", {
          type: "geojson",
          data: `https://api.maptiler.com/data/7d6165ea-2836-4d19-8f67-70c8ca965f8c/features.json?key=${key}`,
        });

        map.addLayer({
          id: "boring_marker",
          type: "symbol",
          source: "boring_sites",
          layout: {
            "icon-image": "boring_marker",
            "icon-size": 0.05,
            "icon-anchor": "bottom",
            visibility: "none",
            "icon-allow-overlap": true,
          },
          paint: {},
        });

        // exciting and full of life
        map.loadImage("/exciting_marker.png", async function (error, image) {
          if (error) throw error;
          map.addImage("exciting_marker", image);
        });

        map.addSource("exciting_sites", {
          type: "geojson",
          data: `https://api.maptiler.com/data/b3be5c76-71a4-4ed4-a0d7-e7e453aa6e2c/features.json?key=${key}`,
        });

        map.addLayer({
          id: "exciting_marker",
          type: "symbol",
          source: "exciting_sites",
          layout: {
            "icon-image": "exciting_marker",
            "icon-size": 0.05,
            "icon-anchor": "bottom",
            visibility: "none",
            "icon-allow-overlap": true,
          },
          paint: {},
        });

        // chaotic and restless
        map.loadImage("/chaotic_marker.png", async function (error, image) {
          if (error) throw error;
          map.addImage("chaotic_marker", image);
        });

        map.addSource("chaotic_sites", {
          type: "geojson",
          data: `https://api.maptiler.com/data/dfd160c9-2963-4f11-a344-0b0504535286/features.json?key=${key}`,
        });

        map.addLayer({
          id: "chaotic_marker",
          type: "symbol",
          source: "chaotic_sites",
          layout: {
            "icon-image": "chaotic_marker",
            "icon-size": 0.05,
            "icon-anchor": "bottom",
            visibility: "none",
            "icon-allow-overlap": true,
          },
          paint: {},
        });
      });
    },
    () => {
      map.setLayoutProperty("pop_choropleth", "visibility", "visible");
      map.setLayoutProperty("boring_marker", "visibility", "none");
      map.setLayoutProperty("exciting_marker", "visibility", "none");
      map.setLayoutProperty("chaotic_marker", "visibility", "none");
    },
    () => {
      map.fitBounds(mapbounds.newport);
    },
    () => {
      map.fitBounds(mapbounds.fareham);
    },
  ];

  // Reactive code to trigger MAP actions
  $: if (map && index != indexPrev) {
    if (mapActions[+index]) {
      mapActions[+index]();
    }
    indexPrev = index;
  }
</script>

<main>
  <h1>Soundscapes of Singapore</h1>

  <p>
    A city is typically associated with hustle and bustle, but pockets of calm
    and tranquility exist.
  </p>

  <Scroller top={0.2} bottom={0.8} bind:index bind:offset bind:progress>
    <div slot="background">
      <p>
        This is the background content, at index {index}. It will stay fixed in
        place while the foreground scrolls over the top.
      </p>
      <Map bind:map />
    </div>

    <div slot="foreground">
      <section>
        <p>This is the first section</p>
        <button class="button-calm" on:click={() => toggleLayer("calm_marker")}
          >Calm</button
        >
        <button
          class="button-boring"
          on:click={() => toggleLayer("boring_marker")}>Boring</button
        >
        <button
          class="button-exciting"
          on:click={() => toggleLayer("exciting_marker")}>Exciting</button
        >
        <button
          class="button-chaotic"
          on:click={() => toggleLayer("chaotic_marker")}>Chaotic</button
        >
      </section>
      <section>This is the second section.</section>
      <section>This is the third section.</section>
      <section>This is the 4th section.</section>
    </div>
  </Scroller>
  <div><section>New section</section></div>
</main>

border: 1px solid #222222;

<style>
  section {
    height: 80vh;
  }

  .button-calm {
    border: 2px solid #233d4d;
  }

  .button-boring {
    border: 2px solid #a1c181;
  }

  .button-exciting {
    border: 2px solid #fcca46;
  }

  .button-chaotic {
    border: 2px solid #fe7f2d;
  }

  button:hover {
    transform: scale(1.05) rotate(-1deg);
  }
</style>
