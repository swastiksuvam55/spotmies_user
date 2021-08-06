import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:spotmies/apiCalls/apiUrl.dart';

class LocationGet extends StatefulWidget {
  const LocationGet({Key key}) : super(key: key);

  @override
  _LocationGetState createState() => _LocationGetState();
}

class _LocationGetState extends State<LocationGet> {
  // List coor = [
  //   {17.836985, 83.698589},
  //   {17.885985, 83.698589},
  //   {17.836985, 83.612389}
  // ];
  final startLatController = new TextEditingController(text: "17.538455");
  final endLatController = new TextEditingController(text: "17.934493");
  final startLongController = new TextEditingController(text: "83.087737");
  final endLongController = new TextEditingController(text: "83.41598");
  final offsetController = new TextEditingController(text: "0.2");
  final placeNamController = new TextEditingController(text: "visakhapatnam");
  int loopCount = 0;
  var placeGeocode;
  String getPlace;
  checkCity(target) {
    var vizagArray = [
      "Visakhapatnam",
      "visakhapatnam",
      "VISAKHAPATNAM",
      "Vizag",
      "vizag",
      "VIZAG",
      "Vishakhapatnam",
      "vishakhapatnam"
    ];
    var add = target.first;
    for (var item in vizagArray) {
      // print("<<<${add.subAdminArea}>>>");
      if (add.locality != null) {
        if (add.locality.contains(item)) {
          return true;
        }
      }
      if (add.subLocality != null) {
        if (add.subLocality.contains(item)) return true;
      }
      if (add.addressLine != null) {
        if (add.addressLine.contains(item)) return true;
      }
      if (add.subAdminArea != null) {
        if (add.subAdminArea.contains(item)) return true;
      }
      if (add.adminArea != null) {
        if (add.adminArea.contains(item)) return true;
      }
      if (add.subThoroughfare != null) {
        if (add.subThoroughfare.contains(item)) return true;
      }
    }
    return false;
  }

  nullRectifier(address) {
    var posibleNulls = [
      "null",
      "Unnamed Road",
      "unnamed road",
      "unnamed",
      "Unnamed",
      "Null",
      "V8XH+5RR",
      "v8xh+5rr",
      "p755+mpx",
      "P755+MPX"
    ];
    var filteredAddress = address;
    var addressLineArray;
    addressLineArray = address['addressLine'].split(",");
    if (posibleNulls.contains(address['subLocality'])) {
      print("null>>>");
      if (!posibleNulls.contains(addressLineArray[0])) {
        filteredAddress['subLocality'] = addressLineArray[0];
      } else {
        filteredAddress['subLocality'] = addressLineArray[1];
        addressLineArray[0] = addressLineArray[1];
        filteredAddress['addressLine'] = addressLineArray.join(',');
      }
    }
    return filteredAddress;
  }

  Future<dynamic> getMethod() async {
    var uri = Uri.http("192.168.0.173:4000", "/api/stamp");
    print("url>> $uri");

    try {
      var response = await http.get(uri).timeout(Duration(seconds: 30));
      print("<>>>><${response.body}>>");
    } catch (e) {
      print("errys > $e");
    }
  }

  Future<dynamic> postMethod(String api, var body) async {
    var uri = Uri.http(API.localHost, api);
    print("body $body");
    var bodyData = json.encode(body);
    var newdata = {"data": bodyData};
    try {
      var response = await http.post(uri, body: newdata);

      print("response>> $response");
      return response;
    } catch (e) {
      print("error>> $e");
    }
  }

