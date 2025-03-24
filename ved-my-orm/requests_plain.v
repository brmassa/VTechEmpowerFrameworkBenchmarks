module main

import time
import veb
import json

// Home page. It will automatically output using `index.html`
pub fn (app &App) index(mut ctx Context) veb.Result {
	return $veb.html()
}

pub fn (app &App) plaintext(mut ctx Context) veb.Result {
	set_header(mut ctx, 'text/plain')
	return ctx.text('Hello, World!')
}

pub fn (app &App) json(mut ctx Context) veb.Result {
	data := json.encode({
		'message': 'Hello, World!'
	})
	set_header(mut ctx, 'application/json')
	return ctx.json(data)
}

@[inline]
fn set_header(mut ctx Context, content_type string) {
	ctx.set_header(.content_type, content_type)
	ctx.set_header(.server, 'V Veb')
	ctx.set_header(.date, time.now().utc_string())
}
