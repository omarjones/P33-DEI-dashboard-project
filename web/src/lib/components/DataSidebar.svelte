<script>
	import Card from './cards/Card.svelte';
	import { base } from '$app/paths';
	import { lifestages } from '$lib/domain/Lifestage';

	export let lifestage;
</script>

<div class="hidden md:grid col-span-1 row-span-2 text-xl auto-rows-min gap-4">
	<Card>
		<ul class="uppercase font-sans-alternate mx-3 text-brand-primary-green">
			{#if !lifestage}
				<li class="capitalize leading-8">scorecard</li>
			{:else}
				<li class="capitalize"><a class="text-black" href={`${base}/scorecard`}>scorecard</a></li>
			{/if}
			{#each lifestages as _lifestage}
				{#if lifestage === _lifestage}
					<li class="leading-8">{_lifestage.name}</li>
				{:else}
					<li>
						<a class="text-black" href={`${base}/${_lifestage.route}/access`}>{_lifestage.name}</a>
					</li>
				{/if}
			{/each}
		</ul>
	</Card>
	<div class="bg-black text-white px-9 py-6">
		<h1 class="text-white">Life Stages</h1>
		<div class="py-4 text-base text-light-gray">
			<p>Magnet school enrollment rate relative to population size in...</p>
		</div>
		<div class="text-base text-light-gray">
			<p>Learn more about equity index</p>
		</div>
	</div>
</div>
