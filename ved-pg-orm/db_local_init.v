module main

import veb
import rand

// Reset DB World table and fill with 10000 rows with random numbers from 1 to 10000
pub fn (app &App) db_init(mut ctx Context) veb.Result {
	mut error, mut error_msq := db_init_world(app, mut ctx)
	if error > 0 {
		return ctx.server_error(error_msq)
	}
	error, error_msq = db_init_world_cached(app, mut ctx)
	if error > 0 {
		return ctx.server_error(error_msq)
	}
	error, error_msq = db_init_fortune(app, mut ctx)
	if error > 0 {
		return ctx.server_error(error_msq)
	}

	set_header(mut ctx, 'text/plain')
	return ctx.text('World table reset and filled with 10000 rows
CachedWorld table reset and filled with 10000 rows
World table reset and filled with default rows')
}

fn db_init_world(app App, mut ctx Context) (int, string) {
	// sql app.db {
	// 	drop table World
	// } or { return 1, 'Failed to drop World table' }
	sql app.db {
		create table World
	} or { return 1, 'Failed to create World table' }

	for _ in 0 .. 10000 {
		world := World{
			random_number: rand.int_in_range(1, 10001) or { 1 }
		}

		sql app.db {
			insert world into World
		} or { return 1, 'Random number generation failed' }
	}

	return 0, ''
}

fn db_init_world_cached(app App, mut ctx Context) (int, string) {
	sql app.db {
		create table CachedWorld
	} or { return 1, 'Failed to create CachedWorld table' }

	for _ in 0 .. 10000 {
		cached_world := CachedWorld{
			random_number: rand.int_in_range(1, 10001) or { 1 }
		}

		sql app.db {
			insert cached_world into CachedWorld
		} or { return 1, 'Random number generation failed' }
	}

	return 0, ''
}

fn db_init_fortune(app App, mut ctx Context) (int, string) {
	sql app.db {
		create table Fortune
	} or { return 1, 'Failed to create Fortune table' }

	mut messages := []string{}
	messages << 'fortune: No such file or directory'
	messages << 'A computer scientist is someone who fixes things that arent broken.' // TODO: escape the aren't
	messages << 'After enough decimal places, nobody gives a damn.'
	messages << 'A bad random number generator: 1, 1, 1, 1, 1, 4.33e+67, 1, 1, 1'
	messages << 'A computer program does what you tell it to do, not what you want it to do.'
	messages << 'Emacs is a nice operating system, but I prefer UNIX. — Tom Christaensen'
	messages << 'Any program that runs right is obsolete.'
	messages << 'A list is only as strong as its weakest link. — Donald Knuth'
	messages << 'Feature: A bug with seniority.'
	messages << 'Computers make very fast, very accurate mistakes.'
	messages << '<script>alert("This should not be displayed in a browser alert box.");</script>'
	messages << 'フレームワークのベンチマーク'

	for message in messages {
		fortune := Fortune{
			message: message
		}
		sql app.db {
			insert fortune into Fortune
		} or { return 1, 'Failed to insert Fortune message' }
	}

	return 0, ''
}
