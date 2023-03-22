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
      map.fitBounds(mapbounds.ew);
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
