using Gst;

class Stream {

	private Stream(Gst.Bin bin, Gst.Element endpoint) {

	}

	public static Stream? from_desc(string desc, string? name) {
		if (name == null)
			name = "stream";

		debug("try with pipeline: %s", desc);
		debug("         endpoint: %s", name);

		try {
			Gst.Bin bin = (Gst.Bin) Gst.parse_launch(desc);

			var endpoint = bin.get_by_name(name);

			if (endpoint == null) {
				warning("did not find an element with name %s", name);
				return null;
			}

			var s = new Stream(bin, endpoint);

			return s;
		} catch (Error e) {
			warning("failed to parse stream: %s", e.message);
			return null;
		}

	}
}