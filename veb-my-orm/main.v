module main

import db.mysql
import veb

pub struct Context {
	veb.Context
}

@[heap]
pub struct App {
pub mut:
	db mysql.DB
}

// Program entry point
fn main() {
	mut app := &App{}

	db_init(mut app)
	defer {
		app.db.close()
	}

	veb.run[App, Context](mut app, 8080)
}

@[inline]
fn db_init(mut app App) {
	app.db = mysql.connect(mysql.Config{
		host:     '127.0.0.1'
		port:     3306
		username: 'benchmarkdbuser'
		password: 'benchmarkdbpass'
		dbname:   'hello_world'
	}) or { panic(err) }
	// or { return ctx.server_error('Database connection failed') }
}