  function() async {
    var startLat = 17.538455;
    var startLong = 83.087737;
    var endLat = 17.934493;
    var endLong = 83.41598;
    double defaultOffset = 0.02000;
    var valstr1;
    var valstr2;
    var coor;
    var a;
    var b;
    var c;
    var d;
    var e;
    var f;
    var g;
    var h;
    var k;
    var l;
    var m;
    var n;

    List loc = [];
    var prevAddress;
    int counter = 0;

    var startLatCont = double.parse(startLatController.text) ?? startLat;
    var startLongCont = double.parse(startLongController.text) ?? startLong;
    var endLatCont = double.parse(endLatController.text) ?? endLat;
    var endLongCont = double.parse(endLongController.text) ?? endLong;
    var offsetCont = double.parse(offsetController.text) > 0.00002
        ? double.parse(offsetController.text)
        : defaultOffset;
    for (var j = startLatCont; j < endLatCont; j += offsetCont) {
      for (var i = startLongCont; i < endLongCont; i += offsetCont) {
        loopCount += 1;
        valstr1 = j;
        valstr2 = i;
        // print("$valstr1 : $valstr2");
        coor = Coordinates(valstr1, valstr2);
        var address = await Geocoder.local.findAddressesFromCoordinates(coor);
        if (prevAddress == null) prevAddress = address;
        if (address.first.addressLine.toLowerCase() !=
            prevAddress.first.addressLine.toLowerCase()) {
          // print("$valstr1 : $valstr2");
          // print("new address");
          a = address.first.subLocality;
          b = address.first.locality;
          c = address.first.coordinates;
          d = address.first.addressLine.toLowerCase();
          e = address.first.subAdminArea;
          f = address.first.postalCode;
          g = address.first.adminArea;
          h = address.first.subThoroughfare;
          k = address.first.featureName;
          l = address.first.thoroughfare;

          var val = {
            "subLocality": "$a",
            "locality": "$b",
            "coordinates": {"latitude": c.latitude, "logitude": c.longitude},
            "addressLine": "$d",
            "subAdminArea": "$e",
            "postalCode": "$f",
            "adminArea": "$g",
            "subThoroughfare": "$h",
            "featureName": "$k",
            "thoroughfare": "$l",
          };
          if (checkCity(address)) {
            loc.add(nullRectifier(val));
            counter += 1;
          }
          if (loopCount % 5 == 0) {
            print("loopCount >> $loopCount");
          }
          prevAddress = address;
        }
      }
    }
    setState(() {
      loopCount = loopCount;
    });

    if (counter == loc.length) {
      print("locy>>> $loc");
      // await getMethod();
      // var response = await postMethod("/api/geocode/newgeocode", loc);
      // print("response2 >> $response");
    }

    // log(firstAddress);
    // return '${valstr1.substring(0, 9)},${valstr2.substring(0, 9)}';
    return '';
  }

  findLocationName() async {
    var lat = double.parse(startLatController.text);
    var long = double.parse(startLongController.text);
    var coor = Coordinates(lat, long);
    var address = await Geocoder.local.findAddressesFromCoordinates(coor);
    print(address.first.locality);
    setState(() {
      getPlace = address.first.locality.toString();
    });
  }

  findNumberOfLocation() {
    var startLatCont = double.parse(startLatController.text);
    var startLongCont = double.parse(startLongController.text);
    var endLatCont = double.parse(endLatController.text);
    var endLongCont = double.parse(endLongController.text);
    var offsetCont = double.parse(offsetController.text) > 0.00002
        ? double.parse(offsetController.text)
        : 0.2;
    var count = 0;
    for (var j = startLatCont; j < endLatCont; j += offsetCont) {
      for (var i = startLongCont; i < endLongCont; i += offsetCont) {
        count += 1;
      }
    }
    print("count val $count");
    setState(() {
      loopCount = count;
    });
  }

