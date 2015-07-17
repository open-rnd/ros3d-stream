class StreamClient {
	public string host {get; set; default = null; }
	public uint16 port {get; set; default = 0; }
	public uint id { get; private set;  }
	public DateTime last_seen {get; set; default = null; }

	public StreamClient(string host, uint16 port, uint id) {
		this.host = host;
		this.port = port;
		this.id = id;
		refresh();
	}

	public string to_string() {
		return "%s:%u-%u".printf(this.host, this.port, this.id);
	}

	public void refresh() {
		this.last_seen = new DateTime.now_local();
	}

	/**
	 * age:
	 * @time_ref: time reference, if null DateTime.now_local() is used
	 *
	 * @return age in seconds
	 */
	public TimeSpan age(DateTime? time_ref = null) {
		var reference = time_ref;
		if (reference == null)
			reference = new DateTime.now_local();

		var diff = reference.difference(this.last_seen);
		// diff is in us, convert to s
		return diff / 1000 / 1000;
	}
}