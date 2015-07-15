
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
				opt_context.parse(ref args);
			} catch (OptionError e) {
				stdout.printf("error: %s\n", e.message);
				stdout.printf("Run '%s --help' to see a full list of available command line options.\n",
							  args[0]);
				return 1;
			}

			if (log_debug == true)
				Environment.set_variable("G_MESSAGES_DEBUG", "all", false);

			if (redirect_target == null || dev_xml == null) {
				warning("Missing command line arguments, see --help");
				return 11;
			}

			var loop = new MainLoop();

			message("loop run()...");
			loop.run();
			message("loop done..");
			return 0;
		}
}