errordomain HttpAPIError {
	BAD_REQUEST
}

class HttpAPI : Soup.Server {

	public HttpAPI(int port) {

		add_handler("/version", version_handler);
		add_handler("/info", info_handler);
		add_handler("/alive", alive_handler);
		add_handler("/start", start_handler);
		add_handler("/stop", stop_handler);
	}

	private static void dump_params(GLib.HashTable<string, string>? query) {
		if (query != null) {
			debug("query params:");
			query.foreach((key, val) => {
					debug("  %s: %s", key, val);
				});
		}
	}

	private static void dump_headers(Soup.MessageHeaders headers) {
		debug("heaers:");
		headers.foreach((n, v) => {
				debug("  %s: %s", n, v);
			});
	}

	private static string? client_address(Soup.ClientContext client) {
		var cl_address = client.get_remote_address() as InetSocketAddress;
		if (cl_address != null)
			return cl_address.address.to_string();

		return null;
	}

	private static void not_allowed(Soup.Message msg) {
		msg.set_status(Soup.Status.METHOD_NOT_ALLOWED);
	}

	private static string get_id(GLib.HashTable<string, string>? query) throws HttpAPIError {
		if (query == null)
			throw new HttpAPIError.BAD_REQUEST("No query provided");

		if (query.contains("id") == false)
			throw new HttpAPIError.BAD_REQUEST("No client ID");

		return query.get("id");
	}

	private static void log_request(Soup.Message msg,
									GLib.HashTable<string, string>? query,
									Soup.ClientContext client) {

		debug("dumping request info -->");
		debug("  request: %s", msg.method);
		debug("  URI: %s", msg.uri.to_string(false));
		dump_headers(msg.request_headers);
		dump_params(query);
		debug("<--");
	}

	private static void version_handler (Soup.Server server, Soup.Message msg, string path,
											GLib.HashTable<string, string>? query,
											Soup.ClientContext client) {
		log_request(msg, query, client);

		if (msg.method != "GET") {
			not_allowed(msg);
			return;
		}

		debug("version handler");
		debug("method: %s", msg.method);

		dump_params(query);

		msg.set_response("text/plain", Soup.MemoryUse.STATIC, "0.1".data);
		msg.set_status(Soup.Status.OK);
	}

	private static void info_handler (Soup.Server server, Soup.Message msg, string path,
										GLib.HashTable? query, Soup.ClientContext client) {
		debug("info handler");
		log_request(msg, query, client);


		msg.set_response("text/plain", Soup.MemoryUse.STATIC, "video/x-raw".data);
		msg.set_status(Soup.Status.OK);
	}

	private static void start_handler (Soup.Server server, Soup.Message msg, string path,
									   GLib.HashTable<string, string>? query,
									   Soup.ClientContext client) {
		debug("start handler");
		log_request(msg, query, client);


		// TODO limit capacity?

		string address = null;
		uint16 port = 0;

		try {
			if (query == null) {
				throw new HttpAPIError.BAD_REQUEST("No query parameters");
			} else {
				if (query.contains("port") == false) {
					// missing port
					throw new HttpAPIError.BAD_REQUEST("Port not provided");
				}

				// extract port
				port = (uint16) int.parse(query.get("port"));
				if (port == 0) {
					// bad parse
					throw new HttpAPIError.BAD_REQUEST("Bad port number");
				}

				if (query.contains("client") == true) {
					// client explicitly provided
					address = query.get("client");
				} else {
					// take client from request
					address = client_address(client);
				}
			}
		} catch (HttpAPIError e) {

			msg.set_response("text/plain", Soup.MemoryUse.COPY,
							 "Incorrect request: %s".printf(e.message).data);
			msg.set_status(Soup.Status.BAD_REQUEST);

			return;
		}

		debug("start stream to: %s:%u", address, port);

		// TODO return stream ID
		msg.set_response("text/plain", Soup.MemoryUse.STATIC, "1".data);
		msg.set_status(Soup.Status.OK);
	}

	private static void stop_handler (Soup.Server server, Soup.Message msg, string path,
										GLib.HashTable<string, string>? query,
										Soup.ClientContext client) {
		debug("stop handler");
		log_request(msg, query, client);

		try {
			var id = get_id(query);

		} catch (HttpAPIError e) {
			msg.set_response("text/plain", Soup.MemoryUse.COPY,
							 "Incorrect request: %s".printf(e.message).data);
			msg.set_status(Soup.Status.BAD_REQUEST);

			return;
		}

		// TODO verify stream ID
		msg.set_status(Soup.Status.OK);
	}

	private static void alive_handler (Soup.Server server, Soup.Message msg, string path,
										GLib.HashTable<string, string>? query,
										Soup.ClientContext client) {
		debug("alive handler");
		log_request(msg, query, client);

		try {
			var id = get_id(query);

		} catch (HttpAPIError e) {
			msg.set_response("text/plain", Soup.MemoryUse.COPY,
							 "Incorrect request: %s".printf(e.message).data);
			msg.set_status(Soup.Status.BAD_REQUEST);

			return;
		}

		// TODO verify stream ID
		msg.set_status(Soup.Status.OK);
	}

}