  forwardGeocode() async {
    final query = placeNamController.text;
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = addresses.first;
    print("${first.featureName} : ${first.coordinates}");
    setState(() {
      placeGeocode = first.coordinates.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("geocode")),
      // body: MyCustomForm()
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: placeNamController,
                    decoration: InputDecoration(
                      helperText: "vizag",
                      border: UnderlineInputBorder(),
                      labelText: 'enter location to search',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: startLatController,
                    decoration: InputDecoration(
                      helperText: "17.538455",
                      border: UnderlineInputBorder(),
                      labelText: 'starting latitude',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: startLongController,
                    decoration: InputDecoration(
                      helperText: "83.087737",
                      border: UnderlineInputBorder(),
                      labelText: 'starting logitude',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: endLatController,
                    decoration: InputDecoration(
                      helperText: "17.934493",
                      border: UnderlineInputBorder(),
                      labelText: 'ending latitude',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: endLongController,
                    decoration: InputDecoration(
                      helperText: "83.41598",
                      border: UnderlineInputBorder(),
                      labelText: 'ending logitude',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: offsetController,
                    decoration: InputDecoration(
                      helperText: "0.00002",
                      border: UnderlineInputBorder(),
                      labelText: 'offset',
                    ),
                  ),
                ),
                Wrap(
                  children: [
                    Text("no of loc: ${loopCount.toString()}"),
                    Text("  geocode : $placeGeocode"),
                    Text("plac : $getPlace")
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 3.0,
                  children: [
                    ElevatedButton(
                      child: Text("Load locations"),
                      onPressed: () async {
                        await function();
                      },
                    ),
                    ElevatedButton(
                      child: Text("no of locs"),
                      onPressed: () async {
                        await findNumberOfLocation();
                      },
                    ),
                    ElevatedButton(
                      child: Text("forward"),
                      onPressed: () async {
                        await forwardGeocode();
                      },
                    ),
                    ElevatedButton(
                      child: Text("reverse"),
                      onPressed: () async {
                        await findLocationName();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      )
      //   ListView.builder(
      //   itemBuilder: (BuildContext context, int index) {
      //     return Container(
      //       child: Padding(
      //         padding: EdgeInsets.all(40.0),
      //         child: Text(function().toString()),
      //       ),
      //     );
      //   },

      // )
      ,
    );
  }
}

// function(List coor) {
//   // for (var e in coor) {
//   //   print(e);
//   //   return Text(e.toString());
//   // }

//   for (var i = 0; i < coor.length; i++) {
//     return Text(coor[i]);
//   }
// }

//  for (int i = 0; i <= len; i++) {
//                                     var imageData = {
//                                       'msg': _chatScreenController.imageLink[i],
//                                       'timestamp':
//                                           _chatScreenController.timestamp,
//                                       'sender': 'u',
//                                       'type': 'media'
//                                     };
//                                     String temp = jsonEncode(imageData);
//                                     await FirebaseFirestore.instance
//                                         .collection('messaging')
//                                         .doc(value)
//                                         .update({
//                                       'createdAt': DateTime.now(),
//                                       'body': FieldValue.arrayUnion([temp]),
//                                       'pmsgcount':
//                                           pread == 0 ? msgcount + 1 : 0,
//                                     });
//                                     Navigator.pop(context);
//                                   }

// getAddressofLocation(coordinates) async {
//   // Position position = await Geolocator.getCurrentPosition(
//   //     desiredAccuracy: LocationAccuracy.high);
//   // final coordinates = Coordinates(position.latitude, position.longitude);
//   var addresses =
//       await Geocoder.local.findAddressesFromCoordinates(coordinates);

//   // setState(() {
//   //   add1 = addresses.first.featureName;
//   //   add2 = addresses.first.addressLine;
//   //   add3 = addresses.first.subLocality;
//   // });
// }

// "{17.33,8322}"

var locationData = [
  {
    'locality':
        'mutyalammapalem rd, cheepurupalle east, andhra pradesh 531020, india',
    'postalCode': '531020',
    'loclity': 'Cheepurupalle East',
    'coordinates': {17.5392901, 83.0882101}
  },
];

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter a search term',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your username',
            ),
          ),
        ),
      ],
    );
  }
}
