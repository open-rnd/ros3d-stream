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
		this.clients = new HashTable<uint, StreamClient>(direct_hash, direct_equal);
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
	 * get_random_id:
	 *
	 * @return: a randomized client id
	 */
	private static uint get_random_id() {
		return (uint) Random.int_range(1, int32.MAX);;
	}

	/**
	 * get_next_id:
	 *
	 * @return: a client ID that does not collide with currently
	 * tracked ones
	 */
	private uint get_next_id() {
		uint id = 0;
		while (true) {
			id = get_random_id();

			if (clients.contains(id) == true)
				debug("client ID collision, try next");
			else
				break;
		}

		debug("new available client ID: %u", id);
		return id;
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

		var id = get_next_id();
		var client = new StreamClient(host, (uint16) port, id);

		clients.insert(id, client);

		debug("starting client: %s", client.to_string());

		stream.client_join(client);

		return id;
	}


	/**
	 * client_stop:
	 * @id:
	 *
	 * Stop the stream for given client ID
	 */
	private void client_stop(uint id) {
		debug("stop client %u", id);

		if (clients.contains(id) == false) {
			warning("client %u not found", id);
			return;
		}

		var client = clients.get(id);

		debug("stopping client: %s", client.to_string());

		stream.client_leave(client);
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
