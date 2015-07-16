using Gst;

public class Main {

	// Command line options
	private static bool log_debug = false;
	private static string config_file = null;
	private static string pipeline = null;

	private static const GLib.OptionEntry[] options = {
		{"debug", 'd', 0, OptionArg.NONE, ref log_debug, "Show debug output", null},
		{"config", 'c', 0, OptionArg.FILENAME, ref config_file,
		 "Path to config file", null},
		{"stream", 's', 0, OptionArg.STRING, ref pipeline,
		 "Pipeline", null},
		{null}
	};

	/**
	 * setup_stream:
	 *
	 * Setup stream source.
	 * @return stream reference or null
	 */
	private static Stream? setup_stream() {
		string pipeline_desc;

		try {
			pipeline_desc = Config.data.get_string("main", "pipeline");
		} catch (KeyFileError err) {
			warning("failed to obtain pipeline description from configuration: %s",
					err.message);
			return null;
		}

		debug("pipeline: %s", pipeline_desc);

		var stream = Stream.from_desc(pipeline_desc, null);
		if (stream == null) {
			warning("failed to setup stream");
		}

		return stream;
	}

	/**
	 * setup_api:
	 *
	 * Setup client API, in this case a HTTP API
	 * @return api or null
	 */
	private static HttpAPI? setup_api() {
		int port = 0;
		try {
			port = Config.data.get_integer("api", "port");
		} catch (KeyFileError err) {
			warning("failed to obtain listen port from configuration: %s",
					err.message);
			return null;
		}

		debug("listen port: %d", port);

		// setup api
		var api = new HttpAPI(port);
		try {
			api.listen_all(port, 0);
		} catch (Error e) {
			warning("failed to start listening: %s", e.message);
		}

		return api;
	}

	public static int main(string[] args)
		{
			try {
				var opt_context = new OptionContext();
				opt_context.set_description("""Ros3D Video Streaming component.""");
				opt_context.set_help_enabled(true);
				opt_context.add_main_entries(options, null);
				opt_context.add_group(Gst.init_get_option_group());
				opt_context.parse(ref args);
			} catch (OptionError e) {
				stdout.printf("error: %s\n", e.message);
				stdout.printf("Run '%s --help' to see a full list of available command line options.\n",
							  args[0]);
				return 1;
			}

			if (log_debug == true)
				Environment.set_variable("G_MESSAGES_DEBUG", "all", false);

			if (config_file == null) {
				warning("need config file, see --help");
				return -1;
			}

			try {
				Config.load(config_file);

				if (log_debug == true)
					Config.debug_on = true;
			} catch (ConfigError e) {
				warning("failed to load configuration from %s: %s",
						config_file, e.message);
			}

			Gst.init(ref args);

			var stream = setup_stream();
			var api = setup_api();

			// reality check
			if (api == null || stream == null) {
				warning("failed to setup, cannot continue");
				return 1;
			}

			// setup manager
			var mgr = new StreamManager(stream);
			// and hookup the API
			mgr.add_client_api(api);

			// looop
			var loop = new MainLoop();
			// ready to go
			message("loop run()...");
			loop.run();
			message("loop done..");
			return 0;
		}
}