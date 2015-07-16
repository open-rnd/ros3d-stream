class Stream {

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

	private string get_clients() {
		string clients;
		this.udpsink.get("clients", out clients);

		debug("clients: %s", clients);
		return clients;
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
	public void client_join_host(string host, uint port) {
		debug("adding client %s:%u", host, port);
		Signal.emit_by_name(udpsink, "add", host, port);

		start();
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

	public void client_join(StreamClient client) {
		client_join_host(client.host, client.port);
	}

	public void client_leave(StreamClient client) {
		client_leave_host(client.host, client.port);
	}
}