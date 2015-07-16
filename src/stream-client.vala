class StreamClient {
	public string host {get; set; default = null; }
	public uint16 port {get; set; default = 0; }
	public uint id { get; private set;  }

	public StreamClient(string host, uint16 port, uint id) {
		this.host = host;
		this.port = port;
		this.id = id;
	}

	public string to_string() {
		return "%s:%u-%u".printf(this.host, this.port, this.id);
	}
}