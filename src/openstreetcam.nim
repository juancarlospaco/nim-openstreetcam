
import asyncdispatch, json, httpclient, strformat, strutils, times, math

const
  osc_api_ver* = "1.0.0"  ## OpenStreetCam API Version (SemVer).
  osc_api_tos* = "https://openstreetcam.com/terms"  ## OpenStreetCam API Terms Of Service (TOS).
  osc_api_url* =
    when defined(ssl): "https://openstreetcam.org/1.0/" ## OpenStreetCam API URL (SSL).
    else:              "http://openstreetcam.org/1.0/"  ## OpenStreetCam API URL (No SSL).

type
  OpenStreetCamBase*[HttpType] = object
    timeout*: int8
    proxy*: Proxy
  OSC* = OpenStreetCamBase[HttpClient]           ##  Sync OpenStreetCam API Client.
  AsyncOSC* = OpenStreetCamBase[AsyncHttpClient] ## Async OpenStreetCam API Client.


proc osc_http_request(this: OSC | AsyncOSC, endpoint: string, multipart: MultipartData, body = "",
                      request_token = "", secret_token = ""): Future[JsonNode] {.multisync.} =
  ## Base function for all OpenStreetCam HTTPS GET/POST/PUT/DELETE API Calls.
  var client =
    when this is AsyncOSC: newAsyncHttpClient(
      proxy = when declared(this.proxy): this.proxy else: nil)
    else: newHttpClient(timeout = this.timeout * 1000,
      proxy = when declared(this.proxy): this.proxy else: nil)
  client.headers["DNT"] = "1"  # DoNotTrack.
#   if request_token != "" and secret_token != "":
#     multipart["request_token"] = request_token
#     multipart["secret_token"] = secret_token
  echo osc_api_url & endpoint
  let responses =
    when this is AsyncOSC: await client.postContent(url=osc_api_url & endpoint, body=body, multipart=multipart)
    else: client.postContent(url=osc_api_url & endpoint, body=body, multipart=multipart)
  result = parseJson(responses)

proc get_segments_bbox*(this: OSC | AsyncOSC, bbTopLeft: string, bbBottomRight: string,
                        obdInfo: range[-1..1] = -1, page: int32 = 1, ipp: int32 = -1, zoom: int32 = -1,
                        date_added = "", address = "", reviewed = "", changed = "",
                        count_active_photos = "", recognitions = ""): Future[JsonNode] {.multisync.} =
  ## http://api.openstreetcam.org/api/doc.html#mapdisplay
  var osc_form_data = newMultipartData()
  osc_form_data["bbTopLeft"] = bbTopLeft
  osc_form_data["bbBottomRight"] = bbBottomRight
  osc_form_data["page"] = $page
  # Optional parameters, all string.
  if obdInfo != -1:
    osc_form_data["obdInfo"] = $obdInfo
  if ipp != -1:
    osc_form_data["ipp"] = $ipp
  if zoom != -1:
    osc_form_data["zoom"] = $zoom
  if date_added != "":
    osc_form_data["date_added"] = date_added
  if address != "":
    osc_form_data["address"] = address
  if reviewed != "":
    osc_form_data["reviewed"] = reviewed
  if changed != "":
    osc_form_data["changed"] = changed
  if count_active_photos != "":
    osc_form_data["count_active_photos"] = count_active_photos
  if recognitions != "":
    osc_form_data["recognitions"] = recognitions
  result = await osc_http_request(this, endpoint="tracks/", multipart=osc_form_data)


when is_main_module:
  let osc_client = OSC(timeout: 9, proxy: nil)
  echo osc_client.get_segments_bbox(bbTopLeft = "99.0,99.0", bbBottomRight = "90.0,90.0")
