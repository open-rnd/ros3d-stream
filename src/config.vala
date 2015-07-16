errordomain ConfigError {
	LOAD_FAILED
}

namespace Config {

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