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