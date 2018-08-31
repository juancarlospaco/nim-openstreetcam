
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
    osc_access_token*, osm_request_token*, osm_secret_token*: string
  OSC* = OpenStreetCamBase[HttpClient]           ##  Sync OpenStreetCam API Client.
  AsyncOSC* = OpenStreetCamBase[AsyncHttpClient] ## Async OpenStreetCam API Client.


template get_form_data(this): untyped =
  ## Build a basic OSC Form Data Multipart, add Auth if declared, inject osc_form_data.
  var osc_form_data {.inject.} = newMultipartData()
  if declared(this.osc_access_token):
    echo "Adding access_token."
    osc_form_data["access_token"] = this.osc_access_token
  if declared(this.osm_request_token):
    echo "Adding request_token."
    osc_form_data["request_token"] = this.osm_request_token
  if declared(this.osm_secret_token):
    echo "Adding secret_token."
    osc_form_data["secret_token"] = this.osm_secret_token

proc osc_http_request(this: OSC | AsyncOSC, endpoint: string, multipart: MultipartData, body = ""): Future[JsonNode] {.multisync.} =
  ## Base function for all OpenStreetCam HTTPS GET/POST/PUT/DELETE API Calls.
  var client =
    when this is AsyncOSC: newAsyncHttpClient(
      proxy = when declared(this.proxy): this.proxy else: nil)
    else: newHttpClient(timeout = this.timeout * 1000,
      proxy = when declared(this.proxy): this.proxy else: nil)
  client.headers["DNT"] = "1"  # DoNotTrack.
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
  get_form_data(this)
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

proc get_nearby_sequences*(this: OSC | AsyncOSC, lat, lon: float, distance = 0.0): Future[JsonNode] {.multisync.} =
  ## http://api.openstreetcam.org/api/doc.html#operation--nearby-tracks-post
  get_form_data(this)
  osc_form_data["lat"] = $lat
  osc_form_data["lng"] = $lon  # Lon is lng, Longitude.
  # Optional parameters, all string.
  if distance != 0.0:
    osc_form_data["distance"] = $distance
  result = await osc_http_request(this, endpoint="nearby-tracks/", multipart=osc_form_data)

proc get_nearby_photos*(this: OSC | AsyncOSC, lat, lon, radius: float,
                        heading= 0.0, wayId= -1, page= -1, ipp= -1, externalUserId= -1, informData=""): Future[JsonNode] {.multisync.} =
  ## http://api.openstreetcam.org/api/doc.html#operation--nearby-tracks-post
  get_form_data(this)
  osc_form_data["lat"] = $lat
  osc_form_data["lng"] = $lon  # Lon is lng, Longitude.
  osc_form_data["radius"] = $radius
  # Optional parameters, all string.
  if heading != 0.0:
    osc_form_data["heading"] = $heading
  if wayId != -1:
    osc_form_data["wayId"] = $wayId
  if page != -1:
    osc_form_data["page"] = $page
  if ipp != -1:
    osc_form_data["ipp"] = $ipp
  if externalUserId != -1:
    osc_form_data["externalUserId"] = $externalUserId
  if informData != "":
    osc_form_data["informData"] = $informData
  result = await osc_http_request(this, endpoint="list/nearby-photos/", multipart=osc_form_data)

# proc post_sequence*(this: OSC | AsyncOSC, uploadSource="", platformName="", informData="",
#                     platformVersion="", appVersion=""): Future[JsonNode] {.multisync.} =
#   ## http://api.openstreetcam.org/api/doc.html#operation--nearby-tracks-post
#   get_form_data(this)
#   # Optional parameters, all string.
#   if uploadSource != "":
#     osc_form_data["uploadSource"] = uploadSource
#   if platformName != "":
#     osc_form_data["platformName"] = platformName
#   if page != -1:
#     osc_form_data["page"] = $page
#   if ipp != -1:
#     osc_form_data["ipp"] = $ipp
#   if externalUserId != -1:
#     osc_form_data["externalUserId"] = $externalUserId
#   if informData != "":
#     osc_form_data["informData"] = $informData
#   result = await osc_http_request(this, endpoint="list/nearby-photos/", multipart=osc_form_data)



when is_main_module:
  let osc_client = OSC(timeout: 9, proxy: nil)
  # echo osc_client.get_segments_bbox(bbTopLeft = "99.0,99.0", bbBottomRight = "90.0,90.0")
  # echo osc_client.get_nearby_sequences(lat = 25.0, lon = 55.0, distance = 999.0)  # FIXME  /1.0/
  echo osc_client.get_nearby_photos(lat = 20.0, lon = 20.0, radius = 999.0)
