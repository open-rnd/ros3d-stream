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