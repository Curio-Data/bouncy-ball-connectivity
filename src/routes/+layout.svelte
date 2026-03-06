<script lang="ts">
	import '../app.css';
	import { browser } from '$app/environment';

	let { children } = $props();
	let darkMode = $state(false);

	function toggleTheme() {
		darkMode = !darkMode;
		if (darkMode) {
			document.documentElement.classList.add('dark');
			localStorage.setItem('theme', 'dark');
		} else {
			document.documentElement.classList.remove('dark');
			localStorage.setItem('theme', 'light');
		}
	}

	$effect(() => {
		if (!browser) return;
		const saved = localStorage.getItem('theme');
		if (saved === 'dark') {
			darkMode = true;
			document.documentElement.classList.add('dark');
		} else if (saved === 'light') {
			darkMode = false;
		} else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
			darkMode = true;
			document.documentElement.classList.add('dark');
		}
	});
</script>

<svelte:head>
	<title>Connectivity Animation Test</title>
</svelte:head>

<div class="page-title">Connectivity Animation Test</div>
<button class="theme-toggle" onclick={toggleTheme} aria-label="Toggle theme">
	{darkMode ? '☀️' : '🌙'}
</button>

{@render children()}
