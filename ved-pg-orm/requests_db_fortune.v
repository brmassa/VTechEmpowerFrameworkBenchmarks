module main

import veb

struct Fortune {
	id      int @[primary; sql: serial]
	message string
}

// Fortunes page. It will automatically output using `fortunes.html`
pub fn (app &App) fortunes(mut ctx Context) veb.Result {
	fortunes_map := app.db.exec('SELECT id, message FROM fortune') or {
		return ctx.server_error('Database query failed')
	}

	mut fortunes := []Fortune{}
	for fortune in fortunes_map {
		id_ := fortune.vals[0]
		message_ := fortune.vals[1]

		fortunes << Fortune{
			id:      id_ or { '' }.int()
			message: message_ or { '' }
		}
	}

	fortunes << Fortune{
		id:      0
		message: 'Additional fortune added at request time.'
	}

	fortunes.sort_with_compare(fn (a &Fortune, b &Fortune) int {
		return a.message.compare(b.message)
	})

	set_header(mut ctx, 'text/html; charset=UTF-8')
	return $veb.html()
}
