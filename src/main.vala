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

			var pipeline_desc = Config.data.get_string("main", "pipeline");
			var port = Config.data.get_integer("api", "port");

			debug("listen port: %d", port);
			debug("pipeline: %s", pipeline_desc);

			Gst.init(ref args);
			var stream = Stream.from_desc(pipeline_desc, null);
			if (stream == null) {
				warning("failed to setup stream");
				return -1;
			}

			var api = new HttpAPI(port);
			var loop = new MainLoop();

			try {
				api.listen_all(port, 0);
			} catch (Error e) {
				warning("failed to start listening: %s", e.message);
				return -1;
			}

			message("loop run()...");
			loop.run();
			message("loop done..");
			return 0;
		}
}