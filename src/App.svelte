<script>
  import Map from "./lib/Map.svelte";
  import Soundscape from "./lib/Soundscape.svelte";
  import Scroller from "@sveltejs/svelte-scroller";

  let index, indexPrev, offset, progress;
  let map = null;

  // TO CHANGE FOR BUILD; FIND SECURE WAY
  const key = "";

  const mapbounds = {
    sg: [
      [103.5997, 1.4761],
      [104.0879, 1.1847],
    ],
    tanglin: [
      [103.7992, 1.3305],
      [103.8386, 1.2841],
    ],
    woodlands: [
      [103.7469, 1.4906],
      [103.8256, 1.3978],
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

        // Green spaces
        map.addSource("green_spaces", {
          type: "geojson",
          data: `https://api.maptiler.com/data/3e3800e4-4559-4148-90de-9d2a5b559961/features.json?key=${key}`,
        });

        map.addLayer({
          id: "green_spaces",
          type: "fill",
          source: "green_spaces",
          layout: { visibility: "none" },
          paint: {
            "fill-color": "#088",
            "fill-opacity": 0,
          },
        });

        //  Income by planning area
        map.addSource("income_zones", {
          type: "geojson",
          data: `https://api.maptiler.com/data/ee8e7985-34d8-4c38-b305-1257936b4957/features.json?key=${key}`,
        });

        map.addLayer({
          id: "income_zones",
          type: "fill",
          source: "income_zones",
          layout: { visibility: "none" },
          paint: {
            "fill-color": [
              "match",
              ["get", "income_range"],
              ["$3,000 - $3,999"],
              "#D9ED92",
              ["$4,000 - $4,999"],
              "#B5E48C",
              ["$5,000 - $5,999"],
              "#99D98C",
              ["$6,000 - $6,999"],
              "#76C893",
              ["$9,000 - $9,999"],
              "#168AAD",
              ["$10,000 - 10,999"],
              "#1A759F",
              ["$11,000 - 11,999"],
              "#1E6091",
              ["$12,000 - $14,999"],
              "#184E77",
              "rgba(0, 0, 0, 0.5)",
            ],
            "fill-opacity": 0.75,
            "fill-outline-color": "#fff",
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
      map.setLayoutProperty("calm_marker", "visibility", "visible");
      map.setLayoutProperty("boring_marker", "visibility", "none");
      map.setLayoutProperty("exciting_marker", "visibility", "none");
      map.setLayoutProperty("chaotic_marker", "visibility", "none");
      map.setLayoutProperty("green_spaces", "visibility", "none");
    },
    () => {
      map.fitBounds(mapbounds.sg);
      map.setLayoutProperty("pop_choropleth", "visibility", "none");
      map.setLayoutProperty("income_zones", "visibility", "none");
      map.setLayoutProperty("green_spaces", "visibility", "visible");
      map.setPaintProperty("green_spaces", "fill-opacity-transition", {
        duration: 2000,
      });

      setTimeout(() =>
        map.setPaintProperty("green_spaces", "fill-opacity", 0.5)
      );
    },
    () => {
      map.setLayoutProperty("green_spaces", "visibility", "none");
      map.setLayoutProperty("income_zones", "visibility", "visible");
      map.fitBounds(mapbounds.tanglin);
    },
    () => {
      map.fitBounds(mapbounds.woodlands);
    },

    () => {
      map.fitBounds(mapbounds.sg);
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

  <p>Listen to one soundscape below.</p>

  <Soundscape src="/soundscape.mp3" />

  <p>
    But what exactly is a soundscape? It is all the audible sounds within an
    area that give rise to a sense of place.
  </p>
  <p>
    Using the ISO 12913-2 model, soundscapes can be categorized into four
    quadrants, depending on how "pleasant" and "eventful" the sounds are to
    people.
  </p>

  <img src="/perceptual_quadrants.png" alt="Diagram of perceptual quantrants" />

  <p>
    <a href="https://arxiv.org/abs/2206.03112">A study</a> identified 62 such soundscapes
    by obtaining survey responses on each subregion in Singapore, before aggregating
    and clustering those responses across the entire city.
  </p>

  <Scroller top={0.2} bottom={0.8} bind:index bind:offset bind:progress>
    <div slot="background">
      <Map bind:map />
    </div>

    <div slot="foreground">
      <section>
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
        <p>
          Click the buttons to see where the various types of soundscapes are
          located
        </p>
      </section>
      <section>This is the second section.</section>
      <section>This is the third section.</section>
      <section>This is the 4th section.</section>
      <section>This is the 5th section.</section>
      <section>This is the final section.</section>
    </div>
  </Scroller>
  <div><section>New section</section></div>
</main>

<style>
  section {
    height: 80vh;
  }

  .button-calm {
    border: 3px solid #233d4d;
  }

  .button-boring {
    border: 3px solid #a1c181;
  }

  .button-exciting {
    border: 3px solid #fcca46;
  }

  .button-chaotic {
    border: 3px solid #fe7f2d;
  }

  button:hover {
    transform: scale(1.05) rotate(-1deg);
  }

  img {
    max-width: 360px;
    margin: 0.5em 0 1em 0;
  }
</style>
