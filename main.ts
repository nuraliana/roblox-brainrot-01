// Giggle Grove: the entrypoint for make.fun's roblox-brainrot-01 bounty.
// The game is the Rojo project beside this file: `rojo build
// default.project.json --output game.rbxl` builds the place from src/, and
// this program hands it in. It copies game.rbxl, src/, screenshots/ and
// PLAY.json from beside this file to /output and writes /output/dossier.json,
// the summary the judge reads, with the vendored make.fun library.
//
// The grader refuses any name under /output that starts with a dot, so the
// copies below skip dotted names at every depth (.gitkeep, .DS_Store, .git).
// It also refuses a screenshot over 256 KiB or more than four of them, so
// those are checked here first and reported plainly instead of silently
// handing in a broken entry.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

/** Skip every file and directory whose name starts with a dot. */
const notDotted = (path: string): boolean => !basename(path).startsWith('.');

/** The gate caps screenshots at 4 files of 256 KiB each; fail loudly here. */
const screenshotsDir = join(here, 'screenshots');
const shots = existsSync(screenshotsDir) ? readdirSync(screenshotsDir).filter(notDotted) : [];
if (shots.length < 3 || shots.length > 4) {
	throw new Error(`expected 3 or 4 screenshots, found ${shots.length}`);
}
for (const shot of shots) {
	const size = statSync(join(screenshotsDir, shot)).size;
	if (size > 262144) {
		throw new Error(`screenshot ${shot} is ${size} bytes, over the 256 KiB cap`);
	}
}

copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: notDotted });
mkdirSync(join(out, 'screenshots'), { recursive: true });
if (existsSync(screenshotsDir)) cpSync(screenshotsDir, join(out, 'screenshots'), { recursive: true, filter: notDotted });

// The scorer's own caps (reference/gate.json): only text_max_bytes shapes the
// bytes; the others refuse an entry the scorer would refuse (a place of more
// than 500000 instances, whose scripts' sources come to over 8 MiB or whose
// scripts' paths come to over 1048576 characters, in all).
writeFileSync(
	join(out, 'dossier.json'),
	buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 }),
);
