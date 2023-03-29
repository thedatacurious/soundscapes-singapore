<script>
  import Map from "./lib/Map.svelte";
  import Scroller from "@sveltejs/svelte-scroller";
  let index, indexPrev, offset, progress;

  let map = null;

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

  // Actions for MAP scroller
  const mapActions = [
    () => {
      // map.fitBounds(mapbounds.ew);
      map.on("load", function () {
        map.addSource("pop_density", {
          type: "geojson",
          data: "https://api.maptiler.com/data/1769d603-8d0f-49d2-810d-63ad6eb01b20/features.json?key=gOcDnGFbS89U5A6FqmcC",
        });

        map.addLayer({
          id: "pop_choropleth",
          source: "pop_density",
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
      });
    },
    () => {
      map.fitBounds(mapbounds.fareham);
    },
    () => {
      map.fitBounds(mapbounds.newport);
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
  <Scroller top={0.2} bottom={0.8} bind:index bind:offset bind:progress>
    <div slot="background">
      <p>
        This is the background content. It will stay fixed in place while the
        foreground scrolls over the top.
      </p>

      <Map bind:map />
    </div>

    <div slot="foreground">
      <section>This is the first section.</section>
      <section>This is the second section.</section>
      <section>This is the third section.</section>
      <section>This is the 4th section.</section>
    </div>
  </Scroller>
  <div><section>New section</section></div>
</main>

<style>
  section {
    height: 80vh;
  }
</style>
