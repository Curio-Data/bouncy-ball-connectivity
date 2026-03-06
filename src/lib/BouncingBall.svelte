<script lang="ts">
	let canvas = $state<HTMLCanvasElement | null>(null);
	let engine: any;
	let runner: any;
	let ball: any;
	let animFrameId: number;
	let Matter: any;
	let initialized = false;

	const BALL_RADIUS = 20;
	const WALL_THICKNESS = 60;
	const MIN_VELOCITY = 10;
	const IMPULSE_FORCE = 0.035;
	const FRAME_PADDING = 60; // min padding from viewport edges
	const FRAME_BORDER = 3;

	interface Frame {
		x: number;
		y: number;
		w: number;
		h: number;
	}

	function getFrame(canvasW: number, canvasH: number): Frame {
		const maxW = 800;
		const maxH = 600;
		const w = Math.min(maxW, canvasW - FRAME_PADDING * 2);
		const h = Math.min(maxH, canvasH - FRAME_PADDING * 2);
		return {
			x: (canvasW - w) / 2,
			y: (canvasH - h) / 2,
			w,
			h
		};
	}

	function createGradient(ctx: CanvasRenderingContext2D, x: number, y: number, radius: number) {
		const gradient = ctx.createRadialGradient(x - radius * 0.3, y - radius * 0.3, 0, x, y, radius);
		gradient.addColorStop(0, '#ffd93d');
		gradient.addColorStop(0.5, '#ff6b6b');
		gradient.addColorStop(1, '#ee5253');
		return gradient;
	}

	function createWalls(frame: Frame) {
		const opts = { isStatic: true, restitution: 1, friction: 0.001 };
		const { x, y, w, h } = frame;
		return [
			Matter.Bodies.rectangle(x - WALL_THICKNESS / 2, y + h / 2, WALL_THICKNESS, h + WALL_THICKNESS * 2, opts),
			Matter.Bodies.rectangle(x + w + WALL_THICKNESS / 2, y + h / 2, WALL_THICKNESS, h + WALL_THICKNESS * 2, opts),
			Matter.Bodies.rectangle(x + w / 2, y - WALL_THICKNESS / 2, w + WALL_THICKNESS * 2, WALL_THICKNESS, opts),
			Matter.Bodies.rectangle(x + w / 2, y + h + WALL_THICKNESS / 2, w + WALL_THICKNESS * 2, WALL_THICKNESS, opts)
		];
	}

	function handleResize() {
		if (!Matter || !engine || !canvas) return;

		const cw = window.innerWidth;
		const ch = window.innerHeight;
		canvas.width = cw;
		canvas.height = ch;

		const frame = getFrame(cw, ch);

		const allBodies = Matter.Composite.allBodies(engine.world);
		const staticBodies = allBodies.filter((b: any) => b.isStatic);
		Matter.Composite.remove(engine.world, staticBodies);
		Matter.Composite.add(engine.world, createWalls(frame));

		if (ball) {
			const bx = Math.max(frame.x + BALL_RADIUS, Math.min(frame.x + frame.w - BALL_RADIUS, ball.position.x));
			const by = Math.max(frame.y + BALL_RADIUS, Math.min(frame.y + frame.h - BALL_RADIUS, ball.position.y));
			Matter.Body.setPosition(ball, { x: bx, y: by });
		}
	}

	function drawFrame(ctx: CanvasRenderingContext2D, frame: Frame) {
		const wallColor = getComputedStyle(document.documentElement).getPropertyValue('--color-wall').trim() || '#2d3436';
		ctx.save();
		ctx.strokeStyle = wallColor;
		ctx.lineWidth = FRAME_BORDER;
		ctx.lineJoin = 'round';
		ctx.strokeRect(frame.x, frame.y, frame.w, frame.h);
		ctx.restore();
	}

	function draw() {
		if (!canvas || !ball) {
			animFrameId = requestAnimationFrame(draw);
			return;
		}

		const ctx = canvas.getContext('2d');
		if (!ctx) {
			animFrameId = requestAnimationFrame(draw);
			return;
		}

		ctx.clearRect(0, 0, canvas.width, canvas.height);

		const frame = getFrame(canvas.width, canvas.height);
		drawFrame(ctx, frame);

		const { x, y } = ball.position;

		ctx.save();
		ctx.shadowColor = 'rgba(255, 107, 107, 0.4)';
		ctx.shadowBlur = 20;
		ctx.beginPath();
		ctx.arc(x, y, BALL_RADIUS, 0, Math.PI * 2);
		ctx.fillStyle = createGradient(ctx, x, y, BALL_RADIUS);
		ctx.fill();
		ctx.restore();

		animFrameId = requestAnimationFrame(draw);
	}

	$effect(() => {
		if (!canvas || initialized) return;
		initialized = true;

		import('matter-js').then((mod) => {
			Matter = mod.default;

			if (!canvas) return;

			const cw = window.innerWidth;
			const ch = window.innerHeight;
			canvas.width = cw;
			canvas.height = ch;

			const frame = getFrame(cw, ch);

			engine = Matter.Engine.create({ gravity: { x: 0, y: 0.5 } });

			ball = Matter.Bodies.circle(frame.x + frame.w / 2, frame.y + frame.h / 3, BALL_RADIUS, {
				restitution: 1.0,
				friction: 0.001,
				frictionAir: 0.0005,
				frictionStatic: 0.05
			});

			const walls = createWalls(frame);
			Matter.Composite.add(engine.world, [ball, ...walls]);

			// Give the ball an initial high-energy kick
			Matter.Body.setVelocity(ball, { x: 10, y: -15 });

			Matter.Events.on(engine, 'afterUpdate', () => {
				if (!ball || !canvas) return;
				const vel = Math.sqrt(ball.velocity.x ** 2 + ball.velocity.y ** 2);
				if (vel < MIN_VELOCITY) {
					// Random angle impulse to keep energy high and varied
					const angle = Math.random() * Math.PI * 2;
					Matter.Body.applyForce(ball, ball.position, {
						x: Math.cos(angle) * IMPULSE_FORCE,
						y: Math.sin(angle) * IMPULSE_FORCE
					});
				}
			});

			runner = Matter.Runner.create();
			Matter.Runner.run(runner, engine);

			window.addEventListener('resize', handleResize);
			animFrameId = requestAnimationFrame(draw);
		});

		return () => {
			window.removeEventListener('resize', handleResize);
			if (animFrameId) cancelAnimationFrame(animFrameId);
			if (runner && Matter) Matter.Runner.stop(runner);
			if (engine && Matter) Matter.Engine.clear(engine);
		};
	});
</script>

<canvas bind:this={canvas}></canvas>

<style>
	canvas {
		display: block;
		width: 100vw;
		height: 100vh;
	}
</style>
