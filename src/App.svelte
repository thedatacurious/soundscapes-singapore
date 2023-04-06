<script>
  import Map from "./lib/Map.svelte";
  import Soundscape from "./lib/Soundscape.svelte";
  import Scroller from "@sveltejs/svelte-scroller";
  import maplibregl from "maplibre-gl";

  let index, indexPrev, offset, progress;
  let map = null;

  const key = process.env.MAPTILER_KEY;

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
              5,
              "#b3cde3",
              35,
              "#8c96c5",
              249,
              "#8856a7",
              8783,
              "#810f7c",
            ],
            "fill-opacity": 1,
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
            "fill-color": [
              "match",
              ["get", "feature_type"],
              ["park", "nature_reserve", "forest", "wetland"],
              "#619B8A",
              "#618392",
            ],
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

  <Scroller
    top={0.2}
    bottom={0.8}
    threshold={0.65}
    bind:index
    bind:offset
    bind:progress
  >
    <div slot="background">
      <Map bind:map />
      {#if +index === 1}
        <div class="legend">
          <h4>Population density (People per 400m hex grid)</h4>
          <div><span style="background-color: #edf8fb" />1-4</div>
          <div><span style="background-color: #b3cde3" />5-35</div>
          <div><span style="background-color: #8c96c5" />36-248</div>
          <div><span style="background-color: #8856a7" />249-8,782</div>
          <div><span style="background-color: #810f7c" />8,783-38.556</div>
        </div>
      {/if}
      {#if +index === 5}
        <div class="legend">
          <h4>Median income bracket of region's residents</h4>
          <div><span style="background-color: #D9ED92BF" />$3,000 - $3,999</div>
          <div><span style="background-color: #B5E48CBF" />$4,000 - $4,999</div>
          <div><span style="background-color: #99D98CBF" />$5,000 - $5,999</div>
          <div><span style="background-color: #76C893BF" />$6,000 - $6,999</div>
          <div>
            <span style="background-color: #168AADBF" />$9,000 - $9,999
          </div>
          <div>
            <span style="background-color: #1A759FBF" />$10,000 - 10,999
          </div>
          <div>
            <span style="background-color: #1E6091BF" />$11,000 - 11,999
          </div>
          <div>
            <span style="background-color: #184E77BF" />$12,000 - $14,999
          </div>
        </div>
      {/if}
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
        <div class="overlay">
          <p>
            Click the buttons to see where the various types of soundscapes are
            located in Singapore.
          </p>
        </div>
      </section>
      <section>
        <div class="overlay">
          <p>
            What features make a calm and tranquil (C&T) soundscape different
            from another types?
          </p>
          <p>
            Perhaps unsurprisingly, such soundscapes tend to be found in
            relatively less dense areas. The areas that they overlap with have
            an average of 4,818 people per 400m hexagon. That's less than half
            the population density for other soundscape types.
          </p>
        </div>
      </section>
      <section>
        <div class="overlay">
          <p>
            Many of the C&T sites (60%) are found in green spaces, ranging from
            parks to nature reserves. The audio at the beginning was taken from
            Sungei Buloh Wetland Reserve, one of such sites.
          </p>
          <p>
            However, being surrounded by greenery isn't sufficient. Roughly 10%
            of soundscapes identified as boring and lifeless are also found in
            green spaces. More investigation is required.
          </p>

          <p>
            Regardless, C&T sites are a luxury in a busy city. This prompts the
            question: are there more of those soundscapes in wealthier areas?
          </p>
        </div>
      </section>
      <section>
        <div class="overlay">
          <p>
            This is Tanglin. It's a wealthy region, its residents having the
            highest median income bracket. The region has one C&T site, the
            Botanic Gardens Eco Lake.
          </p>
        </div>
      </section>
      <section>
        <div class="overlay">
          <p>
            If we head over to Woodlands, we'll see the region also has one C&T
            site, Admiralty Park. Its residents, together with those of nearby
            Yishun, have the lowest median income bracket.
          </p>
        </div>
      </section>
      <section>
        <div class="overlay">
          <p>
            C&T sites aren't clustered around wealthy regions. In fact, they are
            fairly scattered across Singapore.
          </p>
          <p>
            This is good news for those of us who like to explore, get lost, and
            find inner peace.
          </p>
        </div>
      </section>
    </div>
  </Scroller>
</main>

<svelte:head>
  <link
    rel="stylesheet"
    href="https://unpkg.com/maplibre-gl@2.4.0/dist/maplibre-gl.css"
  />
</svelte:head>

<style>
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

  div.overlay {
    position: absolute;
    background-color: #619b8a;
    opacity: 0.7;
    padding: 12px;
  }

  img {
    max-width: 360px;
    margin: 0.5em 0 1em 0;
  }

  .legend div span {
    border-radius: 50%;
    display: inline-block;
    height: 13px;
    margin-right: 5px;
    width: 13px;
  }

  section {
    height: 80vh;
  }
</style>
