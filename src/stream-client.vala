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

class StreamClient : Object {
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