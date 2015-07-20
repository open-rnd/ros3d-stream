namespace PublisherService {
		const string HTTP = "_http._tcp";

}

interface Publisher : Object {

	/**
	 * publish:
	 * @service: service name
	 * @port: port number
	 *
	 * Pulish a zeroconf @service. The service is accessible on @port,
	 * the type is assumed to be _http._tcp.
	 */
	public abstract bool publish(string service, uint16 port);
}

class AvahiPublisher : Object, Publisher {

	private Avahi.EntryGroup group = null;

	public AvahiPublisher() {

	}

	public bool publish(string service, uint16 port) {

		debug("publish service %s on port %d", service, port);

		try {
			var client = new Avahi.Client();
			debug("start client");
			client.start();

			group = new Avahi.EntryGroup();
			group.attach(client);
			var gservice = group.add_service(service,
											 PublisherService.HTTP,
											 port,
											 null);
			if (service == null) {
				warning("failed to add service");
				return false;
			}


			debug("commit group");
			// TODO: connect to state change signal?
			group.commit();
		} catch (Avahi.Error e) {
			warning("failed to publish to Avahi: %s", e.message);
			return false;
		}

		return true;
	}

}