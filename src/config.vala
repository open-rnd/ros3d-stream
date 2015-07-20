errordomain ConfigError {
	LOAD_FAILED
}

namespace Config {

	const string DEFAULT_PIPELINE = "videotestsrc ! x264enc  ! rtph264pay name=stream";
	const int    DEFAULT_API_PORT = 9918;
	const int    DEFAULT_KEEPALIVE = 60;

	public KeyFile data  = null;
	public bool debug_on = false;

	void load(string path) throws ConfigError {
		data = new KeyFile();

		try {
			debug("load from file %s", path);
			data.load_from_file(path, KeyFileFlags.NONE);
		} catch (Error e) {
			throw new ConfigError.LOAD_FAILED("failed to load config: %s".printf(e.message));
		}
	}


}