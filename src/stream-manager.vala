class StreamManager : Object {

	/**
	 * default client keepalive
	 */
	public const int DEFAULT_KEEPALIVE = 60;

	/**
	 * active clients
	 */
	private HashTable<uint, StreamClient> clients;

	/**
	 * stream wrapper
	 */
	private Stream stream;

	/**
	 * keepalive interval
	 */
	private uint keepalive = DEFAULT_KEEPALIVE;
	private uint keepalive_on = 0;

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

	public void set_keepalive_time(uint time) {
		keepalive = time;
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

		start_keepalive_check();
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

		var client = clients.get(id);

		if (client != null) {
			client.refresh();
		}
	}

	/**
	 * start_keepalive_check:
	 */
	private void start_keepalive_check() {
		if (keepalive_on == 0) {
			debug("starting keepalive check, check every %u seconds",
				  keepalive);
			keepalive_on = Timeout.add_seconds(keepalive,
											   this.on_keepalive_check);
		}
	}

	/**
	 * stop_keeaplive_check:
	 */
	private void stop_keeaplive_check() {
		if (keepalive_on != 0) {
			Source.remove(keepalive_on);
			keepalive_on = 0;
		}
	}

	/**
	 * on_keepalive_check:
	 *
	 * @return true if keepalive checking should continue
	 */
	private bool on_keepalive_check() {
		check_stale_clients();

		if (clients.size() == 0) {
			stop_keeaplive_check();
			return false;
		}

		return true;
	}

	/**
	 * check_stale_clients:
	 *
	 * Check if stale clients exists and remove them
	 */
	private void check_stale_clients() {
		// go through all clients and check their age, if above
		// keepalive, then stop the stream and remove the client
		clients.foreach_remove((k, cl) => {
				var age = cl.age();
				debug("checking client %s of age: %s",
					  cl.to_string(), age.to_string());

				if (age > keepalive) {
					warning("removing stale client: %s", cl.to_string());

					// stop client stream
					stream.client_leave(cl);
					return true;
				}

				return false;
			});
	}

}
