module main

import json
import rand
import veb

struct World {
	id int @[primary; sql: serial]
mut:
	random_number int @[sql: 'randomNumber']
}

struct CachedWorld {
	id int @[primary; sql: serial]
mut:
	random_number int @[sql: 'randomNumber']
}

pub fn (app &App) db(mut ctx Context) veb.Result {
	id := rand.int_in_range(1, 10001) or { panic(err) }
	world := get_world(app, id)

	set_header(mut ctx, 'application/json')
	return ctx.json(json.encode(world))
}

pub fn (app &App) queries(mut ctx Context) veb.Result {
	queries := get_query(ctx, 'queries')

	mut worlds := []World{}
	for _ in 0 .. queries {
		id := rand.int_in_range(1, 10001) or { panic(err) }
		world := get_world(app, id)
		worlds << world
	}

	set_header(mut ctx, 'application/json')
	return ctx.json(json.encode(worlds))
}

pub fn (app &App) updates(mut ctx Context) veb.Result {
	queries := get_query(ctx, 'queries')

	mut worlds := []World{}
	for _ in 0 .. queries {
		id := rand.int_in_range(1, 10001) or { panic(err) }
		world := get_world(app, id)
		worlds << world
	}

	for mut world in worlds {
		world.random_number = rand.int_in_range(1, 10001) or { panic(err) }
		sql app.db {
			update World set random_number = world.random_number where id == world.id
		} or { return ctx.server_error('Database update failed') }
	}

	set_header(mut ctx, 'application/json')
	return ctx.json(json.encode(worlds))
}

@['/cached-queries']
pub fn (app &App) cache(mut ctx Context) veb.Result {
	count := get_query(ctx, 'count')

	mut worlds := []CachedWorld{}
	for _ in 0 .. count {
		id := rand.int_in_range(1, 10001) or { panic(err) }
		world := get_cached_world(app, id)
		worlds << world
	}

	set_header(mut ctx, 'application/json')
	return ctx.json(json.encode(worlds))
}

@[inline]
fn get_cached_world(app &App, id int) CachedWorld {
	world := sql app.db {
		select from CachedWorld where id == id
	} or { return CachedWorld{} }

	return world.first()
}

@[inline]
fn get_world(app &App, id int) World {
	world := sql app.db {
		select from World where id == id
	} or { return World{} }

	return world.first()
}

@[inline]
fn get_query(ctx Context, index string) int {
	mut queries := ctx.query[index].int()
	return if queries < 1 {
		1
	} else if queries > 500 {
		500
	} else {
		queries
	}
}
