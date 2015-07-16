class StreamManager {
	/**
	 * active clients
	 */
	private HashTable<uint, StreamClient> clients;

	/**
	 * stream wrapper
	 */
	private Stream stream;

	public StreamManager(Stream s) {
		this.stream = s;
	}

	public void add_client_api(HttpAPI api) {

		api.client_start.connect((host, port) => {
				return this.client_start(host, port);
			});
		api.client_stop.connect((id) => {
				this.client_stop(id);
			});
		api.client_ping.connect((id) => {
				this.client_ping(id);
			});
	}

	/**
	 * client_start:
	 * @host:
	 * @port:
	 *
	 * Start a new client and return assigned ID
	 * @return non-0 client ID
	 */
	private uint client_start(string host, uint port) {
		debug("start client %s:%u", host, port);

		return 0;
	}

	/**
	 * client_stop:
	 * @id:
	 *
	 * Stop the stream for given client ID
	 */
	private void client_stop(uint id) {
		debug("stop client %u", id);
	}

	/**
	 * client_ping:
	 * @id:
	 *
	 * Keepalive request for given client
	 */
	private void client_ping(uint id) {
		debug("ping from client %u", id);
	}
}
