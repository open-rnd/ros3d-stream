.. sectnum::

=================
Streaming Service
=================

:Author: Maciej Borzęcki <maciej.borzecki@open-rnd.pl>

.. contents:: Table of Contents
   :depth: 5

Overview
========

The streaming service can be used for streaming any UDP compatible,
valid, GStreamer pipeline to a desired network client. As of now, the
RTP is the recommended format that is both directly compatible with
UDP and fully supported by GStreamer. Due to lack of support for RTCP
on different mobile devices, the stream is controlled via a client
HTTP API.

The streaming service supports basic operations such as start, and
stop on a per client basis. There is no support for pause.

The streaming server cannot know if the data is reaching the client or
if client is still interested in receiving the stream. This would
normally be resolved using RTCP. For instance, the stream would be
automatically stopped if a TCP RTCP connection was closed (again, not
that obvious if RTCP is using UDP transport). From the server's
perspective, once the stream has been started, the client needs to
explicitly inform the server about it's interest in keeping the stream
on. The server will track each streaming session age, once the age has
passed certain limit (keepalive timeout set in daemon's configuration)
the stream will be automatically stopped. Thus it is important that
the client performs an occasional keepalive request.

Usage
=====

To start the streaming service run::

  ros3d-stream -c <path-to-config> [-d]

GStreamer
---------

The service needs a valid GStreamer pipeline to be supplied through
the configuration. The UDP stream is realized by `mutliudpsink`. The
daemon will look for a pipeline element named `stream` and
automatically connect `sink` pad of `multiudpsink` to the element's
`src` pad. The pads need to be compatible. If the pipeline cannot be
assembled the daemon will signal an error and terminate.

Use `gst-inspect-1.0` to verify if elements have compatible pads,
example::

  gst-inspect-1.0 rtph264pay
  gst-inspect-1.0 mutliudpsink


Avahi/Zeroconf
--------------

The service will announce itself using Zeroconf/Bonjour protocol. For
this reason an associated system daemon such as Avahi needs to be
running. The servic name is `Ros3D Streaming` of type
`_http._tcp`. The service announcement will contain the TCP port
number at which the service exports the HTTP client API.


Configuration
-------------

Example configuration::

  [main]
  # GStreamer pipeline to use. The streamer will look of element named
  # 'stream' and connect to it's src.
  # Default:
  #   videotestsrc ! x264enc  ! rtph264pay name=stream
  pipeline = videotestsrc ! x264enc  ! rtph264pay name=stream

  # Streaming client keepalive time. The client should ping the server
  # at at least this interval, but it may do so more frequently.
  # Default:
  #   60
  keepalive = 60

  [api]
  # The listen port for the API. The API is made available on all
  # interfaces.
  # Default:
  #   9918
  port = 9918


Test client
-----------

To start a test receiver use the `test-client` script in the source
directory. Make sure that the streaming service is started and run the
following command::

  ./test-client <ip>:<port>
  # assuming default settings and localhost
  ./test-client localhost:9918

HTTP API
========

Stream Start
------------

:URI: ``/start?port=<port>[&client=<IP>]``

   Parameter `port` is required, `client` is optional. If `client` is
   not provided an IP address of the incoming HTTP connection will be
   assumed as target host.

:HTTP Methods:
   - **POST**

:HTTP Status:
   - **200** - Stream started
   - **400** - Incorrect request parameters
   - **405** - Incorrect HTTP method - use **POST**
   - **503** - Too many clients connected

The response body is `text/plain` and contains only an assigned client
ID that is used in subsequent requests.

Stream Stop
-----------

:URI: ``/stop?id=<client-id>``

   Parameter `client-id` is required and has been provided as a result
   of a succesful `/start` request.

:HTTP Methods:
   - **POST**

:HTTP Status:
   - **200** - Stream stopped
   - **400** - Incorrect request parameters
   - **405** - Incorrect HTTP method - use **POST**

The response body is empty.

Keepalive
---------

Keepalive request is done by the client to indicate that it's still
interested in receiving the stream. The request should be done
frequently enough for keepalive timer not to expire.

:URI: ``/alive?id=<client-id>``

   Parameter `client-id` is required and has been provided as a result
   of a succesful `/start` request.

:HTTP Methods:
   - **POST**

:HTTP Status:
   - **200** - Stream stopped
   - **400** - Incorrect request parameters
   - **405** - Incorrect HTTP method - use **POST**

The response body is empty.

API Version
-----------

:URI: ``/version``

:HTTP Methods:
   - **GET**

:HTTP Status:
   - **200** - Version information provided
   - **405** - Incorrect HTTP method - use **GET**

The response body is `text/plain` and contains the API version.

Stream Info
-----------

.. note::

   NOT IMPLEMENTED

:URI: ``/info``

:HTTP Methods:
   - **GET**

:HTTP Status:
   - **200** - Stream information provided
   - **405** - Incorrect HTTP method - use **GET**

The response body is `text/plain` and contains a MIME encoded stream
information.
