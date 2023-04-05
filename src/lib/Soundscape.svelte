<script context="module">
  const elements = new Set();
</script>

<script>
  import { onMount } from "svelte";

  export let src;

  let audio;
  let paused = true;

  onMount(() => {
    elements.add(audio);
    return () => elements.delete(audio);
  });

  function stopOthers() {
    elements.forEach((element) => {
      if (element !== audio) element.pause();
    });
  }
</script>

<audio bind:this={audio} bind:paused on:play={stopOthers} controls {src} />

<style>
  audio {
    width: 50%;
    margin: 0.5em 0 1em 0;
  }
</style>
