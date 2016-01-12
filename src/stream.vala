/**
 * Copyright (c) 2015 Open-RnD Sp. z o.o.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

class Stream : Object {

	private Gst.Element udpsink = null;
	private Gst.Pipeline pipeline = null;

	private Stream(Gst.Pipeline pipe, Gst.Element udpsink) {
		this.pipeline = pipe;
		this.udpsink = udpsink;

	}

	public static Stream? from_desc(string desc, string? name) {
		if (name == null)
			name = "stream";

		debug("try with pipeline: %s", desc);
		debug("         endpoint: %s", name);

		try {
			Gst.Pipeline pipe = (Gst.Pipeline) Gst.parse_launch(desc);

			var endpoint = pipe.get_by_name(name);

			if (endpoint == null) {
				warning("did not find an element with name %s", name);
				return null;
			}

			var udpsink = Gst.ElementFactory.make("multiudpsink", null);
			// add to pipeline
			pipe.add(udpsink);

			if (endpoint.link(udpsink) == false) {
				warning("failed to link endpoint %s to udpsink", name);
				return null;
			}

			// var pad = endpoint.get_static_pad("src");
			var pad = udpsink.get_static_pad("sink");
			pad.notify.connect((s, p) => {
					if (p.name == "caps") {
						debug("caps changed");
						debug("caps: %s", pad.caps.to_string());
					}
				});

			var s = new Stream(pipe, udpsink);
			return s;

		} catch (Error e) {
			warning("failed to parse stream: %s", e.message);
			return null;
		}

	}

	public bool is_on() {
		Gst.State state;
		pipeline.get_state(out state, null, Gst.CLOCK_TIME_NONE);

		if (state == Gst.State.NULL)
			return false;

		return true;
	}

	public void start() {
		if (is_on() == false)
			pipeline.set_state(Gst.State.PLAYING);
	}

	/**
	 * get_clients:
	 *
	 * Return a single string with comma separated <host>:<port>
	 * entries.
	 */
	private string get_clients() {
		string clients;
		this.udpsink.get("clients", out clients);

		debug("clients: %s", clients);
		return clients;
	}

	/**
	 * get_clients_array:
	 *
	 * Return an array of <host>:<port> strings
	 */
	private string[] get_clients_array() {
		string clients = get_clients();

		return clients.split(",");
	}

	/**
	 * is_client_on:
	 * @host: host
	 * @port: port
	 *
	 * Check if given client is already connected
	 *
	 * @return true if client is not being streamed to
	 */
	private bool is_client_on(string host, uint port) {
		string client_str = "%s:%u".printf(host, port);

		foreach (var cl in get_clients_array()) {
			if (client_str == cl)
				return true;
		}

		return false;
	}

	/**
	 * has_clients:
	 * @return: true if stream has clients added
	 */
	private bool has_clients() {
		return get_clients().length != 0;
	}

	/**
	 * pause_if_needed:
	 *
	 * Pause stream if no clients are listening
	 */
	public void pause_if_needed() {
		if (has_clients() == false)
			pipeline.set_state(Gst.State.NULL);
	}

	/**
	 * client_join_host:
	 * @host:
	 * @port:
	 *
	 * Add given @host:@port to stream receivers
	 */
	public bool client_join_host(string host, uint port) {
		debug("adding client %s:%u", host, port);

		if (is_client_on(host, port) == true) {
			warning("client %s:%u already on", host, port);
			return false;
		}

		Signal.emit_by_name(udpsink, "add", host, port);

		start();

		return true;
	}

	/**
	 * client_leave_host:
	 * @host:
	 * @port:
	 *
	 * Remove @host:@port from stream receivers
	 */
	public void client_leave_host(string host, uint port) {
		debug("removing client %s:%u", host, port);
		Signal.emit_by_name(udpsink, "remove", host, port);

		pause_if_needed();
	}

	public bool client_join(StreamClient client) {
		return client_join_host(client.host, client.port);
	}

	public void client_leave(StreamClient client) {
		client_leave_host(client.host, client.port);
	}
}