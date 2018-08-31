# Nim-OpenStreetCam

- [OpenStreetCam](https://openstreetcam.org) API Lib for [Nim](https://nim-lang.org), Async & Sync, Pull Requests welcome.

![OpenStreetCam](https://raw.githubusercontent.com/juancarlospaco/nim-overpass/master/osm.jpg "OpenStreetCam")


# Install

- `nimble install openstreetcam`


# Use

```nim
import openstreetcam

# Sync client.
let osc_client = OSC(timeout: 9, proxy: nil)
osc_client.get_segments_bbox(bbTopLeft = "99.0,99.0", bbBottomRight = "90.0,90.0")

```


# API

- [Check the OpenStreetCam Docs](http://api.openstreetcam.org/api/doc.html), the Lib is a 1:1 copy of the official Docs.
- This Library uses API Version `1.0.0` from Year `2018`.
- Each proc links to the official OSC API docs.
- All procs should return an JSON Object `JsonNode`.
- The order of the procs follows the order on the OSC Docs.
- The naming of the procs follows the naming on the OSC Docs.
- The errors on the procs follows the errors on the OSC Docs.
- API Calls are all HTTP `POST`.
- API Calls use [the DoNotTrack HTTP Header.](https://en.wikipedia.org/wiki/Do_Not_Track)
- The `timeout` argument is on Seconds.
- For Proxy support define a `OSC.proxy` or `AsyncOSC.proxy` of `Proxy` type.
- No OS-specific code, so it should work on Linux, Windows and Mac. Not JS.
- Run the module itself for an Example.


# FAQ

- Whats OpenStreetCam ?.

Like Google Street View, but Open Source, Libre, Free.

- This works without SSL ?.

Yes.

- This works with SSL ?.

Yes.

- This works with Asynchronous code ?.

Yes.

- This works with Synchronous code ?.

Yes.

- This requires API Key or Login ?.

[Yes. User and Password.](https://www.openstreetmap.org/user/new)

- This requires Credit Card or Payments ?.

No.

- How to Search by Name ?.

[Use Nominatim for Search.](https://github.com/juancarlospaco/nim-nominatim#nim-nominatim)

- Can I use the OpenStreetCam data ?.

Yes.


# Requisites

- None.
