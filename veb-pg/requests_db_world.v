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
		app.db.exec_param_many('UPDATE World SET randomNumber = $1 WHERE id = $2', [
			world.random_number.str(),
			world.id.str(),
		]) or { return ctx.server_error('Database update failed') }
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
	world_map := app.db.exec_one('SELECT id, randomNumber FROM CachedWorld WHERE id = ${id}') or {
		return CachedWorld{}
	}

	id_ := world_map.vals[0]
	random_number_ := world_map.vals[1]

	world := CachedWorld{
		id:            id_ or { '' }.int()
		random_number: random_number_ or { '' }.int()
	}

	return world
}

@[inline]
fn get_world(app &App, id int) World {
	world_map := app.db.exec_one('SELECT id, randomNumber FROM World WHERE id = ${id}') or {
		return World{}
	}

	id_ := world_map.vals[0]
	random_number_ := world_map.vals[1]

	world := World{
		id:            id_ or { '' }.int()
		random_number: random_number_ or { '' }.int()
	}

	return world
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
